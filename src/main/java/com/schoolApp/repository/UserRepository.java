package com.schoolApp.repository;

import com.schoolApp.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {

    Optional<User> findByUsername(String username);

    Optional<User> findByEmail(String email);

    List<User> findByRole(User.UserRole role);

    List<User> findByIsActiveTrue();

    @Query("SELECT u FROM User u WHERE u.username = :username AND u.isActive = true")
    Optional<User> findActiveUserByUsername(@Param("username") String username);

    @Query("SELECT u FROM User u WHERE u.email = :email AND u.isActive = true")
    Optional<User> findActiveUserByEmail(@Param("email") String email);

    boolean existsByUsername(String username);

    boolean existsByEmail(String email);

    Optional<User> findByPasswordResetToken(String token);

    @Query("SELECT COUNT(u) FROM User u WHERE u.role = :role AND u.isActive = true")
    Long countActiveUsersByRole(@Param("role") User.UserRole role);
}