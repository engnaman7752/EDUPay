package com.EduPay.service;

import com.EduPay.config.CustomUserDetails;
import com.EduPay.dto.AnnouncementDto;
import com.EduPay.dto.BroadcastRequest;
import com.EduPay.model.Announcement;
import com.EduPay.model.Notification;
import com.EduPay.model.Student;
import com.EduPay.model.User;
import com.EduPay.repository.AnnouncementRepository;
import com.EduPay.repository.NotificationRepository;
import com.EduPay.repository.StudentRepository;
import com.EduPay.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * Service for managing announcements.
 * Supports three broadcast scopes:
 *   ALL     → every student user
 *   CLASS   → students of a specific standard (1-12)
 *   STUDENT → one specific student by studentId
 *
 * On each broadcast the announcement is:
 *   1. Persisted in the `announcements` table
 *   2. A Notification row created per recipient user
 *   3. Pushed via WebSocket to each recipient's topic
 */
@Service
public class AnnouncementService {

    private static final Logger log = LoggerFactory.getLogger(AnnouncementService.class);

    private final AnnouncementRepository announcementRepository;
    private final UserRepository userRepository;
    private final StudentRepository studentRepository;
    private final NotificationRepository notificationRepository;
    private final SimpMessagingTemplate messagingTemplate;

