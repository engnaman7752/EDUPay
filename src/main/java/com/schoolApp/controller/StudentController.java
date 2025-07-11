package com.schoolApp.controller;

import com.schoolApp.dto.StudentDto;
import com.schoolApp.model.Student;
import com.schoolApp.service.StudentService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/students")
@RequiredArgsConstructor
@Slf4j
@Tag(name = "Student Management", description = "APIs for managing students")
public class StudentController {

    private final StudentService studentService;

    @PostMapping
    @PreAuthorize("hasRole('ADMIN') or hasRole('TEACHER')")
    @Operation(summary = "Create a new student")
    public ResponseEntity<StudentDto> createStudent(@Valid @RequestBody StudentDto studentDto) {
        log.info("Creating new student: {}", studentDto.getName());
        StudentDto createdStudent = studentService.createStudent(studentDto);
        return new ResponseEntity<>(createdStudent, HttpStatus.CREATED);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN') or hasRole('TEACHER')")
    @Operation(summary = "Update an existing student")
    public ResponseEntity<StudentDto> updateStudent(@PathVariable Long id, @Valid @RequestBody StudentDto studentDto) {
        log.info("Updating student with ID: {}", id);
        StudentDto updatedStudent = studentService.updateStudent(id, studentDto);
        return ResponseEntity.ok(updatedStudent);
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get student by ID")
    public ResponseEntity<StudentDto> getStudentById(@PathVariable Long id) {
        log.info("Fetching student with ID: {}", id);
        StudentDto student = studentService.getStudentById(id);
        return ResponseEntity.ok(student);
    }

    @GetMapping("/roll-number/{rollNumber}")
    @Operation(summary = "Get student by roll number")
    public ResponseEntity<StudentDto> getStudentByRollNumber(@PathVariable String rollNumber) {
        log.info("Fetching student with roll number: {}", rollNumber);
        StudentDto student = studentService.getStudentByRollNumber(rollNumber);
        return ResponseEntity.ok(student);
    }

    @GetMapping
    @Operation(summary = "Get all students with pagination")
    public ResponseEntity<Page<StudentDto>> getAllStudents(@PageableDefault(size = 20) Pageable pageable) {
        log.info("Fetching all students with pagination");
        Page<StudentDto> students = studentService.getAllStudents(pageable);
        return ResponseEntity.ok(students);
    }

    @GetMapping("/active")
    @Operation(summary = "Get all active students")
    public ResponseEntity<List<StudentDto>> getActiveStudents() {
        log.info("Fetching all active students");
        List<StudentDto> students = studentService.getActiveStudents();
        return ResponseEntity.ok(students);
    }

    @GetMapping("/class/{studentClass}")
    @Operation(summary = "Get students by class")
    public ResponseEntity<List<StudentDto>> getStudentsByClass(@PathVariable String studentClass) {
        log.info("Fetching students for class: {}", studentClass);
        List<StudentDto> students = studentService.getStudentsByClass(studentClass);
        return ResponseEntity.ok(students);
    }

    @GetMapping("/class/{studentClass}/section/{section}")
    @Operation(summary = "Get students by class and section")
    public ResponseEntity<List<StudentDto>> getStudentsByClassAndSection(@PathVariable String studentClass,
                                                                         @PathVariable String section) {
        log.info("Fetching students for class: {} and section: {}", studentClass, section);
        List<StudentDto> students = studentService.getStudentsByClassAndSection(studentClass, section);
        return ResponseEntity.ok(students);
    }

    @GetMapping("/search")
    @Operation(summary = "Search students by name or roll number")
    public ResponseEntity<Page<StudentDto>> searchStudents(@RequestParam String searchTerm,
                                                           @PageableDefault(size = 20) Pageable pageable) {
        log.info("Searching students with term: {}", searchTerm);
        Page<StudentDto> students = studentService.searchStudents(searchTerm, pageable);
        return ResponseEntity.ok(students);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Delete a student")
    public ResponseEntity<Void> deleteStudent(@PathVariable Long id) {
        log.info("Deleting student with ID: {}", id);
        studentService.deleteStudent(id);
        return ResponseEntity.noContent().build();
    }

    @PatchMapping("/{id}/status")
    @PreAuthorize("hasRole('ADMIN') or hasRole('TEACHER')")
    @Operation(summary = "Change student status")
    public ResponseEntity<StudentDto> changeStudentStatus(@PathVariable Long id,
                                                          @RequestParam Student.StudentStatus status) {
        log.info("Changing status of student with ID: {} to {}", id, status);
        StudentDto updatedStudent = studentService.changeStudentStatus(id, status);
        return ResponseEntity.ok(updatedStudent);
    }

    @GetMapping("/count")
    @Operation(summary = "Get total student count")
    public ResponseEntity<Long> getTotalStudentCount() {
        log.info("Fetching total student count");
        long count = studentService.getTotalStudentCount();
        return ResponseEntity.ok(count);
    }

    @GetMapping("/count/active")
    @Operation(summary = "Get active student count")
    public ResponseEntity<Long> getActiveStudentCount() {
        log.info("Fetching active student count");
        long count = studentService.getActiveStudentCount();
        return ResponseEntity.ok(count);
    }
}