// lib/services/ai_chat_service.dart
// Service for communicating with the AI chat backend

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:edupay_app/constants/api_constants.dart';
import 'package:edupay_app/models/ai_chat_response.dart';
import 'package:edupay_app/utils/token_manager.dart';

class AIChatService {
  /// Send a question to the AI and get a RAG-powered response
  Future<AIChatResponse> askQuestion(String question) async {
    final token = await TokenManager.getToken();
    if (token == null) {
      throw Exception('Not authenticated. Please log in again.');
    }

    final url = Uri.parse('${ApiConstants.BASE_URL}/ai/chat');

    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'question': question}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return AIChatResponse.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please log in again.');
      } else {
        throw Exception('AI service error: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to connect to AI service. Please try again.');
    }
  }
}
