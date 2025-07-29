package com.EduPay.dto;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;
@Data
@NoArgsConstructor
@AllArgsConstructor
public class AnnouncementDto { // Changed to 'class'
    private Long id;
    private String title;
    private String content;
    private LocalDateTime publishDate;
    private String targetAudience;
    private Long creatorId; // To link the announcement to its creator (admin)
    private String creatorUsername; // Optional: for display purposes
}
