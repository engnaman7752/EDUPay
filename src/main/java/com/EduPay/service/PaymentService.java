package com.EduPay.service;

import com.EduPay.dto.PaymentHistoryDto;
import com.EduPay.model.Fee;
import com.EduPay.model.Payment;
import com.EduPay.model.Student;
import com.EduPay.model.User;
import com.EduPay.repository.FeeRepository;
import com.EduPay.repository.PaymentRepository;
import com.EduPay.repository.StudentRepository;
import com.EduPay.repository.UserRepository;
import com.EduPay.config.CustomUserDetails; // Corrected import: Import CustomUserDetails from config package
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;


/**
 * Service class for handling payment processing and history retrieval.
 * This service focuses on initiating and handling payment transactions,
 * and also provides the payment history for the current student.
 */
@Service
public class PaymentService {

    private final PaymentRepository paymentRepository;
    private final StudentRepository studentRepository;
    private final FeeRepository feeRepository;
    private final UserRepository userRepository;

    public PaymentService(PaymentRepository paymentRepository, StudentRepository studentRepository,
                          FeeRepository feeRepository, UserRepository userRepository) {
        this.paymentRepository = paymentRepository;
        this.studentRepository = studentRepository;
        this.feeRepository = feeRepository;
        this.userRepository = userRepository;
    }

