// lib/services/student_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:edupay_app/constants/api_constants.dart';
import 'package:edupay_app/models/fee.dart';
import 'package:edupay_app/models/announcement.dart';
import 'package:edupay_app/models/payment_history.dart';
import 'package:edupay_app/utils/token_manager.dart';

class StudentService {
  final String _baseUrl = ApiConstants.BASE_URL;

  // Helper to get authorization headers
  Future<Map<String, String>> _getAuthHeaders() async {
    print('DEBUG: StudentService: _getAuthHeaders called.');
    final token = await TokenManager.getToken();
    if (token == null) {
      throw Exception('Authentication token not found. Please log in.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Fetches all fee records for the currently authenticated student
  Future<List<Fee>> getMyFees() async {
    final url = Uri.parse('$_baseUrl/student/fees');
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Fee.fromJson(json)).toList();
      } else {
        final Map<String, dynamic> errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to fetch my fees');
      }
    } catch (e) {
      throw Exception('Failed to fetch my fees: $e');
    }
  }

  // Fetches all announcements relevant to students
  Future<List<Announcement>> getAnnouncements() async {
    final url = Uri.parse('$_baseUrl/student/announcements');
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Announcement.fromJson(json)).toList();
      } else {
        final Map<String, dynamic> errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to fetch announcements');
      }
    } catch (e) {
      throw Exception('Failed to fetch announcements: $e');
    }
  }

  // Fetches the payment history for the currently authenticated student
  Future<List<PaymentHistoryDto>> getPaymentHistory() async {
    final url = Uri.parse('$_baseUrl/student/payments/history');
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => PaymentHistoryDto.fromJson(json)).toList();
      } else {
        final Map<String, dynamic> errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to fetch payment history');
      }
    } catch (e) {
      throw Exception('Failed to fetch payment history: $e');
    }
  }
}
// Note: The StudentService class is designed to interact with the backend API for student-related operations.
// It includes methods to fetch fees, announcements, and payment history for the authenticated student.