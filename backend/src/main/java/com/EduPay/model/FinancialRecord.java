package com.EduPay.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;

@Entity
@Table(name = "financial_records")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class FinancialRecord {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private BigDecimal amount;

    @Column(nullable = false)
    private String type; // INCOME, EXPENSE

    @Column(nullable = false)
    private String category; // FEES, SALARY, MAINTENANCE, EVENTS, OTHERS

    @Column(nullable = false)
    private LocalDate recordDate;

    @Column(columnDefinition = "TEXT")
    private String notes;
}
