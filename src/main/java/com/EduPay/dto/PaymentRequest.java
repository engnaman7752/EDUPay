package com.EduPay.dto;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;


@Data
@NoArgsConstructor
@AllArgsConstructor
public class PaymentRequest {
    private Long studentId;
    private Long feeId;
    private Double amount;
    private String currency;
    private String description; // Description for the payment gateway

}
