package com.EduPay.service;

import com.EduPay.dto.FeeDto;
import com.EduPay.dto.StudentDto;
import com.EduPay.model.Fee;
import com.EduPay.model.Payment;
import com.EduPay.model.Student;
import com.EduPay.model.User;
import com.EduPay.repository.FeeRepository;
import com.EduPay.repository.PaymentRepository;
import com.EduPay.repository.StudentRepository;
import com.EduPay.repository.UserRepository;
// import org.springframework.boot.autoconfigure.security.SecurityProperties; // This import is unused and can be removed
import org.springframework.security.crypto.password.PasswordEncoder; // Import PasswordEncoder
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional; // For transactional operations

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;


@Service
public class AdminService {

    private final StudentRepository studentRepository;
    private final FeeRepository feeRepository;
    private final PaymentRepository paymentRepository;
    private final UserRepository userRepository; // To fetch admin user for linking
    private final PasswordEncoder passwordEncoder; // Inject PasswordEncoder

    public AdminService(StudentRepository studentRepository, FeeRepository feeRepository,
                        PaymentRepository paymentRepository, UserRepository userRepository,
                        PasswordEncoder passwordEncoder) { // Add PasswordEncoder to constructor
        this.studentRepository = studentRepository;
        this.feeRepository = feeRepository;
        this.paymentRepository = paymentRepository;
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder; // Initialize PasswordEncoder
    }

    // --- Student Management ---

    @Transactional
    public StudentDto addStudent(StudentDto studentDto) {
        // In a real app, get adminId from Spring Security context
        // For now, let's use a placeholder admin for demonstration
        Long currentAdminId = 1L; // Placeholder: Replace with actual admin ID from security context

        // Corrected: Unwrap the Optional to get the User object
        User admin = userRepository.findById(currentAdminId)
                .orElseThrow(() -> new RuntimeException("Admin not found with ID: " + currentAdminId));

        if (studentRepository.findByStudentId(studentDto.getStudentId()).isPresent()) {
            throw new RuntimeException("Student with ID " + studentDto.getStudentId() + " already exists.");
        }
        if (studentRepository.findByRollNo(studentDto.getRollNo()).isPresent()) {
            throw new RuntimeException("Student with Roll No " + studentDto.getRollNo() + " already exists.");
        }


        // For simplicity, let's assume student name is the unique username for students.
        if (userRepository.findByUsername(studentDto.getName()).isPresent()) {
            throw new RuntimeException("A user with the student name '" + studentDto.getName() + "' already exists.");
        }

        // Create new Student entity
        Student student = new Student();
        student.setStudentId(studentDto.getStudentId());
        student.setName(studentDto.getName());
        student.setRollNo(studentDto.getRollNo());
        student.setMobileNo(studentDto.getMobileNo());
        student.setStandard(studentDto.getStandard());
        student.setAdmin(admin); // Link to the admin (now a User object)

        Student savedStudent = studentRepository.save(student);

        // Create a corresponding User entity for the student
        User studentUser = new User();
        studentUser.setUsername(studentDto.getName()); // Student's name is the username
        // Corrected: Hash the mobile number to be the password
        studentUser.setPassword(passwordEncoder.encode(studentDto.getMobileNo()));
        studentUser.setRole("STUDENT"); // Set role to STUDENT
        userRepository.save(studentUser);


        return convertToDto(savedStudent);
    }


    public List<StudentDto> getAllStudentsForAdmin() {
        // In a real app, get adminId from Spring Security context
        Long currentAdminId = 1L; // Placeholder: Replace with actual admin ID from security context

        List<Student> students = studentRepository.findByAdminId(currentAdminId);
        return students.stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }


    public StudentDto getStudentById(Long id) {
        Student student = studentRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Student not found with ID: " + id));
        return convertToDto(student);
    }


