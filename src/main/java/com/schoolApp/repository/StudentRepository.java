package com.schoolApp.repository;

import com.schoolApp.model.Student;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface StudentRepository extends JpaRepository<Student, Long> {

    Optional<Student> findByRollNumber(String rollNumber);

    List<Student> findByStudentClassAndSection(String studentClass, String section);

    List<Student> findByStudentClass(String studentClass);

    List<Student> findByStatus(Student.StudentStatus status);

    @Query("SELECT s FROM Student s WHERE s.name LIKE %:name% OR s.rollNumber LIKE %:rollNumber%")
    Page<Student> findByNameOrRollNumber(@Param("name") String name, @Param("rollNumber") String rollNumber, Pageable pageable);

    @Query("SELECT s FROM Student s WHERE s.phoneNumber = :phoneNumber OR s.email = :email")
    List<Student> findByPhoneNumberOrEmail(@Param("phoneNumber") String phoneNumber, @Param("email") String email);

    @Query("SELECT s FROM Student s WHERE s.fatherName LIKE %:parentName% OR s.motherName LIKE %:parentName%")
    List<Student> findByParentName(@Param("parentName") String parentName);

    @Query("SELECT COUNT(s) FROM Student s WHERE s.status = :status")
    Long countByStatus(@Param("status") Student.StudentStatus status);

    @Query("SELECT s.studentClass, COUNT(s) FROM Student s WHERE s.status = 'ACTIVE' GROUP BY s.studentClass")
    List<Object[]> countActiveStudentsByClass();

    @Query("SELECT s FROM Student s WHERE s.admissionDate BETWEEN :startDate AND :endDate")
    List<Student> findByAdmissionDateBetween(@Param("startDate") java.time.LocalDate startDate, @Param("endDate") java.time.LocalDate endDate);

    boolean existsByRollNumber(String rollNumber);

    boolean existsByEmail(String email);

    boolean existsByPhoneNumber(String phoneNumber);
}