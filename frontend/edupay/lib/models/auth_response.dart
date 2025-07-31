// lib/models/auth_response.dart

import 'dart:convert';

class AuthResponse {
  final String jwtToken;
  final String role;
  final int userId;
  final String username;

  AuthResponse({
    required this.jwtToken,
    required this.role,
    required this.userId,
    required this.username,
  });

  // Create an AuthResponse object from a JSON map
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      jwtToken: json['jwtToken'] as String,
      role: json['role'] as String,
      userId: json['userId'] as int,
      username: json['username'] as String,
    );
  }
}
