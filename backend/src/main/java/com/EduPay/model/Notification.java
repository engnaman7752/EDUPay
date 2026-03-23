package com.EduPay.model;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;

import java.time.LocalDateTime;

/**
 * Entity for storing real-time notifications sent to users.
 * Notifications can be AI-generated fee reminders or system alerts.
 */
@Entity
@Table(name = "notifications")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Notification {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long userId; // The user this notification is for

    @Column(nullable = false)
    private String title; // e.g., "Fee Reminder", "Payment Confirmation"

    @Column(nullable = false, length = 2000)
    private String message; // The notification content (can be AI-generated)

    @Column(nullable = false)
    private String type; // "FEE_REMINDER", "PAYMENT_CONFIRM", "AI_INSIGHT", "ANNOUNCEMENT"

    @Column(nullable = false)
    @Builder.Default
    private Boolean isRead = false;

    @Column(nullable = false)
    @Builder.Default
    private LocalDateTime createdAt = LocalDateTime.now();
}
