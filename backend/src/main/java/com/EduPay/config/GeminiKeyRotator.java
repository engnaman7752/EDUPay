package com.EduPay.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Round-robin rotator for multiple Gemini API keys.
 * Cycles through all configured keys to distribute load
 * and avoid per-key rate limits during development.
 */
@Component
public class GeminiKeyRotator {

    private static final Logger log = LoggerFactory.getLogger(GeminiKeyRotator.class);

    private final List<String> apiKeys;
    private final AtomicInteger index = new AtomicInteger(0);

    public GeminiKeyRotator(@Value("${edupay.ai.api-keys}") String rawKeys) {
        this.apiKeys = List.of(rawKeys.split(","))
                .stream()
                .map(String::trim)
                .filter(k -> !k.isBlank())
                .toList();

        if (this.apiKeys.isEmpty()) {
            throw new IllegalStateException("No Gemini API keys configured under 'edupay.ai.api-keys'");
        }
        log.info("🔑 GeminiKeyRotator initialized with {} key(s).", this.apiKeys.size());
    }

    /**
     * Returns the next API key in round-robin order.
     * Thread-safe — safe for concurrent requests.
     */
    public String nextKey() {
        int i = index.getAndUpdate(current -> (current + 1) % apiKeys.size());
        String key = apiKeys.get(i);
        log.debug("🔄 Using API key index {} (****{})", i, key.substring(Math.max(0, key.length() - 6)));
        return key;
    }

    public int keyCount() {
        return apiKeys.size();
    }
}
