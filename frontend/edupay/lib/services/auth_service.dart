// lib/services/auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:edupay_app/constants/api_constants.dart';
import 'package:edupay_app/models/login_request.dart';
import 'package:edupay_app/models/auth_response.dart';
import 'package:edupay_app/utils/token_manager.dart';

class AuthService {
  final String _baseUrl = ApiConstants.BASE_URL;

  // Handles user login (for both admin and student)
  Future<AuthResponse> login(String username, String password) async {
    final url = Uri.parse('$_baseUrl/auth/login');
    final loginRequest = LoginRequest(username: username, password: password);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: loginRequest.toJson(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(responseBody);
        
        // Save auth data locally upon successful login
        await TokenManager.saveAuthData(
          token: authResponse.jwtToken,
          role: authResponse.role,
          userId: authResponse.userId,
          username: authResponse.username,
        );
        return authResponse;
      } else {
        final Map<String, dynamic> errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to login');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  // Handles admin self-registration
  Future<String> registerAdmin(String username, String password) async {
    final url = Uri.parse('$_baseUrl/auth/register/admin');
    final loginRequest = LoginRequest(username: username, password: password);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: loginRequest.toJson(),
      );

      if (response.statusCode == 201) {
        return response.body; // Expecting a simple success message string
      } else {
        final Map<String, dynamic> errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to register admin');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  // Handles user logout by clearing local auth data
  Future<void> logout() async {
    await TokenManager.clearAuthData();
  }
}
// Note: The AuthService class is designed