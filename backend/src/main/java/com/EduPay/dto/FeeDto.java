package com.EduPay.dto;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;


@Data
@NoArgsConstructor
@AllArgsConstructor
public class FeeDto {
    private Long id;
    private String feeType;
    private Double amount;
    private Double amountPaid;
    private Double outstandingAmount;
    private LocalDate dueDate;
    private String status;
    private Long studentId; // To link the fee to a student in DTO context
}