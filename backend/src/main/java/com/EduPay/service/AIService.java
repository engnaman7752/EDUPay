package com.EduPay.service;

import com.EduPay.config.GeminiKeyRotator;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.http.*;

import com.EduPay.model.Fee;
import com.EduPay.model.Student;
import com.EduPay.repository.FeeRepository;
import com.EduPay.repository.StudentRepository;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.util.*;
import java.util.stream.Collectors;

/**
 * Core AI Service - calls the native Gemini REST API directly.
 * This bypasses Spring AI's OpenAI compatibility layer to avoid
 * the restrictive OpenAI-endpoint quota limits.
 */
@Service
public class AIService {

    private static final Logger log = LoggerFactory.getLogger(AIService.class);

    @Value("${spring.ai.openai.chat.options.model:gemini-2.0-flash}")
    private String model;

    @Value("${edupay.ai.system-prompt:You are EduPay AI Assistant.}")
    private String systemPrompt;

    private final StudentRepository studentRepository;
    private final FeeRepository feeRepository;
    private final GeminiKeyRotator geminiKeyRotator;
    private final RestTemplate restTemplate = new RestTemplate();
    private final ObjectMapper objectMapper = new ObjectMapper();

    public AIService(StudentRepository studentRepository, FeeRepository feeRepository, GeminiKeyRotator geminiKeyRotator) {
        this.studentRepository = studentRepository;
        this.feeRepository = feeRepository;
        this.geminiKeyRotator = geminiKeyRotator;
    }

    /**
     * Calls the native Gemini generateContent REST API directly.
     */
    private String callGeminiNative(String prompt) {
        String currentKey = geminiKeyRotator.nextKey();
        String url = String.format(
                "https://generativelanguage.googleapis.com/v1beta/models/%s:generateContent?key=%s",
                model, currentKey);

        // Build the request body for native Gemini API
        Map<String, Object> requestBody = new HashMap<>();

        // System instruction
        Map<String, Object> systemInstruction = new HashMap<>();
        List<Map<String, String>> systemParts = new ArrayList<>();
        systemParts.add(Map.of("text", systemPrompt));
        systemInstruction.put("parts", systemParts);
        requestBody.put("systemInstruction", systemInstruction);

        // User content
        List<Map<String, Object>> contents = new ArrayList<>();
        Map<String, Object> userContent = new HashMap<>();
        userContent.put("role", "user");
        List<Map<String, String>> userParts = new ArrayList<>();
        userParts.add(Map.of("text", prompt));
        userContent.put("parts", userParts);
        contents.add(userContent);
        requestBody.put("contents", contents);

        // Generation config
        Map<String, Object> genConfig = new HashMap<>();
        genConfig.put("temperature", 0.7);
        genConfig.put("maxOutputTokens", 1024);
        requestBody.put("generationConfig", genConfig);

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);

