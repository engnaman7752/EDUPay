package com.EduPay.config;

import com.EduPay.model.User;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.Collections;

/**
 * Custom implementation of Spring Security's UserDetails interface.
 * Wraps our application's User entity to provide user details to Spring Security,
 * including the user's database ID and role.
 */
public class CustomUserDetails implements UserDetails {

    private final User user; // Our application's User entity

    public CustomUserDetails(User user) {
        this.user = user;
    }

    /**
     * Returns the database ID of the user.
     * @return The user's ID.
     */
    public Long getId() {
        return user.getId();
    }

    /**
     * Returns the role of the user (e.g., "ADMIN", "STUDENT").
     * @return The user's role.
     */
    public String getRole() {
        return user.getRole();
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        // Converts the user's role string to a Spring Security GrantedAuthority.
        // Spring Security typically expects roles to be prefixed with "ROLE_", e.g., "ROLE_ADMIN".
        return Collections.singletonList(new SimpleGrantedAuthority("ROLE_" + user.getRole()));
    }

    @Override
    public String getPassword() {
        // Returns the hashed password from the User entity.
        return user.getPassword();
    }

    @Override
    public String getUsername() {
        // Returns the username (student name or admin username) from the User entity.
        return user.getUsername();
    }

    @Override
    public boolean isAccountNonExpired() {
        // Implement logic for account expiration if needed. For now, always true.
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        // Implement logic for account locking if needed. For now, always true.
        return true;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        // Implement logic for credential expiration if needed. For now, always true.
        return true;
    }

    @Override
    public boolean isEnabled() {
        // Implement logic for account enablement if needed. For now, always true.
        return true;
    }
}
