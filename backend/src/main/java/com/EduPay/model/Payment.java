package com.EduPay.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDateTime; // For payment date and time

@Entity
@Table(name = "payments") // Specify table name for clarity (plural is common)
@Data // Lombok annotation for getters, setters, toString, equals, hashCode
@NoArgsConstructor // Lombok annotation for no-argument constructor
@AllArgsConstructor // Lombok annotation for all-argument constructor
public class Payment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id; // Primary key for the payment record

    @Column(nullable = false)
    private String transactionId; // Unique ID for the transaction (e.g., from Razorpay or internal)

    @Column(nullable = false)
    private Double amount; // Amount of the payment

    @Column(nullable = false)
    private String paymentMethod; // "Cash" or "Online"

    @Column(nullable = false)
    private LocalDateTime paymentDate; // Date and time when the payment was made

    @Column(nullable = false)
    private String status; // e.g., "Success", "Pending", "Failed"

    // For online payments, store gateway-specific details
    @Column(nullable = true)
    private String gatewayPaymentId; // e.g., Razorpay payment ID

    @Column(nullable = true)
    private String gatewayOrderId; // e.g., Razorpay order ID

    // Relationship with Student entity: Many payments belong to one student
    @ManyToOne
    @JoinColumn(name = "student_id", nullable = false) // Foreign key column
    private Student student; // The student who made this payment

    // If cash payment, this links to the admin (User entity) who recorded it
    @ManyToOne
    @JoinColumn(name = "recorded_by_user_id", nullable = true) // Nullable because online payments aren't 'recorded' by an admin in this way
    private User recordedBy; // The admin user who manually recorded this cash payment


}
