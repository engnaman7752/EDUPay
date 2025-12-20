// lib/models/payment.dart

import 'dart:convert';

class Payment {
  final int? id;
  final String transactionId;
  final double amount;
  final String paymentMethod;
  final DateTime paymentDate;
  final String status;
  final String? gatewayPaymentId;
  final String? gatewayOrderId;
  final int? studentId; // Link to the student
  final int? recordedById; // Link to the admin who recorded it (for cash)

  Payment({
    this.id,
    required this.transactionId,
    required this.amount,
    required this.paymentMethod,
    required this.paymentDate,
    required this.status,
    this.gatewayPaymentId,
    this.gatewayOrderId,
    this.studentId,
    this.recordedById,
  });

  // Create a Payment object from a JSON map
  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as int?,
      transactionId: json['transactionId'] as String,
      amount: json['amount'] as double,
      paymentMethod: json['paymentMethod'] as String,
      paymentDate: DateTime.parse(json['paymentDate'] as String),
      status: json['status'] as String,
      gatewayPaymentId: json['gatewayPaymentId'] as String?,
      gatewayOrderId: json['gatewayOrderId'] as String?,
      studentId: json['studentId'] as int?,
      recordedById: json['recordedById'] as int?,
    );
  }

  // Convert a Payment object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transactionId': transactionId,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'paymentDate': paymentDate.toIso8601String(), // Send as ISO 8601 string
      'status': status,
      'gatewayPaymentId': gatewayPaymentId,
      'gatewayOrderId': gatewayOrderId,
      'studentId': studentId,
      'recordedById': recordedById,
    };
  }
}
// Note: The Payment class is designed