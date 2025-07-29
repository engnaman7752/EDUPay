package com.EduPay.repository;

import com.EduPay.model.Student;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * JPA Repository for the Student entity.
 * Provides methods for database operations related to students.
 */
@Repository
public interface StudentRepository extends JpaRepository<Student, Long> {


    Optional<Student> findByStudentId(String studentId);


    Optional<Student> findByRollNo(String rollNo);


    Optional<Student> findByMobileNo(String mobileNo);



    List<Student> findByAdminId(Long adminId);

    Optional<Student> findByName(String username);
}
