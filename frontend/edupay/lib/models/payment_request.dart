// lib/models/payment_request.dart

import 'dart:convert';

class PaymentRequest {
  final int studentId;
  final int? feeId; // Optional: if payment is for a specific fee
  final double amount;
  final String currency;
  final String description;

  PaymentRequest({
    required this.studentId,
    this.feeId,
    required this.amount,
    required this.currency,
    required this.description,
  });

  // Convert a PaymentRequest object to a JSON string
  String toJson() {
    return jsonEncode({
      'studentId': studentId,
      'feeId': feeId,
      'amount': amount,
      'currency': currency,
      'description': description,
    });
  }
}
