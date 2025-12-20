// lib/models/payment_history_dto.dart

import 'dart:convert';

class PaymentHistoryDto {
  final int? id;
  final String transactionId;
  final double amount;
  final String paymentMethod;
  final DateTime paymentDate;
  final String status;
  final String studentName;
  final String? feeType;
  final String? recordedByAdminName;

  PaymentHistoryDto({
    this.id,
    required this.transactionId,
    required this.amount,
    required this.paymentMethod,
    required this.paymentDate,
    required this.status,
    required this.studentName,
    this.feeType,
    this.recordedByAdminName,
  });

  // Create a PaymentHistoryDto object from a JSON map
  factory PaymentHistoryDto.fromJson(Map<String, dynamic> json) {
    return PaymentHistoryDto(
      id: json['id'] as int?,
      transactionId: json['transactionId'] as String,
      amount: (json['amount'] as num).toDouble(), // Ensure double conversion
      paymentMethod: json['paymentMethod'] as String,
      paymentDate: DateTime.parse(json['paymentDate'] as String),
      status: json['status'] as String,
      studentName: json['studentName'] as String,
      feeType: json['feeType'] as String?,
      recordedByAdminName: json['recordedByAdminName'] as String?,
    );
  }
}