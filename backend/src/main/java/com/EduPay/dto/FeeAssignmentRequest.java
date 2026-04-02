package com.EduPay.dto;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDate;

/**
 * Request DTO for assigning fees to students.
 *
 * scopeType:
 *   ALL     — assign to every student
 *   CLASS   — assign to all students of a given standard (e.g. "10")
 *   STUDENT — assign to one specific student by studentId string
 *
 * For late fee application, use the dedicated
 *   POST /api/fees/apply-late-charge endpoint
 *   (no body fields required — applies 1% to all overdue fees automatically)
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class FeeAssignmentRequest {

    // ─── Scope ────────────────────────────────────────────────
    /** ALL | CLASS | STUDENT */
    private String scopeType;

    /** Standard as string e.g. "10" — required when scopeType = CLASS */
    private String standard;

    /** Student's unique ID e.g. "S042" — required when scopeType = STUDENT */
    private String studentId;

    // ─── Fee details ───────────────────────────────────────────
    /** e.g. "Tuition Fee", "Exam Fee", "Library Fee", "Transport Fee" */
    private String feeType;

    /** Fee amount per student (must be > 0) */
    private Double amount;

    /** Due date for payment */
    private LocalDate dueDate;
}
