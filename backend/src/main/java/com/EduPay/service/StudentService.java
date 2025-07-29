package com.EduPay.service;

import com.EduPay.dto.AnnouncementDto;
import com.EduPay.dto.FeeDto;
import com.EduPay.dto.PaymentHistoryDto;
import com.EduPay.model.Announcement;
import com.EduPay.model.Fee;
import com.EduPay.model.Payment;
import com.EduPay.model.Student;
import com.EduPay.model.User;
import com.EduPay.repository.AnnouncementRepository;
import com.EduPay.repository.FeeRepository;
import com.EduPay.repository.PaymentRepository;
import com.EduPay.repository.StudentRepository;
import com.EduPay.repository.UserRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

/**
 * Service class for student-specific data retrieval.
 * Handles viewing fees, announcements, and payment history for a student.
 */
@Service
public class StudentService {

    private final StudentRepository studentRepository;
    private final FeeRepository feeRepository;
    private final AnnouncementRepository announcementRepository;
    private final PaymentRepository paymentRepository;
    private final UserRepository userRepository; // To find the student's associated User entity

    public StudentService(StudentRepository studentRepository, FeeRepository feeRepository,
                          AnnouncementRepository announcementRepository, PaymentRepository paymentRepository,
                          UserRepository userRepository) {
        this.studentRepository = studentRepository;
        this.feeRepository = feeRepository;
        this.announcementRepository = announcementRepository;
        this.paymentRepository = paymentRepository;
        this.userRepository = userRepository;
    }

    /**
     * Retrieves all fee records for the currently authenticated student.
     *
     * @return List of FeeDto for the student.
     * @throws RuntimeException if the student's user account is not linked to a student profile.
     */
    public List<FeeDto> getFeesForCurrentStudent() {
        // In a real app, get current user's ID from Spring Security context
        Long currentUserId = 2L; // Placeholder: Replace with actual student User ID from security context

        // Find the Student entity linked to this User
        // Assuming a OneToOne relationship between User (role STUDENT) and Student entity
        User studentUser = userRepository.findById(currentUserId)
                .orElseThrow(() -> new RuntimeException("Student user not found with ID: " + currentUserId));

        // Assuming student's username (name) is used to find the corresponding Student entity
        // Note: The StudentRepository.findByName method is needed for this to work.
        // If not already present, you'll need to add: Optional<Student> findByName(String name); to StudentRepository.java
        Student student = studentRepository.findByName(studentUser.getUsername())
                .orElseThrow(() -> new RuntimeException("Student profile not found for user: " + studentUser.getUsername()));


        List<Fee> fees = feeRepository.findByStudentId(student.getId());
        return fees.stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }

    /**
     * Retrieves all announcements relevant to students.
     * This could include announcements targeted at "All Students" or specific classes/standards.
     *
     * @return List of AnnouncementDto.
     */
    public List<AnnouncementDto> getAnnouncementsForStudents() {
        // Implement logic to filter announcements based on student's standard or target audience "All Students"
        // For now, return all announcements for simplicity
        List<Announcement> announcements = announcementRepository.findAll();
        return announcements.stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }

    /**
     * Retrieves the payment history for the currently authenticated student.
     *
     * @return List of PaymentHistoryDto for the student.
     * @throws RuntimeException if the student's user account is not linked to a student profile.
     */
    public List<PaymentHistoryDto> getPaymentHistoryForCurrentStudent() {
        // In a real app, get current user's ID from Spring Security context
        Long currentUserId = 2L; // Placeholder: Replace with actual student User ID from security context

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

    // --- Helper methods for DTO conversion ---
    private FeeDto convertToDto(Fee fee) {
        return new FeeDto(
                fee.getId(),
                fee.getFeeType(),
                fee.getAmount(),
                fee.getAmountPaid(),
                fee.getOutstandingAmount(),
                fee.getDueDate(),
                fee.getStatus(),
                fee.getStudent() != null ? fee.getStudent().getId() : null
        );
    }

    private AnnouncementDto convertToDto(Announcement announcement) {
        return new AnnouncementDto(
                announcement.getId(),
                announcement.getTitle(),
                announcement.getContent(),
                announcement.getPublishDate(),
                announcement.getTargetAudience(),
                announcement.getCreator() != null ? announcement.getCreator().getId() : null,
                announcement.getCreator() != null ? announcement.getCreator().getUsername() : null
        );
    }

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
