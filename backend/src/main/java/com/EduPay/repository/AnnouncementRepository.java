package com.EduPay.repository;

import com.EduPay.model.Announcement;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

/**
 * JPA Repository for the Announcement entity.
 * Provides methods for database operations related to announcements.
 */
@Repository
public interface AnnouncementRepository extends JpaRepository<Announcement, Long> {

    List<Announcement> findByCreatorId(Long creatorId);


    List<Announcement> findByTargetAudience(String targetAudience);

    List<Announcement> findByPublishDateAfter(LocalDateTime date);
}
