package com.EduPay.controller;

import com.EduPay.dto.AnnouncementDto;
import com.EduPay.dto.BroadcastRequest;
import com.EduPay.service.AnnouncementService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * REST controller for school announcement broadcasts.
 *
 * Admin endpoints:
 *   POST   /api/announcements/broadcast   ← THE MAIN ONE: ALL / CLASS / STUDENT
 *   POST   /api/announcements             ← simple create (no WS push)
 *   PUT    /api/announcements/{id}
 *   DELETE /api/announcements/{id}
 *   GET    /api/announcements             ← all (admin view)
 *
 * Student endpoints:
 *   GET    /api/announcements/my          ← filtered to their class + global
 */
@RestController
@RequestMapping("/api/announcements")
public class AnnouncementController {

    private final AnnouncementService announcementService;

    public AnnouncementController(AnnouncementService announcementService) {
        this.announcementService = announcementService;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // ADMIN: Broadcast (the star feature)
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * Send an alert/info broadcast.
     *
     * Request body example — all students:
     * {
     *   "title":     "Holiday Notice",
     *   "message":   "School will remain closed on 15th April.",
     *   "scopeType": "ALL",
     *   "priority":  "INFO"
     * }
     *
     * Request body example — class-wise:
     * {
     *   "title":     "Class 10 Exam Reminder",
     *   "message":   "Board exams start Monday. Good luck!",
     *   "scopeType": "CLASS",
     *   "standard":  10,
     *   "priority":  "ALERT"
     * }
     *
     * Request body example — student-wise:
     * {
     *   "title":     "Fee Overdue",
     *   "message":   "Your exam fee is overdue. Please pay by Friday.",
     *   "scopeType": "STUDENT",
     *   "studentId": "S042",
     *   "priority":  "URGENT"
     * }
     */
    @PostMapping("/broadcast")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<AnnouncementDto> broadcast(@RequestBody BroadcastRequest request) {
        AnnouncementDto result = announcementService.broadcast(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(result);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // ADMIN: CRUD
    // ─────────────────────────────────────────────────────────────────────────

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<AnnouncementDto> create(@RequestBody AnnouncementDto dto) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(announcementService.createAnnouncement(dto));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<AnnouncementDto> update(@PathVariable Long id,
                                                   @RequestBody AnnouncementDto dto) {
        return ResponseEntity.ok(announcementService.updateAnnouncement(id, dto));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Map<String, String>> delete(@PathVariable Long id) {
        announcementService.deleteAnnouncement(id);
        return ResponseEntity.ok(Map.of("message", "Announcement deleted successfully"));
    }

    /** Admin: see all announcements */
    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'ANALYST', 'VIEWER')")
    public ResponseEntity<List<AnnouncementDto>> getAll() {
        return ResponseEntity.ok(announcementService.getAllAnnouncements());
    }

    // ─────────────────────────────────────────────────────────────────────────
    // STUDENT-FACING
    // ─────────────────────────────────────────────────────────────────────────

    /** Student: see only announcements targeted at them */
    @GetMapping("/my")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<List<AnnouncementDto>> getMy() {
        return ResponseEntity.ok(announcementService.getAnnouncementsForCurrentStudent());
    }
}
