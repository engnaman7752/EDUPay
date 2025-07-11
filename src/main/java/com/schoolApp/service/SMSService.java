package com.schoolApp.service;

import com.schoolApp.config.TwilioConfig;
import com.schoolApp.dto.FeeDto;
import com.schoolApp.dto.SMSDto;
import com.schoolApp.exception.SMSException;
import com.twilio.rest.api.v2010.account.Message;
import com.twilio.type.PhoneNumber;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.concurrent.CompletableFuture;

@Service
@RequiredArgsConstructor
@Slf4j
public class SMSService {

    private final TwilioConfig twilioConfig;
    private final FeeService feeService;

    @Value("${app.sms.enabled:true}")
    private boolean smsEnabled;

    @Value("${app.school.name:Our School}")
    private String schoolName;

    public void sendFeeReminder(FeeDto fee) {
        if (!smsEnabled) {
            log.info("SMS service is disabled, skipping fee reminder for fee ID: {}", fee.getId());
            return;
        }

        try {
            String message = buildFeeReminderMessage(fee);
            sendSMS(fee.getStudent().getPhoneNumber(), message);

            // Mark SMS as sent
            feeService.markSMSSent(fee.getId());

            log.info("Fee reminder SMS sent successfully for fee ID: {}", fee.getId());
        } catch (Exception e) {
            log.error("Failed to send fee reminder SMS for fee ID: {}", fee.getId(), e);
            throw new SMSException("Failed to send fee reminder SMS", e);
        }
    }

    public void sendBulkFeeReminders(List<FeeDto> fees) {
        if (!smsEnabled) {
            log.info("SMS service is disabled, skipping bulk fee reminders");
            return;
        }

        log.info("Sending bulk fee reminders to {} students", fees.size());

        List<CompletableFuture<Void>> futures = fees.stream()
                .map(fee -> CompletableFuture.runAsync(() -> {
                    try {
                        sendFeeReminder(fee);
                    } catch (Exception e) {
                        log.error("Failed to send bulk fee reminder for fee ID: {}", fee.getId(), e);
                    }
                }))
                .toList();

        CompletableFuture.allOf(futures.toArray(new CompletableFuture[0]))
                .thenRun(() -> log.info("Completed sending bulk fee reminders"));
    }

    public void sendCustomSMS(SMSDto smsDto) {
        if (!smsEnabled) {
            log.info("SMS service is disabled, skipping custom SMS");
            return;
        }

        try {
            sendSMS(smsDto.getPhoneNumber(), smsDto.getMessage());
            log.info("Custom SMS sent successfully to: {}", smsDto.getPhoneNumber());
        } catch (Exception e) {
            log.error("Failed to send custom SMS to: {}", smsDto.getPhoneNumber(), e);
            throw new SMSException("Failed to send custom SMS", e);
        }
    }

    public void sendAnnouncementSMS(String phoneNumber, String title, String content) {
        if (!smsEnabled) {
            log.info("SMS service is disabled, skipping announcement SMS");
            return;
        }

        try {
            String message = buildAnnouncementMessage(title, content);
            sendSMS(phoneNumber, message);
            log.info("Announcement SMS sent successfully to: {}", phoneNumber);
        } catch (Exception e) {
            log.error("Failed to send announcement SMS to: {}", phoneNumber, e);
            throw new SMSException("Failed to send announcement SMS", e);
        }
    }

    public void sendWelcomeSMS(String phoneNumber, String studentName) {
        if (!smsEnabled) {
            log.info("SMS service is disabled, skipping welcome SMS");
            return;
        }

        try {
            String message = buildWelcomeMessage(studentName);
            sendSMS(phoneNumber, message);
            log.info("Welcome SMS sent successfully to: {}", phoneNumber);
        } catch (Exception e) {
            log.error("Failed to send welcome SMS to: {}", phoneNumber, e);
            throw new SMSException("Failed to send welcome SMS", e);
        }
    }

    public void sendPaymentConfirmationSMS(String phoneNumber, String studentName,
                                           BigDecimal amount, String receiptNumber) {
        if (!smsEnabled) {
            log.info("SMS service is disabled, skipping payment confirmation SMS");
            return;
        }

        try {
            String message = buildPaymentConfirmationMessage(studentName, amount, receiptNumber);
            sendSMS(phoneNumber, message);
            log.info("Payment confirmation SMS sent successfully to: {}", phoneNumber);
        } catch (Exception e) {
            log.error("Failed to send payment confirmation SMS to: {}", phoneNumber, e);
            throw new SMSException("Failed to send payment confirmation SMS", e);
        }
    }

    private void sendSMS(String phoneNumber, String message) {
        try {
            // Clean phone number format
            String cleanPhoneNumber = phoneNumber.replaceAll("[^0-9+]", "");
            if (!cleanPhoneNumber.startsWith("+")) {
                cleanPhoneNumber = "+91" + cleanPhoneNumber; // Default to India country code
            }

            Message twilioMessage = Message.creator(
                    new PhoneNumber(cleanPhoneNumber),
                    new PhoneNumber(twilioConfig.getFromPhoneNumber()),
                    message
            ).create();

            log.info("SMS sent successfully with SID: {}", twilioMessage.getSid());
        } catch (Exception e) {
            log.error("Failed to send SMS to: {}", phoneNumber, e);
            throw new SMSException("Failed to send SMS via Twilio", e);
        }
    }

    private String buildFeeReminderMessage(FeeDto fee) {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd-MM-yyyy");

        return String.format(
                "Dear Parent, Fee reminder for %s (Roll: %s). Amount: ₹%s due on %s. Please pay soon. - %s",
                fee.getStudent().getName(),
                fee.getStudent().getRollNumber(),
                fee.getDueAmount(),
                fee.getDueDate().format(formatter),
                schoolName
        );
    }

    private String buildAnnouncementMessage(String title, String content) {
        String shortContent = content.length() > 100 ? content.substring(0, 100) + "..." : content;
        return String.format(
                "%s: %s - %s",
                schoolName,
                title,
                shortContent
        );
    }

    private String buildWelcomeMessage(String studentName) {
        return String.format(
                "Welcome to %s! We are pleased to have %s as our student. For any queries, please contact the school office. - %s",
                schoolName,
                studentName,
                schoolName
        );
    }

    private String buildPaymentConfirmationMessage(String studentName, BigDecimal amount, String receiptNumber) {
        return String.format(
                "Payment of ₹%s received for %s. Receipt No: %s. Thank you! - %s",
                amount,
                studentName,
                receiptNumber,
                schoolName
        );
    }

    public boolean isSMSEnabled() {
        return smsEnabled;
    }

    public void setSMSEnabled(boolean enabled) {
        this.smsEnabled = enabled;
        log.info("SMS service enabled status changed to: {}", enabled);
    }
}