    public AnnouncementService(AnnouncementRepository announcementRepository,
                               UserRepository userRepository,
                               StudentRepository studentRepository,
                               NotificationRepository notificationRepository,
                               SimpMessagingTemplate messagingTemplate) {
        this.announcementRepository  = announcementRepository;
        this.userRepository          = userRepository;
        this.studentRepository       = studentRepository;
        this.notificationRepository  = notificationRepository;
        this.messagingTemplate       = messagingTemplate;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // BROADCAST  (new primary entrypoint)
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * Broadcasts an alert/info to:
     *   ALL     → every student
     *   CLASS   → students of the given standard
     *   STUDENT → one specific student
     *
     * Also persists the announcement + per-user notifications + WebSocket push.
     */
    @Transactional
    public AnnouncementDto broadcast(BroadcastRequest req) {
        User creator = getCurrentUser();
        String priority  = req.getPriority()  != null ? req.getPriority()  : "INFO";
        String scopeType = req.getScopeType() != null ? req.getScopeType() : "ALL";

        // Build targetAudience string stored in DB
        String targetAudience = buildTargetAudience(scopeType, req.getStandard(), req.getStudentId());

        // Persist Announcement
        Announcement announcement = new Announcement();
        announcement.setTitle(req.getTitle());
        announcement.setContent(req.getMessage());
        announcement.setPublishDate(LocalDateTime.now());
        announcement.setTargetAudience(targetAudience);
        announcement.setCreator(creator);
        Announcement saved = announcementRepository.save(announcement);

        // Resolve recipient users
        List<User> recipients = resolveRecipients(scopeType, req.getStandard(), req.getStudentId());
        log.info("📢 Broadcasting '{}' [{}] → {} recipients", req.getTitle(), scopeType, recipients.size());

        // Push notification to each recipient
        for (User recipient : recipients) {
            persistAndPushNotification(recipient.getId(), req.getTitle(), req.getMessage(), priority, saved.getId());
        }

        return convertToDto(saved);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // CRUD  (admin-only)
    // ─────────────────────────────────────────────────────────────────────────

    @Transactional
    public AnnouncementDto createAnnouncement(AnnouncementDto dto) {
        User creator = getCurrentUser();

        Announcement announcement = new Announcement();
        announcement.setTitle(dto.getTitle());
        announcement.setContent(dto.getContent());
        announcement.setPublishDate(LocalDateTime.now());
        announcement.setTargetAudience(dto.getTargetAudience());
        announcement.setCreator(creator);

        Announcement saved = announcementRepository.save(announcement);
        return convertToDto(saved);
    }

    @Transactional
    public AnnouncementDto updateAnnouncement(Long id, AnnouncementDto dto) {
        Announcement announcement = announcementRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Announcement not found: " + id));
        announcement.setTitle(dto.getTitle());
        announcement.setContent(dto.getContent());
        announcement.setTargetAudience(dto.getTargetAudience());
        return convertToDto(announcementRepository.save(announcement));
    }

    @Transactional
    public void deleteAnnouncement(Long id) {
        if (!announcementRepository.existsById(id)) {
            throw new RuntimeException("Announcement not found: " + id);
        }
        announcementRepository.deleteById(id);
    }

    /** All announcements created by the current admin, newest first. */
    public List<AnnouncementDto> getMyAnnouncements() {
        return announcementRepository
                .findByCreatorId(getCurrentUser().getId())
                .stream()
                .sorted((a, b) -> b.getPublishDate().compareTo(a.getPublishDate()))
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }

    /** All announcements (admin view). */
    public List<AnnouncementDto> getAllAnnouncements() {
        return announcementRepository.findAll()
                .stream()
                .sorted((a, b) -> b.getPublishDate().compareTo(a.getPublishDate()))
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }

    // ─────────────────────────────────────────────────────────────────────────
    // STUDENT-FACING
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * Returns announcements targeted at the current student:
     *   - ALL_STUDENTS global
     *   - CLASS:<standard> (their class)
     *   - STUDENT:<id> (specifically them)
     */
    public List<AnnouncementDto> getAnnouncementsForCurrentStudent() {
        Long currentUserId = getCurrentUserId();
        if (currentUserId == null) {
            return announcementRepository.findByTargetAudience("ALL_STUDENTS")
                    .stream().map(this::convertToDto).collect(Collectors.toList());
        }

        Optional<Student> studentOpt = studentRepository.findByName(
                userRepository.findById(currentUserId)
                        .map(User::getUsername).orElse(""));

        List<String> audiences = new ArrayList<>(Arrays.asList("ALL_STUDENTS", "ALL"));
        studentOpt.ifPresent(s -> {
            audiences.add("CLASS:" + s.getStandard());
            audiences.add("STUDENT:" + s.getId());
        });

        return announcementRepository
                .findByTargetAudienceInOrderByPublishDateDesc(audiences)
                .stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Helpers
    // ─────────────────────────────────────────────────────────────────────────

    private String buildTargetAudience(String scopeType, Integer standard, String studentId) {
        return switch (scopeType.toUpperCase()) {
            case "CLASS"   -> "CLASS:" + standard;
            case "STUDENT" -> {
                Student s = studentRepository.findByStudentId(studentId)
                        .orElseThrow(() -> new RuntimeException("Student not found: " + studentId));
                yield "STUDENT:" + s.getId();
            }
            default -> "ALL_STUDENTS";
        };
    }

    private List<User> resolveRecipients(String scopeType, Integer standard, String studentId) {
        return switch (scopeType.toUpperCase()) {
            case "CLASS" -> {
                List<Student> classStudents = studentRepository.findByStandard(String.valueOf(standard));
                yield classStudents.stream()
                        .map(s -> userRepository.findByUsername(s.getStudentId()).orElse(null))
                        .filter(u -> u != null)
                        .collect(Collectors.toList());
            }
            case "STUDENT" -> {
                Student s = studentRepository.findByStudentId(studentId)
                        .orElseThrow(() -> new RuntimeException("Student not found: " + studentId));
                yield userRepository.findByUsername(s.getStudentId())
                        .map(List::of).orElse(List.of());
            }
            default -> userRepository.findByRole("STUDENT");
        };
    }

    private void persistAndPushNotification(Long userId, String title, String message,
                                            String priority, Long announcementId) {
        String type = priority.equals("URGENT") ? "URGENT_ALERT"
                    : priority.equals("ALERT")  ? "ALERT"
                    : "ANNOUNCEMENT";

        Notification notif = Notification.builder()
                .userId(userId)
                .title(title)
                .message(message)
                .type(type)
                .isRead(false)
                .createdAt(LocalDateTime.now())
                .build();
        notificationRepository.save(notif);

        Map<String, Object> payload = new HashMap<>();
        payload.put("id", notif.getId());
        payload.put("announcementId", announcementId);
        payload.put("title", title);
        payload.put("message", message);
        payload.put("type", type);
        payload.put("priority", priority);
        payload.put("timestamp", notif.getCreatedAt().toString());

        messagingTemplate.convertAndSend("/topic/notifications/" + userId, payload);
        log.debug("📤 Pushed notification to userId={}", userId);
    }

    private User getCurrentUser() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.getPrincipal() instanceof CustomUserDetails details) {
            return userRepository.findById(details.getId())
                    .orElseThrow(() -> new RuntimeException("Admin user not found"));
        }
        throw new RuntimeException("No authenticated user in security context");
    }

    private Long getCurrentUserId() {
        try {
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            if (auth != null && auth.getPrincipal() instanceof CustomUserDetails details) {
                return details.getId();
            }
        } catch (Exception ignored) {}
        return null;
    }

    private AnnouncementDto convertToDto(Announcement a) {
        return new AnnouncementDto(
                a.getId(),
                a.getTitle(),
                a.getContent(),
                a.getPublishDate(),
                a.getTargetAudience(),
                a.getCreator() != null ? a.getCreator().getId() : null,
                a.getCreator() != null ? a.getCreator().getUsername() : null
        );
    }
}
