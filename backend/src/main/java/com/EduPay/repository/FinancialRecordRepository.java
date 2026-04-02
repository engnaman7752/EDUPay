package com.EduPay.repository;

import com.EduPay.model.FinancialRecord;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface FinancialRecordRepository extends JpaRepository<FinancialRecord, Long> {
    List<FinancialRecord> findByType(String type);
    List<FinancialRecord> findByCategory(String category);
    List<FinancialRecord> findByRecordDateBetween(LocalDate startDate, LocalDate endDate);
}
