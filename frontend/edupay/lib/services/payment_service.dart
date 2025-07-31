// lib/services/payment_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:edupay_app/constants/api_constants.dart';
import 'package:edupay_app/models/payment_request.dart';
import 'package:edupay_app/models/payment_callback.dart';
import 'package:edupay_app/utils/token_manager.dart';

class PaymentService {
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

  // Initiates an online payment by creating an order with the backend
  Future<Map<String, dynamic>> initiatePayment(PaymentRequest request) async {
    final url = Uri.parse('$_baseUrl/payments/initiate');
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        url,
        headers: headers,
        body: request.toJson(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Backend returns gateway order details
      } else {
        final Map<String, dynamic> errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to initiate payment');
      }
    } catch (e) {
      throw Exception('Failed to initiate payment: $e');
    }
  }

  // Handles the callback from the payment gateway (e.g., after Razorpay payment)
  Future<String> handlePaymentCallback(PaymentCallback callback) async {
    final url = Uri.parse('$_baseUrl/payments/callback');
    try {
      // Note: Callbacks might not always have an Authorization header depending on setup.
      // If your backend endpoint for callback is public, no auth header is needed.
      // If it's secured, you'd need a different authentication mechanism (e.g., API key or specific token).
      // For now, assuming it's secured by JWT as other endpoints.
      final headers = await _getAuthHeaders(); 
      final response = await http.post(
        url,
        headers: headers,
        body: callback.toJson(),
      );

      if (response.statusCode == 200) {
        return response.body; // Expecting a success message
      } else {
        final Map<String, dynamic> errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to process payment callback');
      }
    } catch (e) {
      throw Exception('Failed to process payment callback: $e');
    }
  }

  // Verifies payment status with the backend (which then queries the gateway)
  Future<String> verifyPaymentStatus(String paymentId) async {
    final url = Uri.parse('$_baseUrl/payments/verify/$paymentId');
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return response.body; // Expecting a status string
      } else {
        final Map<String, dynamic> errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to verify payment status');
      }
    } catch (e) {
      throw Exception('Failed to verify payment status: $e');
    }
  }
}
// Note: The PaymentService class is designed to handle payment-related operations,
// including initiating online payments, handling payment callbacks, and verifying payment status.