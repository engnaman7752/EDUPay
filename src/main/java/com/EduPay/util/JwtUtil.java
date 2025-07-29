package com.EduPay.util;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey; // Import SecretKey
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Function;

@Component // Marks this class as a Spring component, so it can be injected
public class JwtUtil {

    // Secret key for signing JWTs. Loaded from application.properties (or similar config).
    // It's crucial to keep this key secure and not hardcode it in production.
    @Value("${jwt.secret}")
    private String secret;

    // Expiration time for JWTs in milliseconds. Loaded from application.properties.
    @Value("${jwt.expiration}")
    private Long expiration; // e.g., 3600000 for 1 hour

    // Corrected: Return type should be SecretKey, not String
    private SecretKey getSigningKey() {
        // Generates a secure key from the secret string.
        // Ensure the secret string is long enough and securely generated.
        return Keys.hmacShaKeyFor(secret.getBytes());
    }

    public String generateToken(String username, String role) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("role", role); // Add role as a custom claim
        return createToken(claims, username);
    }

    private String createToken(Map<String, Object> claims, String subject) {
        return Jwts.builder()
                .setClaims(claims) // Set custom claims
                .setSubject(subject) // Set the subject (username)
                .setIssuedAt(new Date(System.currentTimeMillis())) // Set issue date
                .setExpiration(new Date(System.currentTimeMillis() + expiration)) // Set expiration date
                .signWith(getSigningKey(), SignatureAlgorithm.HS256) // Sign with HS256 algorithm and secret key
                .compact(); // Build and compact the token into a string
    }

    public String extractUsername(String token) {
        return extractClaim(token, Claims::getSubject);
    }

    public Date extractExpiration(String token) {
        return extractClaim(token, Claims::getExpiration);
    }

    public <T> T extractClaim(String token, Function<Claims, T> claimsResolver) {
        final Claims claims = extractAllClaims(token);
        return claimsResolver.apply(claims);
    }

    // Corrected: Use Jwts.parserBuilder() for parsing tokens
    private Claims extractAllClaims(String token) {
        return Jwts.parser()
                .setSigningKey(getSigningKey()) // Set the signing key for parsing
                .build() // Build the parser
                .parseClaimsJws(token) // Parse the token
                .getBody(); // Get the claims body
    }

    private Boolean isTokenExpired(String token) {
        return extractExpiration(token).before(new Date());
    }

    public Boolean validateToken(String token, String username) {
        final String extractedUsername = extractUsername(token);
        return (extractedUsername.equals(username) && !isTokenExpired(token));
    }

    public String extractRole(String token) {
        return extractClaim(token, claims -> claims.get("role", String.class));
    }
}
