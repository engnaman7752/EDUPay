package com.EduPay.controller;

import com.EduPay.dto.FeeAssignmentRequest;
import com.EduPay.service.FeeAssignmentService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * REST controller for admin fee assignment and late-fee operations.
 *
 * POST /api/fees/assign
 *   Assign a fee to ALL students / a CLASS / one STUDENT
 *
 * POST /api/fees/apply-late-charge
 *   Apply 1% late fee to all overdue fees (scope: ALL / CLASS / STUDENT)
 */
@RestController
@RequestMapping("/api/fees")
@PreAuthorize("hasRole('ADMIN')")
public class FeeAssignmentController {

    private final FeeAssignmentService feeAssignmentService;

    public FeeAssignmentController(FeeAssignmentService feeAssignmentService) {
        this.feeAssignmentService = feeAssignmentService;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // ASSIGN FEES
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * Assign fees to all students, a class, or a specific student.
     *
     * Example — all students:
     * POST /api/fees/assign
     * { "scopeType":"ALL", "feeType":"Tuition Fee", "amount":18000.0, "dueDate":"2024-05-01" }
     *
     * Example — class-wise:
     * { "scopeType":"CLASS", "standard":"10", "feeType":"Exam Fee", "amount":2500.0, "dueDate":"2024-04-20" }
     *
     * Example — one student:
     * { "scopeType":"STUDENT", "studentId":"S042", "feeType":"Library Fee", "amount":800.0, "dueDate":"2024-05-15" }
     */
    @PostMapping("/assign")
    public ResponseEntity<Map<String, Object>> assignFees(@RequestBody FeeAssignmentRequest request) {
        Map<String, Object> result = feeAssignmentService.assignFees(request);
        return ResponseEntity.ok(result);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // LATE FEE (1%)
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * Apply 1% late charge on all overdue fees.
     *
     * Query params (all optional, default = ALL):
     *   ?scopeType=ALL               → all overdue fees school-wide
     *   ?scopeType=CLASS&standard=10 → only Class 10 overdue fees
     *   ?scopeType=STUDENT&studentId=S042 → only that student's overdue fees
     *
     * Response: { "processed": 23, "totalLateCharge": 456.50, "rateApplied": "1%", "scope": "ALL" }
     */
    @PostMapping("/apply-late-charge")
    public ResponseEntity<Map<String, Object>> applyLateCharge(
            @RequestParam(defaultValue = "ALL")  String scopeType,
            @RequestParam(required = false)       String standard,
            @RequestParam(required = false)       String studentId) {
        Map<String, Object> result = feeAssignmentService.applyLateCharge(scopeType, standard, studentId);
        return ResponseEntity.ok(result);
    }
}
