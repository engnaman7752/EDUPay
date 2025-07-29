package com.EduPay.dto;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data // Lombok annotation to generate getters, setters, toString, equals, and hashCode methods
@NoArgsConstructor // Lombok annotation to generate a no-argument constructor
@AllArgsConstructor // Lombok annotation to generate a constructor with all fields
public class StudentDto {
    private Long id; // Student's database ID
    private String studentId; // Unique identifier for the student (e.g., S001)
    private String name; // Student's full name
    private String rollNo; // Student's roll number
    private String mobileNo; // Student's mobile number
    private String standard; // Student's class/standard (e.g., "Class 10")

}