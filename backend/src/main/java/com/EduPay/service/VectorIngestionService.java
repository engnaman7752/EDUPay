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
    @EventListener(ApplicationReadyEvent.class)
    public void ingestDocuments() {
        try {
            Resource pdfResource = new ClassPathResource("data/school-handbook.pdf");

            if (!pdfResource.exists()) {
                log.warn("⚠️ School handbook PDF not found at classpath:data/school-handbook.pdf. " +
                        "AI responses will not include policy information. " +
                        "Place a PDF file there and restart the application.");
                return;
            }

            log.info("📚 Starting ingestion of school handbook...");

            // Read the PDF using Apache Tika
            TikaDocumentReader reader = new TikaDocumentReader(pdfResource);
            List<Document> rawDocuments = reader.get();

            // Split into smaller chunks for better retrieval accuracy
            TokenTextSplitter splitter = new TokenTextSplitter(
                    300,   // default chunk size (tokens)
                    50,    // min chunk size
                    10,    // overlap
                    10000, // max tokens
                    true   // keep separator
            );
            List<Document> chunks = splitter.apply(rawDocuments);

            // Add source metadata to each chunk
            for (int i = 0; i < chunks.size(); i++) {
                Document chunk = chunks.get(i);
                chunk.getMetadata().put("source", "School Handbook");
                chunk.getMetadata().put("page", String.valueOf(i + 1));
            }

            // Store embeddings in pgvector
            vectorStore.add(chunks);

            log.info("✅ Successfully ingested {} document chunks into vector store.", chunks.size());

        } catch (Exception e) {
            log.error("❌ Failed to ingest school handbook: {}", e.getMessage(), e);
        }
    }
}
