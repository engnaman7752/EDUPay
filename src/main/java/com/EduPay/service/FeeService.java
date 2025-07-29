package com.EduPay.service;

import com.EduPay.dto.FeeDto;
import com.EduPay.model.Fee;
import com.EduPay.model.Student;
import com.EduPay.repository.FeeRepository;
import com.EduPay.repository.StudentRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * Service class for managing fee-related operations, primarily for students.
 * Handles retrieval of fee status for students.
 */
@Service
public class FeeService {

    private final FeeRepository feeRepository;
    private final StudentRepository studentRepository; // Needed to link fees to students

    public FeeService(FeeRepository feeRepository, StudentRepository studentRepository) {
        this.feeRepository = feeRepository;
        this.studentRepository = studentRepository;
    }

    /**
     * Retrieves all fee records for a specific student.
     * This method is typically called by the StudentController.
     *
     * @param studentId The ID of the student whose fees are to be retrieved.
     * @return A list of FeeDto for the specified student.
     * @throws RuntimeException if the student is not found.
     */
    public List<FeeDto> getFeesByStudentId(Long studentId) {
        // Ensure the student exists before fetching fees
        if (!studentRepository.existsById(studentId)) {
            throw new RuntimeException("Student not found with ID: " + studentId);
        }

        List<Fee> fees = feeRepository.findByStudentId(studentId);
        return fees.stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }

    /**
     * Retrieves the fee status for the currently authenticated student.
     * This method assumes that the student's ID can be derived from the
     * authenticated user's context (e.g., from a User entity linked to a Student).
     *
     * @return List of FeeDto for the current student.
     * @throws RuntimeException if the student profile cannot be determined from the current user.
     */
    public List<FeeDto> getFeesForCurrentStudent() {
        // Placeholder for getting the current student's ID from the security context.
        // In a real application, you would get this from Spring Security's Authentication object.
        // Example: Long currentUserId = ((User) SecurityContextHolder.getContext().getAuthentication().getPrincipal()).getId();
        // Then, find the Student entity associated with this User.
        // For demonstration, let's use a mock student ID or assume it's passed from a higher layer.
        Long currentStudentId = 1L; // Example: Replace with actual logic to get current student's ID

        return getFeesByStudentId(currentStudentId);
    }

    // --- Helper method for DTO conversion ---
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
}
