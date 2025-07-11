package com.schoolApp.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "students")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Student {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "Student name is required")
    @Size(min = 2, max = 100, message = "Student name must be between 2 and 100 characters")
    @Column(nullable = false, length = 100)
    private String name;

    @NotBlank(message = "Roll number is required")
    @Column(nullable = false, unique = true, length = 20)
    private String rollNumber;

    @NotBlank(message = "Class is required")
    @Column(nullable = false, length = 10)
    private String studentClass;

    @NotBlank(message = "Section is required")
    @Column(nullable = false, length = 5)
    private String section;

    @NotNull(message = "Date of birth is required")
    @Past(message = "Date of birth must be in the past")
    @Column(nullable = false)
    private LocalDate dateOfBirth;

    @NotBlank(message = "Father's name is required")
    @Size(min = 2, max = 100, message = "Father's name must be between 2 and 100 characters")
    @Column(nullable = false, length = 100)
    private String fatherName;

    @NotBlank(message = "Mother's name is required")
    @Size(min = 2, max = 100, message = "Mother's name must be between 2 and 100 characters")
    @Column(nullable = false, length = 100)
    private String motherName;

    @NotBlank(message = "Phone number is required")
    @Pattern(regexp = "^[+]?[0-9]{10,15}$", message = "Phone number must be valid")
    @Column(nullable = false, length = 15)
    private String phoneNumber;

    @Email(message = "Email should be valid")
    @Column(length = 100)
    private String email;

    @NotBlank(message = "Address is required")
    @Size(max = 500, message = "Address cannot exceed 500 characters")
    @Column(nullable = false, length = 500)
    private String address;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Gender gender;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private StudentStatus status = StudentStatus.ACTIVE;

    @Column(name = "admission_date")
    private LocalDate admissionDate;

    @Column(name = "emergency_contact", length = 15)
    private String emergencyContact;

    @Column(name = "blood_group", length = 5)
    private String bloodGroup;

    @OneToMany(mappedBy = "student", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Fee> fees;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    public enum Gender {
        MALE, FEMALE, OTHER
    }

    public enum StudentStatus {
        ACTIVE, INACTIVE, GRADUATED, TRANSFERRED
    }
}
