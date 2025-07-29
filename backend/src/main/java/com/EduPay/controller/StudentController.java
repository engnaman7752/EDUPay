package com.EduPay.controller;

import com.EduPay.dto.AnnouncementDto;
import com.EduPay.dto.FeeDto;
import com.EduPay.dto.PaymentHistoryDto;
import com.EduPay.service.AnnouncementService;
import com.EduPay.service.FeeService; // Assuming a FeeService for student-specific fee retrieval
import com.EduPay.service.PaymentService; // Assuming a PaymentService for student-specific payment retrieval
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/student") // Base path for all endpoints in this controller
// Note: In a real application, you would add Spring Security annotations here
// to ensure only authenticated users with the 'STUDENT' role can access these endpoints.
// Example: @PreAuthorize("hasRole('STUDENT')")
public class StudentController {

    private final FeeService feeService;
    private final AnnouncementService announcementService;
    private final PaymentService paymentService;

    // Constructor for dependency injection
    public StudentController(FeeService feeService, AnnouncementService announcementService, PaymentService paymentService) {
        this.feeService = feeService;
        this.announcementService = announcementService;
        this.paymentService = paymentService;
    }


    @GetMapping("/fees")
    public ResponseEntity<List<FeeDto>> getMyFees() {
        List<FeeDto> studentFees = feeService.getFeesForCurrentStudent(); // Service will filter by student
        return ResponseEntity.ok(studentFees);
    }


    @GetMapping("/announcements")
    public ResponseEntity<List<AnnouncementDto>> getAnnouncements() {
        // This could fetch announcements targeted at students or all general announcements
        List<AnnouncementDto> announcements = announcementService.getAnnouncementsForStudents();
        return ResponseEntity.ok(announcements);
    }


    @GetMapping("/payments/history")
    public ResponseEntity<List<PaymentHistoryDto>> getPaymentHistory() {
        System.out.println("done");
        List<PaymentHistoryDto> paymentHistory = paymentService.getPaymentHistoryForCurrentStudent(); // Service will filter by student
        return ResponseEntity.ok(paymentHistory);
    }
}
