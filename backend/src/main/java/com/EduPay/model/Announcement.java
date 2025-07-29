package com.EduPay.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDateTime; // Use LocalDateTime for date and time

@Entity
@Table(name = "announcements") // Specify table name for clarity
@Data // Lombok annotation for getters, setters, toString, equals, hashCode
@NoArgsConstructor // Lombok annotation for no-argument constructor
@AllArgsConstructor // Lombok annotation for all-argument constructor
public class Announcement {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id; // Primary key for the announcement

    @Column(nullable = false)
    private String title; // Title of the announcement

    @Column(nullable = false, columnDefinition = "TEXT") // Use TEXT for potentially long content
    private String content; // Full content of the announcement

    @Column(nullable = false)
    private LocalDateTime publishDate; // Date and time when the announcement was published
    @Column(nullable = true) // Target audience can be optional (e.g., "All Students", "Parents", "Class 10")
    private String targetAudience;
    // Relationship with User entity: Many announcements can be created by one user (admin)
    @ManyToOne
    @JoinColumn(name = "creator_user_id", nullable = false) // Foreign key column
    private User creator; // The user (admin) who created this announcement

}