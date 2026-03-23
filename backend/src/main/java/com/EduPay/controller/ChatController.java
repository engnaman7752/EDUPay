package com.EduPay.controller;

import com.EduPay.service.AIService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * REST controller for AI chat interactions.
 * Handles policy queries from parents/students using RAG.
 *
 * POST /api/ai/chat — Send a question, get an AI-generated answer
 * with source citations from the school handbook.
 */
@RestController
@RequestMapping("/api/ai")
public class ChatController {

    private final AIService aiService;

    public ChatController(AIService aiService) {
        this.aiService = aiService;
    }

    /**
     * Process an AI chat question.
     * The AI uses RAG to search school policies and the student's fee data
     * to generate a grounded, personalized response.
     *
     * @param request Map with "question" key
     * @param authentication The authenticated user's security context
     * @return Map with "answer" and "sources" keys
     */
    @PostMapping("/chat")
    public ResponseEntity<Map<String, Object>> chat(
            @RequestBody Map<String, String> request,
            Authentication authentication) {

        String question = request.get("question");
        if (question == null || question.trim().isEmpty()) {
            return ResponseEntity.badRequest().body(
                    Map.of("error", "Question cannot be empty"));
        }

        String username = authentication.getName();
        Map<String, Object> response = aiService.chat(question, username);

        return ResponseEntity.ok(response);
    }
}
