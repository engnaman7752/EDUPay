package com.EduPay.repository;

import com.EduPay.model.Fee;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface FeeRepository extends JpaRepository<Fee, Long> {

    List<Fee> findByStudentId(Long studentId);
    Optional<Fee> findByStudentIdAndStatus(Long studentId, String status);

}
