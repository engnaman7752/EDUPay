package com.EduPay.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.util.List;
import java.util.ArrayList; // Import ArrayList for initialization

@Entity
@Table(name = "users") // Specify table name for clarity
@Data // Lombok annotation for getters, setters, toString, equals, hashCode
@NoArgsConstructor // Lombok annotation for no-argument constructor
@AllArgsConstructor // Lombok annotation for all-argument constructor
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id; // Primary key for the user

    @Column(unique = true, nullable = false)
    private String username; // User's login username (e.g., email or unique ID)

    @Column(nullable = false)
    private String password; // User's hashed password (store securely, not plain text)

    @Column(nullable = false)
    private String role; // User's role: "ADMIN" or "STUDENT"


    @OneToMany(mappedBy = "admin")
    private List<Student> managedStudents = new ArrayList<>(); // Students managed by this admin

    @OneToMany(mappedBy = "creator") // Assuming 'creator' field in Announcement points to User
    private List<Announcement> createdAnnouncements = new ArrayList<>(); // Announcements created by this admin

}