        try {
            ResponseEntity<String> response = restTemplate.exchange(url, HttpMethod.POST, entity, String.class);

            if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
                JsonNode root = objectMapper.readTree(response.getBody());
                JsonNode candidates = root.path("candidates");
                if (candidates.isArray() && !candidates.isEmpty()) {
                    return candidates.get(0).path("content").path("parts").get(0).path("text").asText();
                }
                return "AI returned an empty response.";
            } else {
                log.error("Gemini API returned status {}: {}", response.getStatusCode(), response.getBody());
                return "AI Error: " + response.getStatusCode();
            }
        } catch (Exception e) {
            log.error("Native Gemini API call failed: {}", e.getMessage(), e);
            throw new RuntimeException("Gemini API error: " + e.getMessage());
        }
    }

    /**
     * Process a user's question with personalized student context.
     */
    public Map<String, Object> chat(String question, String username) {
        log.info("🤖 AI Chat request from user '{}': {}", username, question);

        // Get student-specific fee data for personalized responses
        String studentContext = getStudentContext(username);

        // Build the prompt with student context
        String augmentedPrompt = buildAugmentedPrompt(question, "", studentContext);

        String answer;
        List<String> sources = Collections.emptyList();
        try {
            answer = callGeminiNative(augmentedPrompt);
        } catch (Exception e) {
            log.error("❌ AI call failed: {}", e.getMessage(), e);
            answer = "API Error Details (for debugging): " + e.getMessage();
        }

        Map<String, Object> response = new HashMap<>();
        response.put("answer", answer);
        response.put("sources", sources);

        log.info("✅ AI response generated with {} sources", sources.size());
        return response;
    }

    /**
     * Fetches the student's fee data to provide personalized context to the AI.
     */
    private String getStudentContext(String username) {
        try {
            Optional<Student> studentOpt = studentRepository.findByStudentId(username);
            if (studentOpt.isEmpty()) {
                return "No student record found for this user.";
            }

            Student student = studentOpt.get();
            List<Fee> fees = feeRepository.findByStudent(student);

            StringBuilder sb = new StringBuilder();
            sb.append("Student Name: ").append(student.getName()).append("\n");
            sb.append("Student ID: ").append(student.getStudentId()).append("\n");
            sb.append("Class: ").append(student.getStandard()).append("\n\n");
            sb.append("Current Fee Records:\n");

            if (fees.isEmpty()) {
                sb.append("No fee records found.\n");
            } else {
                double totalOutstanding = 0;
                for (Fee fee : fees) {
                    sb.append(String.format("- %s: Total ₹%.2f, Paid ₹%.2f, Outstanding ₹%.2f, Due: %s, Status: %s%n",
                            fee.getFeeType(), fee.getAmount(), fee.getAmountPaid(),
                            fee.getOutstandingAmount(), fee.getDueDate(), fee.getStatus()));
                    totalOutstanding += fee.getOutstandingAmount();
                }
                sb.append(String.format("\nTotal Outstanding: ₹%.2f\n", totalOutstanding));
            }

            return sb.toString();
        } catch (Exception e) {
            log.warn("Could not fetch student context for '{}': {}", username, e.getMessage());
            return "Unable to fetch student-specific data.";
        }
    }

    /**
     * Builds the augmented prompt combining the user's question with context.
     */
    private String buildAugmentedPrompt(String question, String documentContext, String studentContext) {
        StringBuilder prompt = new StringBuilder();

        if (documentContext != null && !documentContext.isEmpty()) {
            prompt.append("### School Policy Context (from official documents):\n");
            prompt.append(documentContext);
            prompt.append("\n\n");
        }

        if (studentContext != null && !studentContext.isEmpty()) {
            prompt.append("### Student's Personal Data (CONFIDENTIAL - only share with this student):\n");
            prompt.append(studentContext);
            prompt.append("\n\n");
        }

        prompt.append("### Student's Question:\n");
        prompt.append(question);
        prompt.append("\n\n");
        prompt.append("Please answer based on the context above. ");
        prompt.append("If the question is about fees, use the student's actual fee data. ");
        prompt.append("Be concise, helpful, and professional.");

        return prompt.toString();
    }

    /**
     * Dedicated method for the Admin to generate a targeted announcement or notice
     * based on a specific student's fee status and a custom prompt phrase.
     */
    public String generateAdminNotice(Long studentId, String adminPrompt) {
        Student student = studentRepository.findById(studentId)
                .orElseThrow(() -> new RuntimeException("Student not found with ID: " + studentId));

        List<Fee> fees = feeRepository.findByStudent(student);
        double totalOutstanding = fees.stream().mapToDouble(Fee::getOutstandingAmount).sum();

        StringBuilder prompt = new StringBuilder();
        prompt.append("You are an administrative assistant writing an official school notice to a student.\n");
        prompt.append("Student Name: ").append(student.getName()).append("\n");
        prompt.append("Class/Standard: ").append(student.getStandard()).append("\n");

        if (totalOutstanding > 0) {
            prompt.append("Fee Status: The student currently has an OUTSTANDING balance of ₹")
                  .append(String.format("%.2f", totalOutstanding)).append(".\n");
            prompt.append("Goal: Write a polite but firm 'Fee Due Reminder' notice. ");
        } else {
            prompt.append("Fee Status: The student has completely PAID all their fees (Balance is ₹0).\n");
            prompt.append("Goal: Write a warm 'Thank You for your Payment' notice. ");
        }

        if (adminPrompt != null && !adminPrompt.isBlank()) {
            prompt.append("\nAdmin's Custom Instructions: \"").append(adminPrompt).append("\"\n");
        }

        prompt.append("\nRules:\n");
        prompt.append("1. Be professional and polite.\n");
        prompt.append("2. Keep it under 4 paragraphs.\n");
        prompt.append("3. Do not include signature blocks (like 'Sincerely, School Admin'). Just the message body.\n");

        try {
            return callGeminiNative(prompt.toString());
        } catch (Exception e) {
            log.error("AI Notice Generation failed: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to generate notice via AI: " + e.getMessage());
        }
    }
}
