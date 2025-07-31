// lib/services/admin_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:edupay_app/constants/api_constants.dart';
import 'package:edupay_app/models/student.dart';
import 'package:edupay_app/models/fee.dart';
import 'package:edupay_app/models/cash_deposit_request.dart';
import 'package:edupay_app/utils/token_manager.dart';

class AdminService {
  final String _baseUrl = ApiConstants.BASE_URL;

  AdminService();

  Future<Map<String, String>> _getAuthHeaders() async {
    print('DEBUG: AdminService: _getAuthHeaders called.');
    final token = await TokenManager.getToken();
    if (token == null) {
      print('DEBUG: AdminService: Token is NULL when trying to get auth headers!');
      throw Exception('Authentication token not found. Please log in.');
    }
    print('DEBUG: AdminService: Using token for request: $token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  String _parseErrorMessage(http.Response response) {
    try {
      final dynamic decodedBody = jsonDecode(response.body);
      if (decodedBody is Map<String, dynamic> && decodedBody.containsKey('message')) {
        return decodedBody['message'] as String;
      } else if (decodedBody is String && decodedBody.isNotEmpty) {
        return decodedBody;
      } else if (decodedBody is List && decodedBody.isNotEmpty && decodedBody[0] is String) {
        return decodedBody.join(', ');
      }
    } catch (e) {
      print('DEBUG: Failed to parse error body: ${response.body}, Exception: $e');
    }
    return response.reasonPhrase ?? 'Unknown error occurred (Status: ${response.statusCode})';
  }

  // --- Student Management ---

  Future<Student> addStudent(Student student) async {
    final url = Uri.parse('$_baseUrl/admin/students');
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(student.toJson()),
      );

      if (response.statusCode == 201) {
        print('DEBUG: AdminService: addStudent success. Status: ${response.statusCode}');
        return Student.fromJson(jsonDecode(response.body));
      } else {
        final String errorMessage = _parseErrorMessage(response);
        print('DEBUG: AdminService: addStudent error. Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('DEBUG: AdminService: addStudent exception: $e');
      throw Exception('Failed to add student: $e');
    }
  }

  Future<List<Student>> getAllStudents() async {
    final url = Uri.parse('$_baseUrl/admin/students');
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        print('DEBUG: AdminService: getAllStudents success. Status: ${response.statusCode}');
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Student.fromJson(json)).toList();
      } else {
        final String errorMessage = _parseErrorMessage(response);
        print('DEBUG: AdminService: getAllStudents error. Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('DEBUG: AdminService: getAllStudents exception: $e');
      throw Exception('Failed to fetch students: $e');
    }
  }

  Future<Student> updateStudent(int id, Student student) async {
    final url = Uri.parse('$_baseUrl/admin/students/$id');
    try {
      final headers = await _getAuthHeaders();
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(student.toJson()),
      );

      if (response.statusCode == 200) {
        print('DEBUG: AdminService: updateStudent success. Status: ${response.statusCode}');
        return Student.fromJson(jsonDecode(response.body));
      } else {
        final String errorMessage = _parseErrorMessage(response);
        print('DEBUG: AdminService: updateStudent error. Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Failed to update student: $e');
    }
  }

  Future<void> deleteStudent(int id) async {
    final url = Uri.parse('$_baseUrl/admin/students/$id');
    try {
      final headers = await _getAuthHeaders();
      final response = await http.delete(url, headers: headers);

      if (response.statusCode != 204) {
        final String errorMessage = _parseErrorMessage(response);
        print('DEBUG: AdminService: deleteStudent error. Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception(errorMessage);
      }
      print('DEBUG: AdminService: deleteStudent success. Status: ${response.statusCode}');
    } catch (e) {
      print('DEBUG: AdminService: deleteStudent exception: $e');
      throw Exception('Failed to delete student: $e');
    }
  }

  // --- Fee Management ---

  // NEW METHOD: Fetches fees for a specific student (for admin view)
  Future<List<Fee>> getFeesForStudent(int studentId) async {
    final url = Uri.parse('$_baseUrl/admin/students/$studentId/fees');
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        print('DEBUG: AdminService: getFeesForStudent success. Status: ${response.statusCode}');
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Fee.fromJson(json)).toList();
      } else {
        final String errorMessage = _parseErrorMessage(response);
        print('DEBUG: AdminService: getFeesForStudent error. Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('DEBUG: AdminService: getFeesForStudent exception: $e');
      throw Exception('Failed to fetch fees for student: $e');
    }
  }

  Future<Fee> addFee(Fee fee) async {
    final url = Uri.parse('$_baseUrl/admin/fees');
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(fee.toJson()),
      );

      if (response.statusCode == 201) {
        print('DEBUG: AdminService: addFee success. Status: ${response.statusCode}');
        return Fee.fromJson(jsonDecode(response.body));
      } else {
        final String errorMessage = _parseErrorMessage(response);
        print('DEBUG: AdminService: addFee error. Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('DEBUG: AdminService: addFee exception: $e');
      throw Exception('Failed to add fee: $e');
    }
  }

  Future<Fee> updateFeeStatus(int feeId, String status) async {
    final url = Uri.parse('$_baseUrl/admin/fees/$feeId/status?status=$status');
    try {
      final headers = await _getAuthHeaders();
      final response = await http.put(url, headers: headers);

      if (response.statusCode == 200) {
        print('DEBUG: AdminService: updateFeeStatus success. Status: ${response.statusCode}');
        return Fee.fromJson(jsonDecode(response.body));
      } else {
        final String errorMessage = _parseErrorMessage(response);
        print('DEBUG: AdminService: updateFeeStatus error. Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('DEBUG: AdminService: updateFeeStatus exception: $e');
      throw Exception('Failed to update fee status: $e');
    }
  }

  Future<Fee> recordCashDeposit(CashDepositRequest request) async {
    final url = Uri.parse('$_baseUrl/admin/fees/cash-deposit');
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        url,
        headers: headers,
        body: request.toJson(),
      );

      if (response.statusCode == 200) {
        print('DEBUG: AdminService: recordCashDeposit success. Status: ${response.statusCode}');
        return Fee.fromJson(jsonDecode(response.body));
      } else {
        final String errorMessage = _parseErrorMessage(response);
        print('DEBUG: AdminService: recordCashDeposit error. Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('DEBUG: AdminService: recordCashDeposit exception: $e');
      throw Exception('Failed to record cash deposit: $e');
    }
  }
}
