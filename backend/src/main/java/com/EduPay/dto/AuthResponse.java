package com.EduPay.dto;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;


@Data // Lombok annotation to generate getters, setters, toString, equals, and hashCode methods
@NoArgsConstructor
@AllArgsConstructor
public class AuthResponse {
    private String jwtToken; // The JWT token for subsequent authenticated requests
    private String role;     // The role of the authenticated user (e.g., "ADMIN", "STUDENT")
    private Long userId;     // The ID of the authenticated user
    private String username; // The username of the authenticated user
}