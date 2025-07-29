package com.EduPay.service;

import com.EduPay.dto.AnnouncementDto;
import com.EduPay.model.Announcement;
import com.EduPay.model.User;
import com.EduPay.repository.AnnouncementRepository;
import com.EduPay.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Service class for managing announcements.
 * Handles creation, update, deletion, and retrieval of announcements.
 */
@Service
public class AnnouncementService {

    private final AnnouncementRepository announcementRepository;
    private final UserRepository userRepository; // To link announcements to their creators

    public AnnouncementService(AnnouncementRepository announcementRepository, UserRepository userRepository) {
        this.announcementRepository = announcementRepository;
        this.userRepository = userRepository;
    }

    /**
     * Creates a new announcement, linking it to the currently authenticated admin.
     *
     * @param announcementDto DTO containing announcement details.
     * @return AnnouncementDto of the newly created announcement.
     * @throws RuntimeException if the creator (admin) is not found.
     */
    @Transactional
    public AnnouncementDto createAnnouncement(AnnouncementDto announcementDto) {
        // In a real app, get creatorId from Spring Security context
        Long currentAdminId = 1L; // Placeholder: Replace with actual admin ID from security context

        User creator = userRepository.findById(currentAdminId)
                .orElseThrow(() -> new RuntimeException("Creator (admin) not found with ID: " + currentAdminId));

        Announcement announcement = new Announcement();
        announcement.setTitle(announcementDto.getTitle());
        announcement.setContent(announcementDto.getContent());
        announcement.setPublishDate(LocalDateTime.now()); // Set current time as publish date
        announcement.setTargetAudience(announcementDto.getTargetAudience());
        announcement.setCreator(creator);

        Announcement savedAnnouncement = announcementRepository.save(announcement);
        return convertToDto(savedAnnouncement);
    }

    /**
     * Updates an existing announcement.
     *
     * @param id The ID of the announcement to update.
     * @param announcementDto DTO containing updated announcement details.
     * @return AnnouncementDto of the updated announcement.
     * @throws RuntimeException if announcement is not found.
     */
    @Transactional
    public AnnouncementDto updateAnnouncement(Long id, AnnouncementDto announcementDto) {
        Announcement announcement = announcementRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Announcement not found with ID: " + id));

        announcement.setTitle(announcementDto.getTitle());
        announcement.setContent(announcementDto.getContent());
        announcement.setTargetAudience(announcementDto.getTargetAudience());
        // publishDate and creator typically not updated via this method

        Announcement updatedAnnouncement = announcementRepository.save(announcement);
        return convertToDto(updatedAnnouncement);
    }

    /**
     * Deletes an announcement by its ID.
     *
     * @param id The ID of the announcement to delete.
     * @throws RuntimeException if announcement is not found.
     */
    @Transactional
    public void deleteAnnouncement(Long id) {
        if (!announcementRepository.existsById(id)) {
            throw new RuntimeException("Announcement not found with ID: " + id);
        }
        announcementRepository.deleteById(id);
    }

    /**
     * Retrieves all announcements created by the currently authenticated admin.
     *
     * @return List of AnnouncementDto created by the admin.
     */
    public List<AnnouncementDto> getAnnouncementsByCreator() {
        // In a real app, get creatorId from Spring Security context
        Long currentAdminId = 1L; // Placeholder: Replace with actual admin ID from security context

        List<Announcement> announcements = announcementRepository.findByCreatorId(currentAdminId);
        return announcements.stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }

    /**
     * Retrieves all announcements relevant to students (e.g., "All Students" or specific standards).
     *
     * @return List of AnnouncementDto.
     */
    public List<AnnouncementDto> getAnnouncementsForStudents() {
        // This method can be expanded to filter by student's class/standard.
        // For now, it fetches all announcements.
        List<Announcement> announcements = announcementRepository.findAll();
        return announcements.stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }

    // --- Helper method for DTO conversion ---
    private AnnouncementDto convertToDto(Announcement announcement) {
        return new AnnouncementDto(
                announcement.getId(),
                announcement.getTitle(),
                announcement.getContent(),
                announcement.getPublishDate(),
                announcement.getTargetAudience(),
                announcement.getCreator() != null ? announcement.getCreator().getId() : null,
                announcement.getCreator() != null ? announcement.getCreator().getUsername() : null
        );
    }
}
