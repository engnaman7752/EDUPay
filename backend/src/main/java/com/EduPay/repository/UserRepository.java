package com.EduPay.repository;

import com.EduPay.model.User;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.lang.NonNull; // Import this
import org.springframework.stereotype.Repository;

import java.util.Optional;

// ... other imports ...

@Repository
public interface UserRepository extends JpaRepository<User, Long> {


    @NonNull
    Optional<User> findByUsername(String username); // Add @NonNull
     @Override // No need to override findById explicitly unless you add custom logic
    @NonNull Optional<User> findById(@NonNull Long aLong); // If you keep it, add @NonNull

    boolean existsByUsername(@NonNull String username); // Add @NonNull
}