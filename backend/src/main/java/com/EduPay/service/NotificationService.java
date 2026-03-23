package com.EduPay.service;

import com.EduPay.model.Fee;
import com.EduPay.model.Notification;
import com.EduPay.model.Student;
import com.EduPay.model.User;
import com.EduPay.repository.FeeRepository;
import com.EduPay.repository.NotificationRepository;
import com.EduPay.repository.StudentRepository;
import com.EduPay.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Service for sending real-time WebSocket notifications.
 * Uses GenAI to draft personalized, polite fee reminders.
 * Pushes notifications instantly via STOMP WebSocket.
 */
@Service
public class NotificationService {

    private static final Logger log = LoggerFactory.getLogger(NotificationService.class);

    private final SimpMessagingTemplate messagingTemplate;
    private final ChatClient chatClient;
    private final StudentRepository studentRepository;
    private final FeeRepository feeRepository;
    private final UserRepository userRepository;
    private final NotificationRepository notificationRepository;

    public NotificationService(SimpMessagingTemplate messagingTemplate,
                               ChatClient chatClient,
                               StudentRepository studentRepository,
                               FeeRepository feeRepository,
                               UserRepository userRepository,
                               NotificationRepository notificationRepository) {
        this.messagingTemplate = messagingTemplate;
        this.chatClient = chatClient;
        this.studentRepository = studentRepository;
        this.feeRepository = feeRepository;
        this.userRepository = userRepository;
        this.notificationRepository = notificationRepository;
    }

    /**
     * Scheduled task: checks for pending fees and sends AI-drafted reminders.
     * Runs based on the cron expression in application.yml.
     */
    @Scheduled(cron = "${edupay.notification.cron}")
    public void checkAndSendFeeReminders() {
        log.info("🔔 Running scheduled fee reminder check...");
        List<Student> allStudents = studentRepository.findAll();

        for (Student student : allStudents) {
            List<Fee> pendingFees = feeRepository.findByStudent(student).stream()
                    .filter(fee -> fee.getOutstandingAmount() > 0)
                    .toList();

            if (!pendingFees.isEmpty()) {
                sendAIGeneratedReminder(student, pendingFees);
            }
        }
    }

    /**
     * Manually trigger reminder generation for all students with pending fees.
     * Called by admin via NotificationController.
     */
    public void triggerRemindersForAllPending() {
        checkAndSendFeeReminders();
    }

    /**
     * Generate and send an AI-drafted personalized fee reminder.
     */
    private void sendAIGeneratedReminder(Student student, List<Fee> pendingFees) {
        try {
            // Build fee summary for prompt
            double totalOutstanding = pendingFees.stream()
                    .mapToDouble(Fee::getOutstandingAmount)
                    .sum();

            StringBuilder feeSummary = new StringBuilder();
            for (Fee fee : pendingFees) {
                feeSummary.append(String.format("- %s: ₹%.2f due by %s%n",
                        fee.getFeeType(), fee.getOutstandingAmount(), fee.getDueDate()));
            }

            // Use AI to draft a polite, personalized reminder
            String prompt = String.format("""
                    Draft a polite, empathetic, and professional fee payment reminder message.
                    Keep it concise (2-3 sentences max).
                    
                    Student Name: %s
                    Class: %s
                    Total Outstanding: ₹%.2f
                    Fee Details:
                    %s
                    
                    The message should:
                    - Address the parent respectfully
                    - Mention the outstanding amount
                    - Be encouraging, not threatening
                    - Suggest early payment benefits if applicable
                    """,
                    student.getName(), student.getStandard(),
                    totalOutstanding, feeSummary.toString());

            String aiMessage;
            try {
                aiMessage = chatClient.prompt()
                        .user(prompt)
                        .call()
                        .content();
            } catch (Exception e) {
                // Fallback to template message if AI is unavailable
                aiMessage = String.format(
                        "Dear Parent, this is a friendly reminder that ₹%.2f in fees is pending for %s (Class %s). " +
                                "Please complete the payment at your earliest convenience. Thank you!",
                        totalOutstanding, student.getName(), student.getStandard());
                log.warn("AI unavailable for reminder generation, using template: {}", e.getMessage());
            }

            // Also generate an AI insight
            String insightPrompt = String.format("""
                    Based on the following fee data, generate ONE short financial insight or tip (1 sentence).
                    Total Outstanding: ₹%.2f
                    Earliest Due Date: %s
                    Number of pending fees: %d
                    
                    Example: "Paying before [date] could help you avoid a late fee surcharge."
                    """,
                    totalOutstanding,
                    pendingFees.stream().map(Fee::getDueDate).min(LocalDate::compareTo).orElse(LocalDate.now()),
                    pendingFees.size());

            String aiInsight;
            try {
                aiInsight = chatClient.prompt()
                        .user(insightPrompt)
                        .call()
                        .content();
            } catch (Exception e) {
                aiInsight = String.format("Early payment could save you from late fee charges. Due date: %s",
                        pendingFees.stream().map(Fee::getDueDate).min(LocalDate::compareTo).orElse(LocalDate.now()));
            }

            // Find the user account linked to this student (via admin or student's own account)
            Long userId = findUserIdForStudent(student);
            if (userId == null) {
                log.warn("No user account found for student: {}", student.getStudentId());
                return;
            }

            // Save notification to DB
            Notification notification = Notification.builder()
                    .userId(userId)
                    .title("Fee Payment Reminder")
                    .message(aiMessage)
                    .type("FEE_REMINDER")
                    .isRead(false)
                    .createdAt(LocalDateTime.now())
                    .build();
            notificationRepository.save(notification);

            // Build WebSocket payload
            Map<String, Object> wsPayload = new HashMap<>();
            wsPayload.put("id", notification.getId());
            wsPayload.put("title", notification.getTitle());
            wsPayload.put("message", aiMessage);
            wsPayload.put("type", "FEE_REMINDER");
            wsPayload.put("insight", aiInsight);
            wsPayload.put("totalOutstanding", totalOutstanding);
            wsPayload.put("timestamp", notification.getCreatedAt().toString());

            // Push via WebSocket to the specific user's topic
            messagingTemplate.convertAndSend(
                    "/topic/notifications/" + userId, wsPayload);

            log.info("📤 Sent AI reminder to student {} (userId: {})", student.getStudentId(), userId);

        } catch (Exception e) {
            log.error("❌ Failed to send reminder for student {}: {}",
                    student.getStudentId(), e.getMessage(), e);
        }
    }

    /**
     * Send a custom notification to a specific user via WebSocket.
     */
    public void sendNotification(Long userId, String title, String message, String type) {
        Notification notification = Notification.builder()
                .userId(userId)
                .title(title)
                .message(message)
                .type(type)
                .isRead(false)
                .createdAt(LocalDateTime.now())
                .build();
        notificationRepository.save(notification);

        Map<String, Object> wsPayload = new HashMap<>();
        wsPayload.put("id", notification.getId());
        wsPayload.put("title", title);
        wsPayload.put("message", message);
        wsPayload.put("type", type);
        wsPayload.put("timestamp", notification.getCreatedAt().toString());

        messagingTemplate.convertAndSend("/topic/notifications/" + userId, wsPayload);
    }

    /**
     * Find the user ID associated with a student.
     * Tries to match by studentId -> username in users table.
     */
    private Long findUserIdForStudent(Student student) {
        return userRepository.findByUsername(student.getStudentId())
                .map(User::getId)
                .orElse(null);
    }
}
