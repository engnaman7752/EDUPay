// lib/models/login_request.dart

import 'dart:convert';

class LoginRequest {
  final String username;
  final String password;

  LoginRequest({
    required this.username,
    required this.password,
  });

  // Convert a LoginRequest object to a JSON string
  String toJson() {
    return jsonEncode({
      'username': username,
      'password': password,
    });
  }
}
