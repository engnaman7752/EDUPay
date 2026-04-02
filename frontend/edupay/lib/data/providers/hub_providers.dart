// lib/data/providers/hub_providers.dart
// Riverpod providers for the EduPay AI Hub

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:edupay_app/constants/api_constants.dart';
import 'package:edupay_app/domain/models/edupay_user.dart';
import 'package:edupay_app/domain/models/financial_record.dart';
import 'package:edupay_app/utils/token_manager.dart';

// ─── Current logged-in user ────────────────────────────────────────────────────
final hubUserProvider = StateProvider<EduPayUser?>((ref) => null);

// ─── Dashboard summary (admin/analyst/viewer) ──────────────────────────────────
final dashboardSummaryProvider = FutureProvider<DashboardSummary>((ref) async {
  final token = await TokenManager.getToken();
  if (token == null) return DashboardSummary.mock;

  try {
    final res = await http.get(
      Uri.parse('${ApiConstants.BASE_URL}/dashboard/summary'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      return DashboardSummary.fromJson(
          jsonDecode(res.body) as Map<String, dynamic>);
    }
  } catch (_) {}
  return DashboardSummary.mock;
});

// ─── Financial records list ────────────────────────────────────────────────────
final financialRecordsProvider =
    FutureProvider<List<FinancialRecord>>((ref) async {
  final token = await TokenManager.getToken();
  if (token == null) return _mockRecords;

  try {
    final res = await http.get(
      Uri.parse('${ApiConstants.BASE_URL}/financial-records'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List;
      return list
          .map((e) => FinancialRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    }
  } catch (_) {}
  return _mockRecords;
});

// ─── AI chat history ───────────────────────────────────────────────────────────
final aiChatHistoryProvider =
    StateProvider<List<Map<String, String>>>((ref) => []);

// ─── AI chat loading state ─────────────────────────────────────────────────────
final aiChatLoadingProvider = StateProvider<bool>((ref) => false);

// ─── Active nav index ──────────────────────────────────────────────────────────
final navIndexProvider = StateProvider<int>((ref) => 0);

// ─── Mock financial records ────────────────────────────────────────────────────
final _mockRecords = [
  FinancialRecord(
      id: 1, amount: 45000, type: 'INCOME', category: 'FEES',
      recordDate: DateTime(2024, 4, 1), notes: 'Term 1 fees - Class 10'),
  FinancialRecord(
      id: 2, amount: 22000, type: 'EXPENSE', category: 'SALARY',
      recordDate: DateTime(2024, 4, 2), notes: 'Staff payroll April'),
  FinancialRecord(
      id: 3, amount: 12000, type: 'INCOME', category: 'FEES',
      recordDate: DateTime(2024, 4, 3), notes: 'Class 8 fees collected'),
  FinancialRecord(
      id: 4, amount: 5500, type: 'EXPENSE', category: 'MAINTENANCE',
      recordDate: DateTime(2024, 4, 5), notes: 'Lab equipment repair'),
  FinancialRecord(
      id: 5, amount: 8000, type: 'INCOME', category: 'EVENTS',
      recordDate: DateTime(2024, 4, 7), notes: 'Annual sports day registration'),
  FinancialRecord(
      id: 6, amount: 30000, type: 'INCOME', category: 'FEES',
      recordDate: DateTime(2024, 4, 10), notes: 'Term 2 fees - Class 12'),
];