    @Transactional
    public StudentDto updateStudent(Long id, StudentDto studentDto) {
        Student student = studentRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Student not found with ID: " + id));

        student.setName(studentDto.getName());
        student.setRollNo(studentDto.getRollNo());
        student.setMobileNo(studentDto.getMobileNo());
        student.setStandard(studentDto.getStandard());
        // Do not update studentId or admin here, as they are typically fixed or managed separately.

        // If mobile number (password) or name (username) changes, update the User entity as well
        User studentUser = userRepository.findByUsername(student.getName()) // Find user by old name
                .orElseThrow(() -> new RuntimeException("Corresponding user not found for student: " + student.getName()));

        studentUser.setUsername(studentDto.getName()); // Update username to new student name
        // Corrected: Hash the new mobile number to be the password
        studentUser.setPassword(passwordEncoder.encode(studentDto.getMobileNo()));
        userRepository.save(studentUser);


        Student updatedStudent = studentRepository.save(student);
        return convertToDto(updatedStudent);
    }


    @Transactional
    public void deleteStudent(Long id) {
        Student student = studentRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Student not found with ID: " + id));

        // Delete the corresponding User entity for the student
        userRepository.findByUsername(student.getName()).ifPresent(userRepository::delete);

        studentRepository.deleteById(id);
    }

    // --- Fee Management ---


    @Transactional
    public FeeDto addFee(FeeDto feeDto) {
        Student student = studentRepository.findById(feeDto.getStudentId())
                .orElseThrow(() -> new RuntimeException("Student not found with ID: " + feeDto.getStudentId()));

        Fee fee = new Fee();
        fee.setFeeType(feeDto.getFeeType());
        fee.setAmount(feeDto.getAmount());
        fee.setAmountPaid(0.0); // Initially no amount paid
        fee.setOutstandingAmount(feeDto.getAmount()); // Initially outstanding is full amount
        fee.setDueDate(feeDto.getDueDate());
        fee.setStatus("Pending"); // Initial status
        fee.setStudent(student);

        Fee savedFee = feeRepository.save(fee);
        return convertToDto(savedFee);
    }


    @Transactional
    public FeeDto updateFeeStatus(Long feeId, String status) {
        Fee fee = feeRepository.findById(feeId)
                .orElseThrow(() -> new RuntimeException("Fee not found with ID: " + feeId));

        fee.setStatus(status);
        Fee updatedFee = feeRepository.save(fee);
        return convertToDto(updatedFee);
    }


    @Transactional
    public FeeDto recordCashPayment(Long studentId, Long feeId, Double amount) {
        Student student = studentRepository.findById(studentId)
                .orElseThrow(() -> new RuntimeException("Student not found with ID: " + studentId));

        Fee fee = feeRepository.findById(feeId)
                .orElseThrow(() -> new RuntimeException("Fee not found with ID: " + feeId));

        // Ensure the fee belongs to the correct student (multi-tenancy check)
        if (!fee.getStudent().getId().equals(studentId)) {
            throw new RuntimeException("Fee does not belong to the specified student.");
        }

        if (amount <= 0) {
            throw new RuntimeException("Payment amount must be positive.");
        }

        if (amount > fee.getOutstandingAmount()) {
            throw new RuntimeException("Payment amount exceeds outstanding amount for this fee.");
        }

        // Update fee details
        fee.setAmountPaid(fee.getAmountPaid() + amount);
        fee.setOutstandingAmount(fee.getOutstandingAmount() - amount);

        if (fee.getOutstandingAmount() <= 0) {
            fee.setStatus("Paid");
        } else {
            fee.setStatus("Partially Paid");
        }
        Fee updatedFee = feeRepository.save(fee);

        // Create a new Payment record for the cash deposit
        Payment payment = new Payment();
        payment.setTransactionId("CASH-" + System.currentTimeMillis()); // Simple unique ID for cash
        payment.setAmount(amount);
        payment.setPaymentMethod("Cash");
        payment.setPaymentDate(LocalDateTime.now());
        payment.setStatus("Success");
        payment.setStudent(student);

        // In a real app, get adminId from Spring Security context
        Long currentAdminId = 1L; // Placeholder: Replace with actual admin ID from security context
        User recordedByAdmin = userRepository.findById(currentAdminId)
                .orElseThrow(() -> new RuntimeException("Admin user not found for recording cash payment."));
        payment.setRecordedBy(recordedByAdmin);

        paymentRepository.save(payment);

        return convertToDto(updatedFee);
    }

    // --- Helper methods for DTO conversion ---
    private StudentDto convertToDto(Student student) {
        return new StudentDto(
                student.getId(),
                student.getStudentId(),
                student.getName(),
                student.getRollNo(),
                student.getMobileNo(),
                student.getStandard()
        );
    }

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
