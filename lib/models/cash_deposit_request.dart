// lib/models/cash_deposit_request.dart

import 'dart:convert';

class CashDepositRequest {
  final int studentId;
  final int feeId;
  final double amount;

  CashDepositRequest({
    required this.studentId,
    required this.feeId,
    required this.amount,
  });

  // Convert a CashDepositRequest object to a JSON string
  String toJson() {
    return jsonEncode({
      'studentId': studentId,
      'feeId': feeId,
      'amount': amount,
    });
  }
}
