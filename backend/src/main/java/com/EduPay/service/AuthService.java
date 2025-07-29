package com.EduPay.service;

import com.EduPay.dto.AuthResponse;
import com.EduPay.model.User;
import com.EduPay.repository.UserRepository;
import com.EduPay.util.JwtUtil;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder; // Used for hashing passwords
    private final JwtUtil jwtUtil; // Used for generating JWT tokens

    public AuthService(UserRepository userRepository, PasswordEncoder passwordEncoder, JwtUtil jwtUtil) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtUtil = jwtUtil;
    }


    public AuthResponse authenticateUser(String username, String password) {
        // Find user by username
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found with username: " + username));

        // Verify password
        if (!passwordEncoder.matches(password, user.getPassword())) {
            throw new RuntimeException("Invalid credentials.");
        }

        // Generate JWT token
        String token = jwtUtil.generateToken(user.getUsername(), user.getRole());

        // Return authentication response
        return new AuthResponse(token, user.getRole(), user.getId(), user.getUsername());
    }


    public void registerAdmin(String username, String password) {
        // Check if username already exists
        if (userRepository.findByUsername(username).isPresent()) {
            throw new RuntimeException("Username already exists: " + username);
        }

        // Create new User entity
        User newAdmin = new User();
        newAdmin.setUsername(username);
        newAdmin.setPassword(passwordEncoder.encode(password)); // Hash the password
        newAdmin.setRole("ADMIN"); // Set role to ADMIN

        // Save the new admin to the database
        userRepository.save(newAdmin);
    }


}
