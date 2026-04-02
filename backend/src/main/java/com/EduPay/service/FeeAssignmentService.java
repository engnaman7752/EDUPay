package com.EduPay.service;

import com.EduPay.dto.FeeAssignmentRequest;
import com.EduPay.model.Fee;
import com.EduPay.model.Student;
import com.EduPay.repository.FeeRepository;
import com.EduPay.repository.StudentRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

/**
 * Service for bulk fee assignment and late-fee penalty application.
 *
 * Supports three scopes: ALL | CLASS | STUDENT
 * Late fee: 1% of outstanding amount added to amount + outstanding (compounding-friendly)
 */
@Service
public class FeeAssignmentService {

    private static final Logger log = LoggerFactory.getLogger(FeeAssignmentService.class);
    private static final double LATE_FEE_RATE = 0.01; // 1%

    private final FeeRepository feeRepository;
    private final StudentRepository studentRepository;

    public FeeAssignmentService(FeeRepository feeRepository,
                                StudentRepository studentRepository) {
        this.feeRepository   = feeRepository;
        this.studentRepository = studentRepository;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // ASSIGN FEES
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * Assigns a fee entry to the resolved set of students.
     * Returns a summary map: { "assigned": N, "skipped": 0 }
     */
    @Transactional
    public Map<String, Object> assignFees(FeeAssignmentRequest req) {
        validate(req);

        List<Student> targets = resolveStudents(req.getScopeType(), req.getStandard(), req.getStudentId());
        log.info("💸 Assigning '{}' ₹{} → {} student(s) [scope={}]",
                req.getFeeType(), req.getAmount(), targets.size(), req.getScopeType());

        for (Student student : targets) {
            Fee fee = new Fee();
            fee.setStudent(student);
            fee.setFeeType(req.getFeeType());
            fee.setAmount(req.getAmount());
            fee.setAmountPaid(0.0);
            fee.setOutstandingAmount(req.getAmount());
            fee.setDueDate(req.getDueDate());
            fee.setStatus("Pending");
            feeRepository.save(fee);
        }

        return Map.of(
                "assigned", targets.size(),
                "feeType",  req.getFeeType(),
                "amount",   req.getAmount(),
                "dueDate",  req.getDueDate().toString(),
                "scope",    req.getScopeType()
        );
    }

    // ─────────────────────────────────────────────────────────────────────────
    // APPLY LATE FEE (1%)
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * Finds all fees past their dueDate (with outstanding > 0) and adds 1%
     * of the outstanding amount as a late charge.
     *
     * Scope: ALL | CLASS | STUDENT
     * Returns summary: { "processed": N, "totalLateCharge": X }
     */
    @Transactional
    public Map<String, Object> applyLateCharge(String scopeType, String standard, String studentId) {
        LocalDate today = LocalDate.now();
        List<Fee> overdueFees = resolveOverdueFees(
                scopeType != null ? scopeType : "ALL",
                standard, studentId, today);

        double totalCharge = 0.0;
        int processed = 0;

        for (Fee fee : overdueFees) {
            double outstanding = fee.getOutstandingAmount();
            double charge = Math.round(outstanding * LATE_FEE_RATE * 100.0) / 100.0; // round to 2 dp

            // Add 1% to the total amount and outstanding
            fee.setAmount(fee.getAmount() + charge);
            fee.setOutstandingAmount(outstanding + charge);
            fee.setStatus("Overdue"); // ensure status reflects overdue state
            feeRepository.save(fee);

            totalCharge += charge;
            processed++;
            log.debug("⚠️ Late charge ₹{} added to feeId={} (student={})",
                    charge, fee.getId(), fee.getStudent().getStudentId());
        }

        log.info("⚠️ Late fee applied to {} fees | total charge added: ₹{}", processed, totalCharge);
        return Map.of(
                "processed",       processed,
                "totalLateCharge", Math.round(totalCharge * 100.0) / 100.0,
                "rateApplied",     "1%",
                "scope",           scopeType != null ? scopeType : "ALL"
        );
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Helpers
    // ─────────────────────────────────────────────────────────────────────────

    private List<Student> resolveStudents(String scopeType, String standard, String studentId) {
        return switch (scopeType.toUpperCase()) {
            case "CLASS"   -> studentRepository.findByStandard(standard);
            case "STUDENT" -> List.of(
                    studentRepository.findByStudentId(studentId)
                            .orElseThrow(() -> new RuntimeException("Student not found: " + studentId))
            );
            default -> studentRepository.findAll(); // ALL
        };
    }

    private List<Fee> resolveOverdueFees(String scopeType, String standard,
                                         String studentId, LocalDate today) {
        return switch (scopeType.toUpperCase()) {
            case "CLASS" -> feeRepository.findOverdueFeesByStandard(standard, today);
            case "STUDENT" -> {
                Student s = studentRepository.findByStudentId(studentId)
                        .orElseThrow(() -> new RuntimeException("Student not found: " + studentId));
                yield feeRepository.findOverdueFeesByStudent(s.getId(), today);
            }
            default -> feeRepository.findOverdueFees(today); // ALL
        };
    }

    private void validate(FeeAssignmentRequest req) {
        if (req.getFeeType() == null || req.getFeeType().isBlank())
            throw new IllegalArgumentException("feeType is required");
        if (req.getAmount() == null || req.getAmount() <= 0)
            throw new IllegalArgumentException("amount must be greater than 0");
        if (req.getDueDate() == null)
            throw new IllegalArgumentException("dueDate is required");
        if ("CLASS".equalsIgnoreCase(req.getScopeType()) &&
                (req.getStandard() == null || req.getStandard().isBlank()))
            throw new IllegalArgumentException("standard is required when scopeType=CLASS");
        if ("STUDENT".equalsIgnoreCase(req.getScopeType()) &&
                (req.getStudentId() == null || req.getStudentId().isBlank()))
            throw new IllegalArgumentException("studentId is required when scopeType=STUDENT");
    }
}
