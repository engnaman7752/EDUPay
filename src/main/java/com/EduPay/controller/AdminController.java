package com.EduPay.controller;

import com.EduPay.dto.AnnouncementDto;
import com.EduPay.dto.CashDepositRequest;
import com.EduPay.dto.FeeDto;
import com.EduPay.dto.StudentDto;
import com.EduPay.service.AdminService;
import com.EduPay.service.AnnouncementService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin")
public class AdminController {

    private final AdminService adminService; // Service for student and fee management
    private final AnnouncementService announcementService; // Service for announcement management

    // Constructor for dependency injection
    public AdminController(AdminService adminService, AnnouncementService announcementService) {
        this.adminService = adminService;
        this.announcementService = announcementService;
    }

    // --- Student Management Endpoints ---


    @PostMapping("/students")
    public ResponseEntity<StudentDto> addStudent(@RequestBody StudentDto studentDto) {

        StudentDto createdStudent = adminService.addStudent(studentDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdStudent);
    }


    @GetMapping("/students")
    public ResponseEntity<List<StudentDto>> getAllStudents() {

        List<StudentDto> students = adminService.getAllStudentsForAdmin(); // Service will filter by admin
        return ResponseEntity.ok(students);
    }


    @GetMapping("/students/{id}")
    public ResponseEntity<StudentDto> getStudentById(@PathVariable Long id) {
        StudentDto student = adminService.getStudentById(id);
        return ResponseEntity.ok(student);
    }


    @PutMapping("/students/{id}")
    public ResponseEntity<StudentDto> updateStudent(@PathVariable Long id, @RequestBody StudentDto studentDto) {
        StudentDto updatedStudent = adminService.updateStudent(id, studentDto);
        return ResponseEntity.ok(updatedStudent);
    }


    @DeleteMapping("/students/{id}")
    public ResponseEntity<Void> deleteStudent(@PathVariable Long id) {
        adminService.deleteStudent(id);
        return ResponseEntity.noContent().build(); // 204 No Content
    }

    // --- Fee Management Endpoints ---


    @PostMapping("/fees")
    public ResponseEntity<FeeDto> addFee(@RequestBody FeeDto feeDto) {
        FeeDto createdFee = adminService.addFee(feeDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdFee);
    }


    @PutMapping("/fees/{feeId}/status")
    public ResponseEntity<FeeDto> updateFeeStatus(@PathVariable Long feeId, @RequestParam String status) {
        FeeDto updatedFee = adminService.updateFeeStatus(feeId, status);
        return ResponseEntity.ok(updatedFee);
    }


    @PostMapping("/fees/cash-deposit")
    public ResponseEntity<?> recordCashDeposit(@RequestBody CashDepositRequest cashDepositRequest) {
        try {
            FeeDto updatedFee = adminService.recordCashPayment(
                    cashDepositRequest.getStudentId(),
                    cashDepositRequest.getFeeId(),
                    cashDepositRequest.getAmount()
            );
            return ResponseEntity.ok(updatedFee); // Or a custom DTO combining fee and payment info
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }

    // --- Announcement Management Endpoints ---


    @PostMapping("/announcements")
    public ResponseEntity<AnnouncementDto> createAnnouncement(@RequestBody AnnouncementDto announcementDto) {
        // Get current admin's ID from security context for the creator field
        // Long adminId = SecurityContextHolder.getContext().getAuthentication().getPrincipal().getId();
        AnnouncementDto createdAnnouncement = announcementService.createAnnouncement(announcementDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdAnnouncement);
    }



    @PutMapping("/announcements/{id}")
    public ResponseEntity<AnnouncementDto> updateAnnouncement(@PathVariable Long id, @RequestBody AnnouncementDto announcementDto) {
        AnnouncementDto updatedAnnouncement = announcementService.updateAnnouncement(id, announcementDto);
        return ResponseEntity.ok(updatedAnnouncement);
    }


    @DeleteMapping("/announcements/{id}")
    public ResponseEntity<Void> deleteAnnouncement(@PathVariable Long id) {
        announcementService.deleteAnnouncement(id);
        return ResponseEntity.noContent().build(); // 204 No Content
    }
    @GetMapping("/announcements/my-announcements")
    public ResponseEntity<List<AnnouncementDto>> getMyAnnouncements() {
        // Get current admin's ID from security context
        // Long adminId = SecurityContextHolder.getContext().getAuthentication().getPrincipal().getId();
        List<AnnouncementDto> announcements = announcementService.getAnnouncementsByCreator(); // Service will filter by admin
        return ResponseEntity.ok(announcements);
    }
}
