package com.EduPay.dto;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

/**
 * Request DTO for admin broadcast alerts.
 *
 * scopeType values:
 *   ALL          - send to all students
 *   CLASS        - send to all students in a given class/standard (1-12)
 *   STUDENT      - send to one specific student by their student ID string
 *
 * priority values: INFO | ALERT | URGENT
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class BroadcastRequest {

    /** Required: short headline */
    private String title;

    /** Required: full message body */
    private String message;

    /**
     * Scope of the broadcast:
     *   ALL | CLASS | STUDENT
     */
    private String scopeType;

    /**
     * Required when scopeType = CLASS.
     * Integer 1–12 representing the class standard.
     */
    private Integer standard;

    /**
     * Required when scopeType = STUDENT.
     * The student's unique studentId string (e.g. "S001").
     */
    private String studentId;

    /** INFO | ALERT | URGENT  (default INFO if null) */
    private String priority;
}
