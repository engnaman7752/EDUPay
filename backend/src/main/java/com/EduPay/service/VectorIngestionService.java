package com.EduPay.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.ai.document.Document;
import org.springframework.ai.reader.tika.TikaDocumentReader;
import org.springframework.ai.transformer.splitter.TokenTextSplitter;
import org.springframework.ai.vectorstore.VectorStore;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * Service responsible for ingesting school policy documents (PDFs)
 * into the pgvector vector store for RAG-based AI queries.
 *
 * On application startup, reads the school handbook PDF, splits it
 * into chunks, generates embeddings, and stores them in PostgreSQL.
 */
@Service
public class VectorIngestionService {

    private static final Logger log = LoggerFactory.getLogger(VectorIngestionService.class);

    private final VectorStore vectorStore;

    public VectorIngestionService(VectorStore vectorStore) {
        this.vectorStore = vectorStore;
    }

    /**
     * Triggered automatically when the application is fully started.
     * Reads the school handbook PDF and ingests it into the vector store.
     */
    // DISABLED: Auto-ingestion was burning API quota on every startup.
    // Re-enable this when you actually have a school handbook PDF to upload.
    // @EventListener(ApplicationReadyEvent.class)
    public void ingestDocuments() {
        log.info("📚 Document ingestion is DISABLED. No handbook PDF will be processed.");
    }
}
