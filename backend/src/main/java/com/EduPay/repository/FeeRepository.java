package com.EduPay.repository;

import com.EduPay.model.Fee;
import com.EduPay.model.Student;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface FeeRepository extends JpaRepository<Fee, Long> {

    List<Fee> findByStudentId(Long studentId);
    Optional<Fee> findByStudentIdAndStatus(Long studentId, String status);
    List<Fee> findByStudent(Student student);

    // All fees for students in a given standard string (e.g. "10")
    List<Fee> findByStudentStandard(String standard);

    // All fees that are overdue (dueDate < today AND outstanding > 0)
    @Query("SELECT f FROM Fee f WHERE f.dueDate < :today AND f.outstandingAmount > 0")
    List<Fee> findOverdueFees(@Param("today") LocalDate today);

    // Overdue fees scoped to a single student
    @Query("SELECT f FROM Fee f WHERE f.student.id = :studentId AND f.dueDate < :today AND f.outstandingAmount > 0")
    List<Fee> findOverdueFeesByStudent(@Param("studentId") Long studentId,
                                       @Param("today") LocalDate today);

    // Overdue fees scoped to a class standard
    @Query("SELECT f FROM Fee f WHERE f.student.standard = :standard AND f.dueDate < :today AND f.outstandingAmount > 0")
    List<Fee> findOverdueFeesByStandard(@Param("standard") String standard,
                                        @Param("today") LocalDate today);
}
