package com.schoolApp.repository;

import com.schoolApp.model.Fee;
import com.schoolApp.model.Student;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface FeeRepository extends JpaRepository<Fee, Long> {

    List<Fee> findByStudentId(Long studentId);

    List<Fee> findByStudentIdAndPaymentStatus(Long studentId, Fee.PaymentStatus paymentStatus);

    List<Fee> findByPaymentStatus(Fee.PaymentStatus paymentStatus);

    List<Fee> findByFeeTypeAndFeeMonthAndFeeYear(Fee.FeeType feeType, Integer feeMonth, Integer feeYear);

    Optional<Fee> findByStudentAndFeeTypeAndFeeMonthAndFeeYear(Student student, Fee.FeeType feeType, Integer feeMonth, Integer feeYear);

    @Query("SELECT f FROM Fee f WHERE f.dueDate < :currentDate AND f.paymentStatus IN ('PENDING', 'PARTIALLY_PAID')")
    List<Fee> findOverdueFees(@Param("currentDate") LocalDate currentDate);

    @Query("SELECT f FROM Fee f WHERE f.dueDate = :dueDate AND f.paymentStatus IN ('PENDING', 'PARTIALLY_PAID')")
    List<Fee> findFeesDueToday(@Param("dueDate") LocalDate dueDate);

    @Query("SELECT f FROM Fee f WHERE f.dueDate BETWEEN :startDate AND :endDate AND f.paymentStatus IN ('PENDING', 'PARTIALLY_PAID')")
    List<Fee> findFeesDueBetween(@Param("startDate") LocalDate startDate, @Param("endDate") LocalDate endDate);

    @Query("SELECT f FROM Fee f WHERE f.student.studentClass = :studentClass AND f.feeMonth = :month AND f.feeYear = :year")
    List<Fee> findByClassAndMonthAndYear(@Param("studentClass") String studentClass, @Param("month") Integer month, @Param("year") Integer year);

    @Query("SELECT SUM(f.amount) FROM Fee f WHERE f.paymentStatus = 'PAID' AND f.paymentDate BETWEEN :startDate AND :endDate")
    BigDecimal getTotalCollectionBetween(@Param("startDate") LocalDate startDate, @Param("endDate") LocalDate endDate);

    @Query("SELECT SUM(f.dueAmount) FROM Fee f WHERE f.paymentStatus IN ('PENDING', 'PARTIALLY_PAID')")
    BigDecimal getTotalOutstandingAmount();

    @Query("SELECT f.feeType, SUM(f.amount) FROM Fee f WHERE f.paymentStatus = 'PAID' AND f.paymentDate BETWEEN :startDate AND :endDate GROUP BY f.feeType")
    List<Object[]> getCollectionByFeeType(@Param("startDate") LocalDate startDate, @Param("endDate") LocalDate endDate);

    @Query("SELECT f.student.studentClass, SUM(f.amount) FROM Fee f WHERE f.paymentStatus = 'PAID' AND f.paymentDate BETWEEN :startDate AND :endDate GROUP BY f.student.studentClass")
    List<Object[]> getCollectionByClass(@Param("startDate") LocalDate startDate, @Param("endDate") LocalDate endDate);

    @Query("SELECT COUNT(f) FROM Fee f WHERE f.paymentStatus = :status")
    Long countByPaymentStatus(@Param("status") Fee.PaymentStatus status);

    @Query("SELECT f FROM Fee f WHERE f.smsSent = false AND f.dueDate <= :reminderDate AND f.paymentStatus IN ('PENDING', 'PARTIALLY_PAID')")
    List<Fee> findFeesForSMSReminder(@Param("reminderDate") LocalDate reminderDate);

    @Query("SELECT f FROM Fee f WHERE f.receiptNumber = :receiptNumber")
    Optional<Fee> findByReceiptNumber(@Param("receiptNumber") String receiptNumber);

    @Query("SELECT f FROM Fee f WHERE f.transactionId = :transactionId")
    Optional<Fee> findByTransactionId(@Param("transactionId") String transactionId);

    Page<Fee> findByStudentNameContainingIgnoreCase(String studentName, Pageable pageable);
}