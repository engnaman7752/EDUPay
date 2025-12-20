// lib/models/user.dart

import 'dart:convert';

class User {
  final int? id;
  final String username;
  final String password; // Note: This will be hashed on the backend
  final String role;

  User({
    this.id,
    required this.username,
    required this.password,
    required this.role,
  });

  // Create a User object from a JSON map
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int?,
      username: json['username'] as String,
      password: json['password'] as String,
      role: json['role'] as String,
    );
  }

  // Convert a User object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'role': role,
    };
  }
}
