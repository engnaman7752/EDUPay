package com.schoolApp.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;


@Entity
@Table(name = "fees")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Fee {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "student_id", nullable = false)
    private Student student;

    @NotNull(message = "Fee amount is required")
    @DecimalMin(value = "0.0", inclusive = false, message = "Fee amount must be positive")
    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal amount;

    @DecimalMin(value = "0.0", message = "Paid amount cannot be negative")
    @Column(name = "paid_amount", precision = 10, scale = 2)
    private BigDecimal paidAmount = BigDecimal.ZERO;

    @Column(name = "due_amount", precision = 10, scale = 2)
    private BigDecimal dueAmount;

    @NotNull(message = "Fee type is required")
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private FeeType feeType;

    @NotNull(message = "Fee month is required")
    @Column(name = "fee_month", nullable = false)
    private Integer feeMonth;

    @NotNull(message = "Fee year is required")
    @Column(name = "fee_year", nullable = false)
    private Integer feeYear;

    @NotNull(message = "Due date is required")
    @Column(name = "due_date", nullable = false)
    private LocalDate dueDate;

    @Column(name = "payment_date")
    private LocalDate paymentDate;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private PaymentStatus paymentStatus = PaymentStatus.PENDING;

    @Enumerated(EnumType.STRING)
    @Column(name = "payment_method")
    private PaymentMethod paymentMethod;

    @Column(name = "transaction_id", length = 100)
    private String transactionId;

    @Column(name = "receipt_number", length = 50)
    private String receiptNumber;

    @Size(max = 500, message = "Remarks cannot exceed 500 characters")
    @Column(length = 500)
    private String remarks;

    @Column(name = "late_fee", precision = 10, scale = 2)
    private BigDecimal lateFee = BigDecimal.ZERO;

    @Column(name = "discount", precision = 10, scale = 2)
    private BigDecimal discount = BigDecimal.ZERO;

    @Column(name = "sms_sent")
    private Boolean smsSent = false;

    @Column(name = "reminder_count")
    private Integer reminderCount = 0;

    @Column(name = "last_reminder_date")
    private LocalDate lastReminderDate;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    public enum FeeType {
        TUITION, TRANSPORT, LIBRARY, LABORATORY, SPORTS, EXAMINATION, ADMISSION, MISCELLANEOUS
    }

    public enum PaymentStatus {
        PENDING, PAID, PARTIALLY_PAID, OVERDUE, CANCELLED
    }

    public enum PaymentMethod {
        CASH, CARD, UPI, BANK_TRANSFER, CHEQUE, ONLINE
    }

    @PrePersist
    @PreUpdate
    private void calculateDueAmount() {
        if (amount != null && paidAmount != null) {
            dueAmount = amount.subtract(paidAmount);
        }
    }
}
