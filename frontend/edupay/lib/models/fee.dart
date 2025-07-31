// lib/models/fee.dart

import 'dart:convert';

class Fee {
  final int? id;
  final String feeType;
  final double amount;
  final double amountPaid;
  final double outstandingAmount;
  final DateTime dueDate;
  final String status;
  final int? studentId; // Link to the student

  Fee({
    this.id,
    required this.feeType,
    required this.amount,
    required this.amountPaid,
    required this.outstandingAmount,
    required this.dueDate,
    required this.status,
    this.studentId,
  });

  // Create a Fee object from a JSON map
  factory Fee.fromJson(Map<String, dynamic> json) {
    return Fee(
      id: json['id'] as int?,
      feeType: json['feeType'] as String,
      amount: json['amount'] as double,
      amountPaid: json['amountPaid'] as double,
      outstandingAmount: json['outstandingAmount'] as double,
      dueDate: DateTime.parse(json['dueDate'] as String),
      status: json['status'] as String,
      studentId: json['studentId'] as int?,
    );
  }

  // Convert a Fee object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'feeType': feeType,
      'amount': amount,
      'amountPaid': amountPaid,
      'outstandingAmount': outstandingAmount,
      'dueDate': dueDate.toIso8601String().split('T').first, // Format as 'yyyy-MM-dd' for LocalDate
      'status': status,
      'studentId': studentId,
    };
  }
}
