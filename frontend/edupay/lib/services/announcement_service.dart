// lib/services/announcement_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:edupay_app/models/announcement.dart';
import 'package:edupay_app/utils/token_manager.dart';

import '../constants/api_constants.dart';


class AnnouncementService {
  final String _baseUrl = ApiConstants.BASE_URL;

  // Helper to get authorization headers
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await TokenManager.getToken();
    if (token == null) {
      throw Exception('Authentication token not found. Please log in.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // --- Admin-specific Announcement methods ---

  // Creates a new announcement (Admin only)
  Future<Announcement> createAnnouncement(Announcement announcement) async {
    final url = Uri.parse('$_baseUrl/admin/announcements');
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(announcement.toJson()),
      );

      if (response.statusCode == 201) {
        return Announcement.fromJson(jsonDecode(response.body));
      } else {
        final Map<String, dynamic> errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to create announcement');
      }
    } catch (e) {
      throw Exception('Failed to create announcement: $e');
    }
  }

  // Updates an existing announcement (Admin only)
  Future<Announcement> updateAnnouncement(int id, Announcement announcement) async {
    final url = Uri.parse('$_baseUrl/admin/announcements/$id');
    try {
      final headers = await _getAuthHeaders();
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(announcement.toJson()),
      );

      if (response.statusCode == 200) {
        return Announcement.fromJson(jsonDecode(response.body));
      } else {
        final Map<String, dynamic> errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to update announcement');
      }
    } catch (e) {
      throw Exception('Failed to update announcement: $e');
    }
  }

  // Deletes an announcement (Admin only)
  Future<void> deleteAnnouncement(int id) async {
    final url = Uri.parse('$_baseUrl/admin/announcements/$id');
    try {
      final headers = await _getAuthHeaders();
      final response = await http.delete(url, headers: headers);

      if (response.statusCode != 204) { // 204 No Content is expected for successful delete
        final Map<String, dynamic> errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to delete announcement');
      }
    } catch (e) {
      throw Exception('Failed to delete announcement: $e');
    }
  }

  // Fetches announcements created by the current admin (Admin only)
  Future<List<Announcement>> getMyAnnouncements() async {
    final url = Uri.parse('$_baseUrl/admin/announcements/my-announcements');
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Announcement.fromJson(json)).toList();
      } else {
        final Map<String, dynamic> errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to fetch my announcements');
      }
    } catch (e) {
      throw Exception('Failed to fetch my announcements: $e');
    }
  }

  // --- Student-specific Announcement methods (also used by admin for general view) ---

  // Fetches all announcements relevant to students (or all public announcements)
  Future<List<Announcement>> getAnnouncementsForStudents() async {
    // Note: This endpoint is accessible by students via /api/student/announcements
    // and by admins via /api/admin/announcements (if you have a general endpoint)
    // For simplicity, we'll use the student endpoint here for general announcements.
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
}
// Note: The AnnouncementService class is designed to handle announcement-related operations,
// including creating, updating, deleting, and fetching announcements for both admins and students.