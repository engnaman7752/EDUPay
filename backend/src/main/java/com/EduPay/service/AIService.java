package com.EduPay.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.document.Document;
import org.springframework.ai.vectorstore.SearchRequest;
import org.springframework.ai.vectorstore.VectorStore;
import org.springframework.stereotype.Service;

import com.EduPay.model.Fee;
import com.EduPay.model.Student;
import com.EduPay.repository.FeeRepository;
import com.EduPay.repository.StudentRepository;

import java.util.*;
import java.util.stream.Collectors;

/**
 * Core AI Service implementing RAG (Retrieval-Augmented Generation).
 *
 * When a parent/student asks a question:
 * 1. Performs similarity search in pgvector for relevant school policy chunks
 * 2. Fetches the student's fee data for personalized context
 * 3. Builds a grounded prompt with retrieved context + student data
 * 4. Calls Gemini via Spring AI ChatClient for the answer
 * 5. Returns response with source citations
 */
@Service
public class AIService {

    private static final Logger log = LoggerFactory.getLogger(AIService.class);

    private final ChatClient chatClient;
    private final VectorStore vectorStore;
    private final StudentRepository studentRepository;
    private final FeeRepository feeRepository;

    public AIService(ChatClient chatClient, VectorStore vectorStore,
                     StudentRepository studentRepository, FeeRepository feeRepository) {
        this.chatClient = chatClient;
        this.vectorStore = vectorStore;
        this.studentRepository = studentRepository;
        this.feeRepository = feeRepository;
    }

    /**
     * Process a user's question with RAG context.
     *
     * @param question The user's question
     * @param username The authenticated user's username (for scoping data)
     * @return Map containing "answer" and "sources"
     */
    public Map<String, Object> chat(String question, String username) {
        log.info("🤖 AI Chat request from user '{}': {}", username, question);

        // 1. Retrieve relevant documents from vector store
        List<Document> relevantDocs = vectorStore.similaritySearch(
                SearchRequest.builder()
                        .query(question)
                        .topK(5)
                        .similarityThreshold(0.5)
                        .build()
        );

        // 2. Build context from retrieved documents
        String documentContext = relevantDocs.stream()
                .map(Document::getText)
                .collect(Collectors.joining("\n\n---\n\n"));

        // 3. Build source citations
        List<String> sources = relevantDocs.stream()
                .map(doc -> {
                    String source = (String) doc.getMetadata().getOrDefault("source", "Unknown");
                    String page = (String) doc.getMetadata().getOrDefault("page", "");
                    return page.isEmpty() ? source : source + ", Page " + page;
                })
                .distinct()
                .collect(Collectors.toList());

        // 4. Get student-specific fee data for personalized responses
        String studentContext = getStudentContext(username);

        // 5. Build the user prompt with RAG context
        String augmentedPrompt = buildAugmentedPrompt(question, documentContext, studentContext);

        // 6. Call the LLM
        String answer;
        try {
            answer = chatClient.prompt()
                    .user(augmentedPrompt)
                    .call()
                    .content();
        } catch (Exception e) {
            log.error("❌ AI call failed: {}", e.getMessage(), e);
            answer = "I'm sorry, I'm having trouble processing your request right now. " +
                    "Please try again in a moment or contact the school office directly.";
            sources = Collections.emptyList();
        }

        // 7. Build response
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
     * Builds the augmented prompt combining the user's question with RAG context.
     */
    private String buildAugmentedPrompt(String question, String documentContext, String studentContext) {
        StringBuilder prompt = new StringBuilder();

        if (!documentContext.isEmpty()) {
            prompt.append("### School Policy Context (from official documents):\n");
            prompt.append(documentContext);
            prompt.append("\n\n");
        }

        if (!studentContext.isEmpty()) {
            prompt.append("### Student's Personal Data (CONFIDENTIAL - only share with this student):\n");
            prompt.append(studentContext);
            prompt.append("\n\n");
        }

        prompt.append("### Student's Question:\n");
        prompt.append(question);
        prompt.append("\n\n");
        prompt.append("Please answer based on the context above. ");
        prompt.append("If you reference a school policy, mention the source. ");
        prompt.append("If the question is about fees, use the student's actual fee data. ");
        prompt.append("Be concise, helpful, and professional.");

        return prompt.toString();
    }
}
