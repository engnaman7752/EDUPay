package com.EduPay.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.EnableWebMvc;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * Web configuration for the EduPay application.
 * Configures CORS (Cross-Origin Resource Sharing) to allow frontend applications
 * (like your Flutter app) to communicate with the backend API.
 */
@Configuration // Marks this class as a Spring configuration class
@EnableWebMvc // Enables Spring MVC features, including CORS configuration
public class WebConfig implements WebMvcConfigurer {

    /**
     * Configures CORS mappings for the application.
     * This allows your Flutter frontend (running on a different origin/port)
     * to make requests to your Spring Boot backend.
     *
     * @param registry The CorsRegistry to configure.
     */
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**") // Apply CORS to all endpoints
                .allowedOrigins("http://localhost:3000", "http://localhost:8080", "http://localhost:4200",
                        "http://localhost:5000", "http://127.0.0.1:5000", // Common development origins
                        "http://localhost:8081", // For Flutter web development (often runs on 8081)
                        "http://localhost:8082", // Another common Flutter web port
                        "http://10.0.2.2:8080", // Android emulator localhost
                        "http://10.0.3.2:8080", // Genymotion emulator localhost
                        "http://192.168.x.x:8080", // Replace with your actual backend IP if testing on device
                        "https://your-frontend-domain.com", // Replace with your deployed frontend domain
                        "https://edupay-frontend.web.app" // Example: if using Firebase Hosting
                )
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS") // Allowed HTTP methods
                .allowedHeaders("*") // Allow all headers
                .allowCredentials(true) // Allow sending of cookies and authorization headers
                .maxAge(3600); // Max age of the CORS pre-flight request in seconds
    }
}
