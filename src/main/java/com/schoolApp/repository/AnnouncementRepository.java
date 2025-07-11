package com.schoolApp.repository;

import com.schoolApp.model.Announcement;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface AnnouncementRepository extends JpaRepository<Announcement, Long> {

    List<Announcement> findByIsActiveTrue();

    List<Announcement> findByType(Announcement.AnnouncementType type);

    List<Announcement> findByPriority(Announcement.Priority priority);

    List<Announcement> findByTargetClass(String targetClass);

    List<Announcement> findByTargetClassAndTargetSection(String targetClass, String targetSection);

    @Query("SELECT a FROM Announcement a WHERE a.isActive = true AND (a.expiryDate IS NULL OR a.expiryDate > :currentDate)")
    List<Announcement> findActiveAndNotExpired(@Param("currentDate") LocalDateTime currentDate);

    @Query("SELECT a FROM Announcement a WHERE a.publishDate <= :currentDate AND a.isActive = true ORDER BY a.priority DESC, a.createdAt DESC")
    List<Announcement> findPublishedAnnouncements(@Param("currentDate") LocalDateTime currentDate);

    @Query("SELECT a FROM Announcement a WHERE a.targetClass = :targetClass AND a.isActive = true AND (a.expiryDate IS NULL OR a.expiryDate > :currentDate)")
    List<Announcement> findActiveAnnouncementsForClass(@Param("targetClass") String targetClass, @Param("currentDate") LocalDateTime currentDate);

    @Query("SELECT a FROM Announcement a WHERE a.targetClass = :targetClass AND a.targetSection = :targetSection AND a.isActive = true AND (a.expiryDate IS NULL OR a.expiryDate > :currentDate)")
    List<Announcement> findActiveAnnouncementsForClassAndSection(@Param("targetClass") String targetClass, @Param("targetSection") String targetSection, @Param("currentDate") LocalDateTime currentDate);

    @Query("SELECT a FROM Announcement a WHERE a.createdBy = :createdBy ORDER BY a.createdAt DESC")
    List<Announcement> findByCreatedBy(@Param("createdBy") String createdBy);

    @Query("SELECT a FROM Announcement a WHERE a.title LIKE %:keyword% OR a.content LIKE %:keyword%")
    Page<Announcement> findByKeyword(@Param("keyword") String keyword, Pageable pageable);

    @Query("SELECT a FROM Announcement a WHERE a.createdAt BETWEEN :startDate AND :endDate")
    List<Announcement> findByCreatedAtBetween(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);

    @Query("SELECT COUNT(a) FROM Announcement a WHERE a.type = :type AND a.isActive = true")
    Long countByTypeAndActive(@Param("type") Announcement.AnnouncementType type);

    @Query("SELECT a FROM Announcement a WHERE a.smsSent = false AND a.isActive = true AND a.publishDate <= :currentDate")
    List<Announcement> findAnnouncementsForSMS(@Param("currentDate") LocalDateTime currentDate);

    @Query("SELECT a FROM Announcement a WHERE a.emailSent = false AND a.isActive = true AND a.publishDate <= :currentDate")
    List<Announcement> findAnnouncementsForEmail(@Param("currentDate") LocalDateTime currentDate);

    List<Announcement> findTop10ByIsActiveTrueOrderByCreatedAtDesc();
}