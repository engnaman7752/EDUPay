package com.EduPay.dto;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDateTime;
@Data
@NoArgsConstructor
@AllArgsConstructor
public class PaymentCallback { // Changed to 'class'
    private String razorpayPaymentId;
    private String razorpayOrderId;
    private String razorpaySignature; // For verifying the callback authenticity
    private String status; // e.g., "success", "failed"
    private String errorMessage; // If payment failed

}

