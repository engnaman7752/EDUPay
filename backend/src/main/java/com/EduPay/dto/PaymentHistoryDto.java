package com.EduPay.dto;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDateTime;
@Data
@NoArgsConstructor
@AllArgsConstructor
public class PaymentHistoryDto { // Changed to 'class'
    private Long id; // Payment record ID
    private String transactionId;
    private Double amount;
    private String paymentMethod; // "Cash" or "Online"
    private LocalDateTime paymentDate;
    private String status;
    private String studentName; // Name of the student who made the payment
    private String feeType; // Optional: if linked to a specific fee
    private String recordedByAdminName; // Optional: if cash payment was recorded by an admin
}