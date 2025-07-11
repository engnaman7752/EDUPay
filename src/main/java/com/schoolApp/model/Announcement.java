package com.schoolApp.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "announcements")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Announcement {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "Title is required")
    @Size(min = 5, max = 200, message = "Title must be between 5 and 200 characters")
    @Column(nullable = false, length = 200)
    private String title;

    @NotBlank(message = "Content is required")
    @Size(min = 10, max = 2000, message = "Content must be between 10 and 2000 characters")
    @Column(nullable = false, length = 2000)
    private String content;

    @NotNull(message = "Announcement type is required")
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private AnnouncementType type;

    @NotNull(message = "Priority is required")
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Priority priority;

    @Column(name = "target_class", length = 10)
    private String targetClass;

    @Column(name = "target_section", length = 5)
    private String targetSection;

    @Column(name = "is_active")
    private Boolean isActive = true;

    @Column(name = "publish_date")
    private LocalDateTime publishDate;

    @Column(name = "expiry_date")
    private LocalDateTime expiryDate;

    @Column(name = "created_by", length = 100)
    private String createdBy;

    @Column(name = "sms_sent")
    private Boolean smsSent = false;

    @Column(name = "email_sent")
    private Boolean emailSent = false;

    @Column(name = "view_count")
    private Integer viewCount = 0;

    @Size(max = 500, message = "Attachment URL cannot exceed 500 characters")
    @Column(name = "attachment_url", length = 500)
    private String attachmentUrl;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    public enum AnnouncementType {
        GENERAL, ACADEMIC, SPORTS, CULTURAL, HOLIDAY, EXAMINATION, FEE_REMINDER, EMERGENCY
    }

    public enum Priority {
        LOW, NORMAL, HIGH, URGENT
    }
}