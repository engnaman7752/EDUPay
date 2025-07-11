package com.schoolApp.service;

import com.schoolApp.dto.AnnouncementDto;
import com.schoolApp.exception.ResourceNotFoundException;
import com.schoolApp.model.Announcement;
import com.schoolApp.repository.AnnouncementRepository;
import com.schoolApp.repository.StudentRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.modelmapper.ModelMapper;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class AnnouncementService {

    private final AnnouncementRepository announcementRepository;
    private final StudentRepository studentRepository;
    private final SMSService smsService;
    private final ModelMapper modelMapper;

    public AnnouncementDto createAnnouncement(AnnouncementDto announcementDto) {
        log.info("Creating new announcement: {}", announcementDto.getTitle());

        Announcement announcement = modelMapper.map(announcementDto, Announcement.class);
        announcement.setPublishDate(LocalDateTime.now());
        announcement.setIsActive(true);
        announcement.setViewCount(0);

        Announcement savedAnnouncement = announcementRepository.save(announcement);
        log.info("Successfully created announcement with ID: {}", savedAnnouncement.getId());

        return modelMapper.map(savedAnnouncement, AnnouncementDto.class);
    }

    public AnnouncementDto updateAnnouncement(Long id, AnnouncementDto announcementDto) {
        log.info("Updating announcement with ID: {}", id);

        Announcement existingAnnouncement = announcementRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Announcement not found with ID: " + id));

        modelMapper.map(announcementDto, existingAnnouncement);
        existingAnnouncement.setId(id);

        Announcement updatedAnnouncement = announcementRepository.save(existingAnnouncement);
        log.info("Successfully updated announcement with ID: {}", updatedAnnouncement.getId());

        return modelMapper.map(updatedAnnouncement, AnnouncementDto.class);
    }

    @Transactional(readOnly = true)
    public AnnouncementDto getAnnouncementById(Long id) {
        log.info("Fetching announcement with ID: {}", id);

        Announcement announcement = announcementRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Announcement not found with ID: " + id));

        // Increment view count
        announcement.setViewCount(announcement.getViewCount() + 1);
        announcementRepository.save(announcement);

        return modelMapper.map(announcement, AnnouncementDto.class);
    }

    @Transactional(readOnly = true)
    public Page<AnnouncementDto> getAllAnnouncements(Pageable pageable) {
        log.info("Fetching all announcements with pagination");

        Page<Announcement> announcements = announcementRepository.findAll(pageable);
        return announcements.map(announcement -> modelMapper.map(announcement, AnnouncementDto.class));
    }

    @Transactional(readOnly = true)
    public List<AnnouncementDto> getActiveAnnouncements() {
        log.info("Fetching all active announcements");

        List<Announcement> announcements = announcementRepository.findActiveAndNotExpired(LocalDateTime.now());
        return announcements.stream()
                .map(announcement -> modelMapper.map(announcement, AnnouncementDto.class))
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<AnnouncementDto> getPublishedAnnouncements() {
        log.info("Fetching all published announcements");

        List<Announcement> announcements = announcementRepository.findPublishedAnnouncements(LocalDateTime.now());
        return announcements.stream()
                .map(announcement -> modelMapper.map(announcement, AnnouncementDto.class))
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<AnnouncementDto> getAnnouncementsForClass(String studentClass) {
        log.info("Fetching announcements for class: {}", studentClass);

        List<Announcement> announcements = announcementRepository.findActiveAnnouncementsForClass(studentClass, LocalDateTime.now());
        return announcements.stream()
                .map(announcement -> modelMapper.map(announcement, AnnouncementDto.class))
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<AnnouncementDto> getAnnouncementsForClassAndSection(String studentClass, String section) {
        log.info("Fetching announcements for class: {} and section: {}", studentClass, section);

        List<Announcement> announcements = announcementRepository.findActiveAnnouncementsForClassAndSection(
                studentClass, section, LocalDateTime.now());
        return announcements.stream()
                .map(announcement -> modelMapper.map(announcement, AnnouncementDto.class))
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<AnnouncementDto> getAnnouncementsByType(Announcement.AnnouncementType type) {
        log.info("Fetching announcements by type: {}", type);

        List<Announcement> announcements = announcementRepository.findByType(type);
        return announcements.stream()
                .map(announcement -> modelMapper.map(announcement, AnnouncementDto.class))
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public Page<AnnouncementDto> searchAnnouncements(String keyword, Pageable pageable) {
        log.info("Searching announcements with keyword: {}", keyword);

        Page<Announcement> announcements = announcementRepository.findByKeyword(keyword, pageable);
        return announcements.map(announcement -> modelMapper.map(announcement, AnnouncementDto.class));
    }

    public void deleteAnnouncement(Long id) {
        log.info("Deleting announcement with ID: {}", id);

        Announcement announcement = announcementRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Announcement not found with ID: " + id));

        // Soft delete by setting isActive to false
        announcement.setIsActive(false);
        announcementRepository.save(announcement);

        log.info("Successfully deleted announcement with ID: {}", id);
    }

    public AnnouncementDto toggleAnnouncementStatus(Long id) {
        log.info("Toggling status of announcement with ID: {}", id);

        Announcement announcement = announcementRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Announcement not found with ID: " + id));

        announcement.setIsActive(!announcement.getIsActive());
        Announcement updatedAnnouncement = announcementRepository.save(announcement);

        log.info("Successfully toggled status of announcement with ID: {}", id);
        return modelMapper.map(updatedAnnouncement, AnnouncementDto.class);
    }

    public void sendAnnouncementSMS(Long announcementId) {
        log.info("Sending SMS for announcement with ID: {}", announcementId);

        Announcement announcement = announcementRepository.findById(announcementId)
                .orElseThrow(() -> new ResourceNotFoundException("Announcement not found with ID: " + announcementId));

        if (announcement.getSmsSent()) {
            log.warn("SMS already sent for announcement with ID: {}", announcementId);
            return;
        }

        // Get target students
        List<String> phoneNumbers;
        if (announcement.getTargetClass() != null) {
            if (announcement.getTargetSection() != null) {
                phoneNumbers = studentRepository.findByStudentClassAndSection(
                                announcement.getTargetClass(), announcement.getTargetSection())
                        .stream()
                        .map(student -> student.getPhoneNumber())
                        .collect(Collectors.toList());
            } else {
                phoneNumbers = studentRepository.findByStudentClass(announcement.getTargetClass())
                        .stream()
                        .map(student -> student.getPhoneNumber())
                        .collect(Collectors.toList());
            }
        } else {
            phoneNumbers = studentRepository.findByStatus(com.schoolApp.model.Student.StudentStatus.ACTIVE)
                    .stream()
                    .map(student -> student.getPhoneNumber())
                    .collect(Collectors.toList());
        }

        // Send SMS to all target phone numbers
        phoneNumbers.forEach(phoneNumber -> {
            try {
                smsService.sendAnnouncementSMS(phoneNumber, announcement.getTitle(), announcement.getContent());
            } catch (Exception e) {
                log.error("Failed to send announcement SMS to: {}", phoneNumber, e);
            }
        });

        // Mark SMS as sent
        announcement.setSmsSent(true);
        announcementRepository.save(announcement);

        log.info("Successfully sent SMS for announcement with ID: {} to {} recipients", announcementId, phoneNumbers.size());
    }

    @Transactional(readOnly = true)
    public List<AnnouncementDto> getRecentAnnouncements(int limit) {
        log.info("Fetching recent {} announcements", limit);

        List<Announcement> announcements = announcementRepository.findTop10ByIsActiveTrueOrderByCreatedAtDesc();
        return announcements.stream()
                .limit(limit)
                .map(announcement -> modelMapper.map(announcement, AnnouncementDto.class))
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public long getTotalAnnouncementCount() {
        return announcementRepository.count();
    }

    @Transactional(readOnly = true)
    public long getActiveAnnouncementCount() {
        return announcementRepository.countByTypeAndActive(null, true);
    }
}