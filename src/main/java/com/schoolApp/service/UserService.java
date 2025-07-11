package com.schoolApp.service;

import com.schoolApp.dto.UserDto;
import com.schoolApp.exception.ResourceNotFoundException;
import com.schoolApp.exception.DuplicateResourceException;
import com.schoolApp.model.User;
import com.schoolApp.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.modelmapper.ModelMapper;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final ModelMapper modelMapper;

    public UserDto createUser(UserDto userDto) {
        log.info("Creating new user: {}", userDto.getUsername());

        if (userRepository.existsByUsername(userDto.getUsername())) {
            throw new DuplicateResourceException("Username already exists: " + userDto.getUsername());
        }

        if (userRepository.existsByEmail(userDto.getEmail())) {
            throw new DuplicateResourceException("Email already exists: " + userDto.getEmail());
        }

        User user = modelMapper.map(userDto, User.class);
        user.setPassword(passwordEncoder.encode(userDto.getPassword()));
        user.setIsActive(true);

        User savedUser = userRepository.save(user);
        log.info("Successfully created user with ID: {}", savedUser.getId());

        UserDto result = modelMapper.map(savedUser, UserDto.class);
        result.setPassword(null); // Don't return password
        return result;
    }

    public UserDto updateUser(Long id, UserDto userDto) {
        log.info("Updating user with ID: {}", id);

        User existingUser = userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with ID: " + id));

        // Check for duplicate username (excluding current user)
        if (!existingUser.getUsername().equals(userDto.getUsername()) &&
                userRepository.existsByUsername(userDto.getUsername())) {
            throw new DuplicateResourceException("Username already exists: " + userDto.getUsername());
        }

        // Check for duplicate email (excluding current user)
        if (!existingUser.getEmail().equals(userDto.getEmail()) &&
                userRepository.existsByEmail(userDto.getEmail())) {
            throw new DuplicateResourceException("Email already exists: " + userDto.getEmail());
        }

        modelMapper.map(userDto, existingUser);
        existingUser.setId(id);

        // Only update password if provided
        if (userDto.getPassword() != null && !userDto.getPassword().isEmpty()) {
            existingUser.setPassword(passwordEncoder.encode(userDto.getPassword()));
        }

        User updatedUser = userRepository.save(existingUser);
        log.info("Successfully updated user with ID: {}", updatedUser.getId());

        UserDto result = modelMapper.map(updatedUser, UserDto.class);
        result.setPassword(null); // Don't return password
        return result;
    }

    @Transactional(readOnly = true)
    public UserDto getUserById(Long id) {
        log.info("Fetching user with ID: {}", id);

        User user = userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with ID: " + id));

        UserDto result = modelMapper.map(user, UserDto.class);
        result.setPassword(null); // Don't return password
        return result;
    }

    @Transactional(readOnly = true)
    public UserDto getUserByUsername(String username) {
        log.info("Fetching user with username: {}", username);

        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with username: " + username));

        UserDto result = modelMapper.map(user, UserDto.class);
        result.setPassword(null); // Don't return password
        return result;
    }

    @Transactional(readOnly = true)
    public List<UserDto> getAllUsers() {
        log.info("Fetching all users");

        List<User> users = userRepository.findAll();
        return users.stream()
                .map(user -> {
                    UserDto dto = modelMapper.map(user, UserDto.class);
                    dto.setPassword(null); // Don't return password
                    return dto;
                })
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<UserDto> getActiveUsers() {
        log.info("Fetching all active users");

        List<User> users = userRepository.findByIsActiveTrue();
        return users.stream()
                .map(user -> {
                    UserDto dto = modelMapper.map(user, UserDto.class);
                    dto.setPassword(null); // Don't return password
                    return dto;
                })
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<UserDto> getUsersByRole(User.UserRole role) {
        log.info("Fetching users by role: {}", role);

        List<User> users = userRepository.findByRole(role);
        return users.stream()
                .map(user -> {
                    UserDto dto = modelMapper.map(user, UserDto.class);
                    dto.setPassword(null); // Don't return password
                    return dto;
                })
                .collect(Collectors.toList());
    }

    public void deleteUser(Long id) {
        log.info("Deleting user with ID: {}", id);

        User user = userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with ID: " + id));

        // Soft delete by setting isActive to false
        user.setIsActive(false);
        userRepository.save(user);

        log.info("Successfully deleted user with ID: {}", id);
    }

    public UserDto toggleUserStatus(Long id) {
        log.info("Toggling status of user with ID: {}", id);

        User user = userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with ID: " + id));

        user.setIsActive(!user.getIsActive());
        User updatedUser = userRepository.save(user);

        log.info("Successfully toggled status of user with ID: {}", id);
        UserDto result = modelMapper.map(updatedUser, UserDto.class);
        result.setPassword(null); // Don't return password
        return result;
    }

    public void updateLastLogin(String username) {
        log.info("Updating last login for user: {}", username);

        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with username: " + username));

        user.setLastLogin(LocalDateTime.now());
        userRepository.save(user);

        log.info("Successfully updated last login for user: {}", username);
    }

    public String generatePasswordResetToken(String email) {
        log.info("Generating password reset token for email: {}", email);

        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with email: " + email));

        String token = UUID.randomUUID().toString();
        user.setPasswordResetToken(token);
        user.setPasswordResetExpiry(LocalDateTime.now().plusHours(24)); // Token expires in 24 hours

        userRepository.save(user);

        log.info("Successfully generated password reset token for email: {}", email);
        return token;
    }

    public void resetPassword(String token, String newPassword) {
        log.info("Resetting password using token");

        User user = userRepository.findByPasswordResetToken(token)
                .orElseThrow(() -> new ResourceNotFoundException("Invalid or expired reset token"));

        if (user.getPasswordResetExpiry().isBefore(LocalDateTime.now())) {
            throw new ResourceNotFoundException("Password reset token has expired");
        }

        user.setPassword(passwordEncoder.encode(newPassword));
        user.setPasswordResetToken(null);
        user.setPasswordResetExpiry(null);

        userRepository.save(user);

        log.info("Successfully reset password for user: {}", user.getUsername());
    }

    public boolean changePassword(String username, String oldPassword, String newPassword) {
        log.info("Changing password for user: {}", username);

        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with username: " + username));

        if (!passwordEncoder.matches(oldPassword, user.getPassword())) {
            log.warn("Invalid old password for user: {}", username);
            return false;
        }

        user.setPassword(passwordEncoder.encode(newPassword));
        userRepository.save(user);

        log.info("Successfully changed password for user: {}", username);
        return true;
    }

    @Transactional(readOnly = true)
    public boolean validateUser(String username, String password) {
        log.info("Validating user: {}", username);

        User user = userRepository.findActiveUserByUsername(username).orElse(null);

        if (user == null) {
            log.warn("User not found or inactive: {}", username);
            return false;
        }

        boolean isValid = passwordEncoder.matches(password, user.getPassword());
        log.info("User validation result for {}: {}", username, isValid);

        return isValid;
    }

    @Transactional(readOnly = true)
    public long getTotalUserCount() {
        return userRepository.count();
    }

    @Transactional(readOnly = true)
    public long getActiveUserCount() {
        return userRepository.findByIsActiveTrue().size();
    }
}