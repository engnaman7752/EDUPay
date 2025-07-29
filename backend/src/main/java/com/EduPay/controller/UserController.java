package com.EduPay.controller;

import com.EduPay.dto.LoginRequest;
import com.EduPay.dto.AuthResponse;
import com.EduPay.service.AuthService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController // Marks this class as a REST controller, handling HTTP requests
@RequestMapping("/api/auth") // Base path for all endpoints in this controller
public class UserController {

    private final AuthService authService; // Inject AuthService to handle authentication logic

    // Constructor for dependency injection of AuthService
    public UserController(AuthService authService) {
        this.authService = authService;
    }


    @PostMapping("/login") // Maps POST requests to /api/auth/login
    public ResponseEntity<?> login(@RequestBody LoginRequest loginRequest) {
        try {
            // Call the authentication service to attempt login
            AuthResponse authResponse = authService.authenticateUser(
                    loginRequest.getUsername(),
                    loginRequest.getPassword()
            );
            // If authentication is successful, return the JWT token and user role
            return ResponseEntity.ok(authResponse);
        } catch (RuntimeException e) {
            // Catch authentication-related exceptions (e.g., invalid credentials)
            // Return an unauthorized status with the error message
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(e.getMessage());
        }
    }


    @PostMapping("/register/admin") // Maps POST requests to /api/auth/register/admin
    public ResponseEntity<?> registerAdmin(@RequestBody LoginRequest loginRequest) {
        try {
            // Call the authentication service to register a new admin
            authService.registerAdmin(
                    loginRequest.getUsername(),
                    loginRequest.getPassword()
            );
            return ResponseEntity.status(HttpStatus.CREATED).body("Admin registered successfully.");
        } catch (RuntimeException e) {
            // Catch registration-related exceptions (e.g., username already exists)
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }


}
