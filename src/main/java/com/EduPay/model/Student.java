package com.EduPay.model;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
// Corrected import: Remove this if it exists and ensure 'import com.EduPay.model.User;' is present
// import org.springframework.boot.autoconfigure.security.SecurityProperties;

import java.util.List;
import java.util.ArrayList; // Import ArrayList for initialization

@Entity
@Table(name = "students") // Specify table name for clarity
@Data // Lombok annotation for getters, setters, toString, equals, hashCode
@NoArgsConstructor // Lombok annotation for no-argument constructor
@AllArgsConstructor // Lombok annotation for all-argument constructor
public class Student {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id; // Primary key for the student

    @Column(unique = true, nullable = false)
    private String studentId; // Unique identifier for the student (e.g., S001)

    @Column(nullable = false)
    private String name; // Student's full name

    @Column(unique = true) // Assuming roll number is unique per school/admin
    private String rollNo; // Changed to String as roll numbers can be alphanumeric

    @Column(nullable = false)
    private String mobileNo; // Changed to String for better handling of leading zeros and formatting

    @Column(nullable = false)
    private String standard; // Changed to String (e.g., "Class 10", "XI Science")

    // Multi-tenancy: Link student to the admin (User entity) who created them
    @ManyToOne
    @JoinColumn(name = "admin_user_id", nullable = false) // Foreign key column
    // Corrected: Use your custom User entity
    private User admin; // The admin user who manages this student

    // Relationship with Fee entity: One student can have many fees
    @OneToMany(mappedBy = "student", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Fee> fees = new ArrayList<>(); // Initialize to prevent NullPointerException

    // Relationship with Payment entity: One student can have many payments
    @OneToMany(mappedBy = "student", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Payment> payments = new ArrayList<>(); // Initialize to prevent NullPointerException
}
