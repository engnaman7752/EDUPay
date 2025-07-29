package com.EduPay.controller;

import com.EduPay.dto.PaymentCallback;
import com.EduPay.dto.PaymentRequest;
import com.EduPay.service.PaymentService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/payments")
public class PaymentController {

    private final PaymentService paymentService;

    // Constructor for dependency injection
    public PaymentController(PaymentService paymentService) {
        this.paymentService = paymentService;
    }


    @PostMapping("/initiate")
    public ResponseEntity<?> initiatePayment(@RequestBody PaymentRequest paymentRequest) {
        try {
            // The service will interact with Razorpay SDK/API to create an order
            Object gatewayOrderResponse = paymentService.createPaymentOrder(
                    paymentRequest.getStudentId(),
                    paymentRequest.getFeeId(),
                    paymentRequest.getAmount(),
                    paymentRequest.getCurrency(),
                    paymentRequest.getDescription()
            );
            return ResponseEntity.ok(gatewayOrderResponse);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }


    @PostMapping("/callback")
    public ResponseEntity<?> handlePaymentCallback(@RequestBody PaymentCallback paymentCallback) {
        try {
            // The service will verify the payment signature and update the payment status in the DB
            paymentService.handlePaymentGatewayCallback(
                    paymentCallback.getRazorpayPaymentId(),
                    paymentCallback.getRazorpayOrderId(),
                    paymentCallback.getRazorpaySignature(),
                    paymentCallback.getStatus(),
                    paymentCallback.getErrorMessage()
            );
            return ResponseEntity.ok("Payment callback processed successfully.");
        } catch (RuntimeException e) {
            // Log the error and return an appropriate response
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }


    @GetMapping("/verify/{paymentId}")
    public ResponseEntity<?> verifyPayment(@PathVariable String paymentId) {
        try {
            // The service will call the payment gateway's API to verify the status
            String verifiedStatus = paymentService.verifyPaymentStatus(paymentId);
            return ResponseEntity.ok("Payment status: " + verifiedStatus);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }
}
