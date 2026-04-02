package com.EduPay.controller;

import com.EduPay.model.FinancialRecord;
import com.EduPay.repository.FinancialRecordRepository;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/financial-records")
public class FinancialRecordController {

    private final FinancialRecordRepository financialRecordRepository;

    public FinancialRecordController(FinancialRecordRepository financialRecordRepository) {
        this.financialRecordRepository = financialRecordRepository;
    }

    @GetMapping
    public ResponseEntity<List<FinancialRecord>> getAllRecords(
            @RequestParam(required = false) String type,
            @RequestParam(required = false) String category,
            @RequestParam(required = false) LocalDate startDate,
            @RequestParam(required = false) LocalDate endDate) {
        
        List<FinancialRecord> records;
        
        if (type != null) {
            records = financialRecordRepository.findByType(type);
        } else if (category != null) {
            records = financialRecordRepository.findByCategory(category);
        } else if (startDate != null && endDate != null) {
            records = financialRecordRepository.findByRecordDateBetween(startDate, endDate);
        } else {
            records = financialRecordRepository.findAll();
        }
        return ResponseEntity.ok(records);
    }

    @PostMapping
    public ResponseEntity<FinancialRecord> createRecord(@RequestBody FinancialRecord record) {
        FinancialRecord savedRecord = financialRecordRepository.save(record);
        return ResponseEntity.status(HttpStatus.CREATED).body(savedRecord);
    }

    @PutMapping("/{id}")
    public ResponseEntity<FinancialRecord> updateRecord(@PathVariable Long id, @RequestBody FinancialRecord recordDetails) {
        return financialRecordRepository.findById(id).map(record -> {
            record.setAmount(recordDetails.getAmount());
            record.setType(recordDetails.getType());
            record.setCategory(recordDetails.getCategory());
            record.setRecordDate(recordDetails.getRecordDate());
            record.setNotes(recordDetails.getNotes());
            return ResponseEntity.ok(financialRecordRepository.save(record));
        }).orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteRecord(@PathVariable Long id) {
        if (financialRecordRepository.existsById(id)) {
            financialRecordRepository.deleteById(id);
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }
}