    // Helper method to get the current authenticated user's ID from Spring Security Context
    private Long getCurrentUserId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            throw new RuntimeException("User is not authenticated.");
        }
        // Corrected: Cast the principal to CustomUserDetails, not CustomUserDetailsService
        if (authentication.getPrincipal() instanceof CustomUserDetails) {
            return ((CustomUserDetails) authentication.getPrincipal()).getId();
        } else {
            throw new RuntimeException("Authenticated principal is not of type CustomUserDetails.");
        }
    }

    /**
     * Simulates creating an order with a payment gateway (e.g., Razorpay).
     * In a real application, this would involve calling the Razorpay API.
     *
     * @param studentId The ID of the student initiating the payment.
     * @param feeId Optional ID of the fee being paid.
     * @param amount The amount to be paid.
     * @param currency The currency (e.g., "INR").
     * @param description A description for the payment.
     * @return A mock object representing the payment gateway's order response.
     * @throws RuntimeException if student or fee is not found.
     */
    @Transactional
    public Object createPaymentOrder(Long studentId, Long feeId, Double amount, String currency, String description) {
        Student student = studentRepository.findById(studentId)
                .orElseThrow(() -> new RuntimeException("Student not found with ID: " + studentId));

        // Optional: Validate fee if feeId is provided
        if (feeId != null) {
            Fee fee = feeRepository.findById(feeId)
                    .orElseThrow(() -> new RuntimeException("Fee not found with ID: " + feeId));
            if (!fee.getStudent().getId().equals(studentId)) {
                throw new RuntimeException("Fee does not belong to the specified student.");
            }
            // Further validation: check if amount matches outstanding, etc.
        }

        // --- Simulate Payment Gateway Order Creation ---
        // In a real scenario, integrate with Razorpay SDK/API here.
        // Example: RazorpayClient client = new RazorpayClient(keyId, keySecret);
        // JSONObject orderRequest = new JSONObject();
        // orderRequest.put("amount", amount * 100); // Razorpay expects amount in paisa
        // orderRequest.put("currency", currency);
        // orderRequest.put("receipt", "receipt_id_" + System.currentTimeMillis());
        // Order order = client.orders.create(orderRequest);
        // return order.toMap(); // Return the order details from Razorpay

        // For now, return a mock response
        String mockOrderId = "order_" + System.currentTimeMillis();
        System.out.println("Simulating payment order creation for student " + studentId + " with amount " + amount);
        return new Object() {
            public String orderId = mockOrderId;
            public Double amount = 100.0; // Use the actual amount passed
            public String currency = "INR";
            public String status = "created";
        };
    }


    /**
     * Handles the callback from the payment gateway (e.g., Razorpay webhook).
     * Verifies the payment and updates the database.
     *
     * @param razorpayPaymentId The payment ID from the gateway.
     * @param razorpayOrderId The order ID from the gateway.
     * @param razorpaySignature The signature for verification.
     * @param status The status of the payment (e.g., "success", "failed").
     * @param errorMessage Any error message from the gateway.
     * @throws RuntimeException if verification fails or payment update encounters an issue.
     */
    @Transactional
    public void handlePaymentGatewayCallback(String razorpayPaymentId, String razorpayOrderId,
                                             String razorpaySignature, String status, String errorMessage) {
        // --- Simulate Signature Verification ---
        // In a real scenario, verify the signature using Razorpay's utility.
        // Example: Utils.verifyPaymentSignature(attributes, razorpaySignature, razorpayKeySecret);
        // if (!verified) { throw new RuntimeException("Payment signature verification failed."); }

        System.out.println("Processing payment callback for order: " + razorpayOrderId + ", payment: " + razorpayPaymentId);

        // Find the corresponding payment record (if already created as 'pending' or similar)
        Optional<Payment> existingPaymentOpt = paymentRepository.findByGatewayOrderId(razorpayOrderId);
        Payment payment;

        if (existingPaymentOpt.isPresent()) {
            payment = existingPaymentOpt.get();
        } else {
            // This might happen if the payment record is created only after successful callback.
            // In a robust system, you'd likely have a 'pending' payment record created with the order.
            // For this example, we'll assume a mock student and amount if not found.
            payment = new Payment();
            payment.setTransactionId(razorpayPaymentId);
            Student mockStudent = studentRepository.findById(1L) // Placeholder student
                    .orElseThrow(() -> new RuntimeException("Mock student not found for payment callback."));
            payment.setStudent(mockStudent);
            payment.setAmount(100.0); // Placeholder amount, should come from order details or pre-created payment
            payment.setPaymentMethod("Online");
            payment.setPaymentDate(LocalDateTime.now());
        }

        payment.setGatewayPaymentId(razorpayPaymentId);
        payment.setGatewayOrderId(razorpayOrderId);
        payment.setStatus(status.equalsIgnoreCase("success") ? "Success" : "Failed");

        // Update fee status if payment is successful and linked to a fee
        if (status.equalsIgnoreCase("success")) {
            // Find the fee associated with this payment/order and update its status
            // This logic depends on how you link orders to fees.
            // For example, if your PaymentRequest includes feeId, you'd store it in the Payment entity
            // and then retrieve the Fee here.
            Optional<Fee> feeOpt = feeRepository.findByStudentIdAndStatus(payment.getStudent().getId(), "Pending"); // Simplified
            if (feeOpt.isPresent()) {
                Fee fee = feeOpt.get();
                fee.setAmountPaid(fee.getAmountPaid() + payment.getAmount());
                fee.setOutstandingAmount(fee.getOutstandingAmount() - payment.getAmount());
                if (fee.getOutstandingAmount() <= 0) {
                    fee.setStatus("Paid");
                } else {
                    fee.setStatus("Partially Paid");
                }
                feeRepository.save(fee);
            }
        } else {
            System.err.println("Payment failed for order " + razorpayOrderId + ": " + errorMessage);
        }

        paymentRepository.save(payment);
    }

    /**
     * Simulates verifying the status of a payment with the gateway.
     * This might be used for reconciliation or to check status of pending payments.
     *
     * @param paymentId The payment ID (e.g., Razorpay payment ID).
     * @return The verified status string.
     * @throws RuntimeException if payment is not found or gateway verification fails.
     */
    public String verifyPaymentStatus(String paymentId) {
        // In a real scenario, call Razorpay API to fetch payment status
        // Example: Payment payment = client.payments.fetch(paymentId);
        // return payment.get("status");

        // For now, simulate a status
        Optional<Payment> paymentOpt = paymentRepository.findByGatewayPaymentId(paymentId);
        if (paymentOpt.isPresent()) {
            return paymentOpt.get().getStatus();
        } else {
            throw new RuntimeException("Payment not found with ID: " + paymentId);
        }
    }

    /**
     * Retrieves the payment history for the currently authenticated student.
     *
     * @return List of PaymentHistoryDto for the student.
     * @throws RuntimeException if the student's user account is not linked to a student profile.
     */
    public List<PaymentHistoryDto> getPaymentHistoryForCurrentStudent() {
        // Get current user's ID from Spring Security context
        Long currentUserId = getCurrentUserId(); // Correctly fetches ID from CustomUserDetails

        // Find the User entity for the current authenticated user
        User studentUser = userRepository.findById(currentUserId)
                .orElseThrow(() -> new RuntimeException("Student user not found with ID: " + currentUserId));

        // Assuming student's username (name) is used to find the corresponding Student entity
        // Note: The StudentRepository.findByName method is needed for this to work.
        // If not already present, you'll need to add: Optional<Student> findByName(String name); to StudentRepository.java
        Student student = studentRepository.findByName(studentUser.getUsername())
                .orElseThrow(() -> new RuntimeException("Student profile not found for user: " + studentUser.getUsername()));

        List<Payment> payments = paymentRepository.findByStudentId(student.getId());
        return payments.stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }

    // Helper method for DTO conversion
    private PaymentHistoryDto convertToDto(Payment payment) {
        return new PaymentHistoryDto(
                payment.getId(),
                payment.getTransactionId(),
                payment.getAmount(),
                payment.getPaymentMethod(),
                payment.getPaymentDate(),
                payment.getStatus(),
                payment.getStudent() != null ? payment.getStudent().getName() : "N/A",
                null, // feeType - requires joining with Fee entity if needed
                payment.getRecordedBy() != null ? payment.getRecordedBy().getUsername() : null
        );
    }
}
