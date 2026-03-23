package com.EduPay.controller;

import com.EduPay.model.Notification;
import com.EduPay.model.User;
import com.EduPay.repository.NotificationRepository;
import com.EduPay.repository.UserRepository;
import com.EduPay.service.NotificationService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * REST controller for notification management.
 *
 * GET  /api/notifications        — Fetch current user's notifications
 * GET  /api/notifications/unread — Get unread count
 * PUT  /api/notifications/{id}/read — Mark a notification as read
 * POST /api/admin/notifications/trigger — Admin triggers fee reminders
 */
@RestController
public class NotificationController {

    private final NotificationRepository notificationRepository;
    private final NotificationService notificationService;
    private final UserRepository userRepository;

    public NotificationController(NotificationRepository notificationRepository,
                                  NotificationService notificationService,
                                  UserRepository userRepository) {
        this.notificationRepository = notificationRepository;
        this.notificationService = notificationService;
        this.userRepository = userRepository;
    }

    /**
     * Get all notifications for the authenticated user.
     */
    @GetMapping("/api/notifications")
    public ResponseEntity<List<Notification>> getNotifications(Authentication authentication) {
        Long userId = getUserId(authentication);
        if (userId == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(
                notificationRepository.findByUserIdOrderByCreatedAtDesc(userId));
    }

    /**
     * Get the count of unread notifications for the authenticated user.
     */
    @GetMapping("/api/notifications/unread")
    public ResponseEntity<Map<String, Long>> getUnreadCount(Authentication authentication) {
        Long userId = getUserId(authentication);
        if (userId == null) {
            return ResponseEntity.notFound().build();
        }
        long count = notificationRepository.countByUserIdAndIsReadFalse(userId);
        return ResponseEntity.ok(Map.of("count", count));
    }

    /**
     * Mark a notification as read.
     */
    @PutMapping("/api/notifications/{id}/read")
    public ResponseEntity<Void> markAsRead(@PathVariable Long id, Authentication authentication) {
        Long userId = getUserId(authentication);
        Optional<Notification> notifOpt = notificationRepository.findById(id);

        if (notifOpt.isEmpty() || !notifOpt.get().getUserId().equals(userId)) {
            return ResponseEntity.notFound().build();
        }

        Notification notification = notifOpt.get();
        notification.setIsRead(true);
        notificationRepository.save(notification);
        return ResponseEntity.ok().build();
    }

    /**
     * Admin endpoint: trigger AI-generated fee reminders for all students
     * with pending fees. Sends real-time WebSocket notifications.
     */
    @PostMapping("/api/admin/notifications/trigger")
    public ResponseEntity<Map<String, String>> triggerReminders() {
        notificationService.triggerRemindersForAllPending();
        return ResponseEntity.ok(Map.of(
                "status", "success",
                "message", "Fee reminders are being generated and sent"));
    }

    /**
     * Helper: resolve the user ID from the authenticated principal.
     */
    private Long getUserId(Authentication authentication) {
        String username = authentication.getName();
        return userRepository.findByUsername(username)
                .map(User::getId)
                .orElse(null);
    }
}
