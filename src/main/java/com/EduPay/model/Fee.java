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

import java.time.LocalDate;

@Entity
@Table(name = "fees") // Specify table name for clarity
@Data // Lombok annotation for getters, setters, toString, equals, hashCode
@NoArgsConstructor // Lombok annotation for no-argument constructor
@AllArgsConstructor // Lombok annotation for all-argument constructor
public class Fee {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id; // Primary key for the fee record

    @Column(nullable = false)
    private String feeType; // e.g., "Tuition Fee", "Exam Fee", "Library Fee"

    @Column(nullable = false)
    private Double amount; // Total amount for this fee type

    @Column(nullable = false)
    private Double amountPaid; // Amount already paid for this fee

    @Column(nullable = false)
    private Double outstandingAmount; // Remaining amount to be paid

    @Column(nullable = false)
    private LocalDate dueDate; // Date by which the fee is due

    @Column(nullable = false)
    private String status; // e.g., "Pending", "Partially Paid", "Paid", "Overdue"

    // Relationship with Student entity: Many fees belong to one student
    @ManyToOne
    @JoinColumn(name = "student_id", nullable = false) // Foreign key column
    private Student student; // The student this fee belongs to


}
