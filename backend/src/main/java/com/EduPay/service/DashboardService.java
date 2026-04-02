package com.EduPay.service;

import com.EduPay.model.FinancialRecord;
import com.EduPay.repository.FinancialRecordRepository;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class DashboardService {
    
    private final FinancialRecordRepository financialRecordRepository;
    
    public DashboardService(FinancialRecordRepository financialRecordRepository) {
        this.financialRecordRepository = financialRecordRepository;
    }
    
    public Map<String, Object> getDashboardSummary() {
        List<FinancialRecord> allRecords = financialRecordRepository.findAll();
        
        BigDecimal totalIncome = allRecords.stream()
                .filter(r -> "INCOME".equalsIgnoreCase(r.getType()))
                .map(FinancialRecord::getAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
                
        BigDecimal totalExpenses = allRecords.stream()
                .filter(r -> "EXPENSE".equalsIgnoreCase(r.getType()))
                .map(FinancialRecord::getAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
                
        BigDecimal netBalance = totalIncome.subtract(totalExpenses);
        
        Map<String, BigDecimal> categoryTotals = allRecords.stream()
                .collect(Collectors.groupingBy(
                        FinancialRecord::getCategory,
                        Collectors.reducing(
                                BigDecimal.ZERO,
                                FinancialRecord::getAmount,
                                BigDecimal::add
                        )
                ));
        
        List<FinancialRecord> recentActivity = allRecords.stream()
                .sorted((a, b) -> b.getRecordDate().compareTo(a.getRecordDate()))
                .limit(10)
                .collect(Collectors.toList());
                
        Map<String, Object> summary = new HashMap<>();
        summary.put("totalIncome", totalIncome);
        summary.put("totalExpenses", totalExpenses);
        summary.put("netBalance", netBalance);
        summary.put("categoryTotals", categoryTotals);
        summary.put("recentActivity", recentActivity);
        
        return summary;
    }
}
