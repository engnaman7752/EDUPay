package com.EduPay.config;

import org.springframework.ai.chat.client.ChatClient;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Spring AI configuration for the EduPay AI assistant.
 * Configures the ChatClient with a system prompt for school-specific interactions.
 */
@Configuration
public class AIConfig {

    @Value("${edupay.ai.system-prompt}")
    private String systemPrompt;

    /**
     * Creates a ChatClient bean with the EduPay system prompt.
     * The ChatClient.Builder is auto-configured by Spring AI based on the
     * Gemini starter in application.yml.
     */
    @Bean
    public ChatClient chatClient(ChatClient.Builder builder) {
        return builder
                .defaultSystem(systemPrompt)
                .build();
    }

    /**
     * Creates an in-memory SimpleVectorStore using the local Transformers embedding model.
     * This avoids the need for installing complex pgvector extensions on Windows/pgAdmin.
     */
    @Bean
    public org.springframework.ai.vectorstore.VectorStore vectorStore(org.springframework.ai.embedding.EmbeddingModel embeddingModel) {
        return org.springframework.ai.vectorstore.SimpleVectorStore.builder(embeddingModel).build();
    }
}
