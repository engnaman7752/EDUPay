package com.schoolApp.service;

import com.schoolApp.dto.StudentDto;
import com.schoolApp.exception.ResourceNotFoundException;
import com.schoolApp.exception.DuplicateResourceException;
import com.schoolApp.model.Student;
import com.schoolApp.repository.StudentRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.modelmapper.ModelMapper;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class StudentService {

    private final StudentRepository studentRepository;
    private final ModelMapper modelMapper;

    public StudentDto createStudent(StudentDto studentDto) {
        log.info("Creating new student with roll number: {}", studentDto.getRollNumber());

        if (studentRepository.existsByRollNumber(studentDto.getRollNumber())) {
            throw new DuplicateResourceException("Student with roll number " + studentDto.getRollNumber() + " already exists");
        }

        if (studentDto.getEmail() != null && studentRepository.existsByEmail(studentDto.getEmail())) {
            throw new DuplicateResourceException("Student with email " + studentDto.getEmail() + " already exists");
        }

        Student student = modelMapper.map(studentDto, Student.class);
        student.setAdmissionDate(LocalDate.now());
        student.setStatus(Student.StudentStatus.ACTIVE);

        Student savedStudent = studentRepository.save(student);
        log.info("Successfully created student with ID: {}", savedStudent.getId());

        return modelMapper.map(savedStudent, StudentDto.class);
    }

    public StudentDto updateStudent(Long id, StudentDto studentDto) {
        log.info("Updating student with ID: {}", id);

        Student existingStudent = studentRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Student not found with ID: " + id));

        // Check for duplicate roll number (excluding current student)
        if (!existingStudent.getRollNumber().equals(studentDto.getRollNumber()) &&
                studentRepository.existsByRollNumber(studentDto.getRollNumber())) {
            throw new DuplicateResourceException("Student with roll number " + studentDto.getRollNumber() + " already exists");
        }

        // Check for duplicate email (excluding current student)
        if (studentDto.getEmail() != null &&
                !studentDto.getEmail().equals(existingStudent.getEmail()) &&
                studentRepository.existsByEmail(studentDto.getEmail())) {
            throw new DuplicateResourceException("Student with email " + studentDto.getEmail() + " already exists");
        }

        // Update fields
        modelMapper.map(studentDto, existingStudent);
        existingStudent.setId(id); // Ensure ID is not overwritten

        Student updatedStudent = studentRepository.save(existingStudent);
        log.info("Successfully updated student with ID: {}", updatedStudent.getId());

        return modelMapper.map(updatedStudent, StudentDto.class);
    }

    @Transactional(readOnly = true)
    public StudentDto getStudentById(Long id) {
        log.info("Fetching student with ID: {}", id);

        Student student = studentRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Student not found with ID: " + id));

        return modelMapper.map(student, StudentDto.class);
    }

    @Transactional(readOnly = true)
    public StudentDto getStudentByRollNumber(String rollNumber) {
        log.info("Fetching student with roll number: {}", rollNumber);

        Student student = studentRepository.findByRollNumber(rollNumber)
                .orElseThrow(() -> new ResourceNotFoundException("Student not found with roll number: " + rollNumber));

        return modelMapper.map(student, StudentDto.class);
    }

    @Transactional(readOnly = true)
    public Page<StudentDto> getAllStudents(Pageable pageable) {
        log.info("Fetching all students with pagination");

        Page<Student> students = studentRepository.findAll(pageable);
        return students.map(student -> modelMapper.map(student, StudentDto.class));
    }

    @Transactional(readOnly = true)
    public List<StudentDto> getStudentsByClass(String studentClass) {
        log.info("Fetching students for class: {}", studentClass);

        List<Student> students = studentRepository.findByStudentClass(studentClass);
        return students.stream()
                .map(student -> modelMapper.map(student, StudentDto.class))
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<StudentDto> getStudentsByClassAndSection(String studentClass, String section) {
        log.info("Fetching students for class: {} and section: {}", studentClass, section);

        List<Student> students = studentRepository.findByStudentClassAndSection(studentClass, section);
        return students.stream()
                .map(student -> modelMapper.map(student, StudentDto.class))
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public Page<StudentDto> searchStudents(String searchTerm, Pageable pageable) {
        log.info("Searching students with term: {}", searchTerm);

        Page<Student> students = studentRepository.findByNameOrRollNumber(searchTerm, searchTerm, pageable);
        return students.map(student -> modelMapper.map(student, StudentDto.class));
    }

    public void deleteStudent(Long id) {
        log.info("Deleting student with ID: {}", id);

        Student student = studentRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Student not found with ID: " + id));

        // Soft delete by changing status
        student.setStatus(Student.StudentStatus.INACTIVE);
        studentRepository.save(student);

        log.info("Successfully deleted student with ID: {}", id);
    }

    public StudentDto changeStudentStatus(Long id, Student.StudentStatus status) {
        log.info("Changing status of student with ID: {} to {}", id, status);

        Student student = studentRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Student not found with ID: " + id));

        student.setStatus(status);
        Student updatedStudent = studentRepository.save(student);

        log.info("Successfully changed status of student with ID: {}", id);
        return modelMapper.map(updatedStudent, StudentDto.class);
    }

    @Transactional(readOnly = true)
    public List<StudentDto> getActiveStudents() {
        log.info("Fetching all active students");

        List<Student> students = studentRepository.findByStatus(Student.StudentStatus.ACTIVE);
        return students.stream()
                .map(student -> modelMapper.map(student, StudentDto.class))
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public long getTotalStudentCount() {
        return studentRepository.count();
    }

    @Transactional(readOnly = true)
    public long getActiveStudentCount() {
        return studentRepository.countByStatus(Student.StudentStatus.ACTIVE);
    }
}