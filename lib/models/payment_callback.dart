// lib/models/payment_callback.dart

import 'dart:convert';

class PaymentCallback {
  final String razorpayPaymentId;
  final String razorpayOrderId;
  final String razorpaySignature;
  final String status;
  final String? errorMessage;

  PaymentCallback({
    required this.razorpayPaymentId,
    required this.razorpayOrderId,
    required this.razorpaySignature,
    required this.status,
    this.errorMessage,
  });

  // Convert a PaymentCallback object to a JSON string
  String toJson() {
    return jsonEncode({
      'razorpayPaymentId': razorpayPaymentId,
      'razorpayOrderId': razorpayOrderId,
      'razorpaySignature': razorpaySignature,
      'status': status,
      'errorMessage': errorMessage,
    });
  }
}
