// lib/presentation/screens/student/student_hub_view.dart
// Student-facing hub view: profile + personal fee breakdown

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:edupay_app/core/theme/hub_theme.dart';
import 'package:edupay_app/data/providers/hub_providers.dart';
import 'package:edupay_app/constants/api_constants.dart';
import 'package:edupay_app/presentation/widgets/glassmorphism_card.dart';
import 'package:edupay_app/utils/token_manager.dart';

String _fmt(double v) => '₹${NumberFormat('#,##,###').format(v.toInt())}';

// ─── Student fee data provider ────────────────────────────────────────────────
final studentFeesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final token = await TokenManager.getToken();
  if (token == null) return _mockFees;
  try {
    final user = ref.read(hubUserProvider);
    if (user == null) return _mockFees;
    final res = await http.get(
      Uri.parse('${ApiConstants.BASE_URL}/student/fees'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List)
          .cast<Map<String, dynamic>>();
    }
  } catch (_) {}
  return _mockFees;
});

const _mockFees = [
  {
    'feeType': 'Tuition Fee',
    'amount': 18000.0,
    'amountPaid': 18000.0,
    'outstandingAmount': 0.0,
    'dueDate': '2024-05-01',
    'status': 'Paid',
  },
  {
    'feeType': 'Exam Fee',
    'amount': 2500.0,
    'amountPaid': 0.0,
    'outstandingAmount': 2500.0,
    'dueDate': '2024-04-20',
    'status': 'Overdue',
  },
  {
    'feeType': 'Library Fee',
    'amount': 800.0,
    'amountPaid': 400.0,
    'outstandingAmount': 400.0,
    'dueDate': '2024-05-15',
    'status': 'Partially Paid',
  },
];

// ─── Student Hub View ─────────────────────────────────────────────────────────
class StudentHubView extends ConsumerWidget {
  const StudentHubView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(hubUserProvider);
    final feesAsync = ref.watch(studentFeesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Title ──────────────────────────────────────────────
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${user?.username ?? 'Student'} 👋',
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: HubTheme.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
                    style: const TextStyle(
                        fontSize: 12, color: HubTheme.textSecondary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ─── Profile + Summary row ───────────────────────────────
          feesAsync.when(
            data: (fees) => _StudentSummaryRow(fees: fees),
            loading: () => const _FeeSkeleton(),
            error: (_, __) => _StudentSummaryRow(fees: _mockFees),
          ),
          const SizedBox(height: 24),

          // ─── Fee breakdown ───────────────────────────────────────
          const Text('My Fee Breakdown',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: HubTheme.textPrimary)),
          const SizedBox(height: 12),
          feesAsync.when(
            data: (fees) => Column(
              children: fees
                  .map((f) => _FeeEntryCard(fee: f))
                  .toList(),
            ),
            loading: () => const _FeeSkeleton(),
            error: (_, __) => Column(
              children: _mockFees.map((f) => _FeeEntryCard(fee: f)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Summary row: quick stats + profile ───────────────────────────────────────
class _StudentSummaryRow extends StatelessWidget {
  final List<Map<String, dynamic>> fees;
  const _StudentSummaryRow({required this.fees});

  @override
  Widget build(BuildContext context) {
    final totalFees = fees.fold<double>(
        0, (s, f) => s + ((f['amount'] as num?) ?? 0).toDouble());
    final totalPaid = fees.fold<double>(
        0, (s, f) => s + ((f['amountPaid'] as num?) ?? 0).toDouble());
    final outstanding = fees.fold<double>(
        0,
        (s, f) =>
            s + ((f['outstandingAmount'] as num?) ?? 0).toDouble());
    final progress =
        totalFees > 0 ? (totalPaid / totalFees).clamp(0.0, 1.0) : 0.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile card
        Expanded(
          flex: 2,
          child: GlassmorphismCard(
            glowColor: HubTheme.violet,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: HubTheme.cyanGradient,
                        boxShadow:
                            HubTheme.neonGlow(HubTheme.cyan, radius: 10),
                      ),
                      child: const Icon(Icons.person_rounded,
                          color: Colors.black, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Naman Jain',
                            style: TextStyle(
                                color: HubTheme.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 16)),
                        SizedBox(height: 2),
                        Text('Roll No: 42 • Class 10',
                            style: TextStyle(
                                color: HubTheme.textSecondary,
                                fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: HubTheme.borderGlass),
                const SizedBox(height: 16),
                const Text('Fee Payment Progress',
                    style: TextStyle(
                        color: HubTheme.textSecondary, fontSize: 12)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: HubTheme.navySurface,
                    valueColor: const AlwaysStoppedAnimation(HubTheme.cyan),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Paid: ${_fmt(totalPaid)}',
                        style: const TextStyle(
                            color: HubTheme.green, fontSize: 11)),
                    Text(
                        '${(progress * 100).toStringAsFixed(0)}% complete',
                        style: const TextStyle(
                            color: HubTheme.textHint, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Mini KPIs
        Expanded(
          flex: 3,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: KpiCard(
                      label: 'Total Fees',
                      value: _fmt(totalFees),
                      icon: Icons.receipt_rounded,
                      gradient: HubTheme.kpiIncomeGradient,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: KpiCard(
                      label: 'Outstanding',
                      value: _fmt(outstanding),
                      icon: Icons.warning_amber_rounded,
                      gradient: HubTheme.kpiOutstandingGradient,
                      deltaPositive: false,
                      delta: outstanding > 0 ? 'Due' : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Individual fee entry card ─────────────────────────────────────────────────
class _FeeEntryCard extends StatelessWidget {
  final Map<String, dynamic> fee;
  const _FeeEntryCard({required this.fee});

  Color _statusColor(String status) {
    switch (status) {
      case 'Paid':
        return HubTheme.green;
      case 'Overdue':
        return HubTheme.red;
      case 'Partially Paid':
        return HubTheme.amber;
      default:
        return HubTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = fee['status'] as String? ?? 'Pending';
    final amount = (fee['amount'] as num? ?? 0).toDouble();
    final paid = (fee['amountPaid'] as num? ?? 0).toDouble();
    final outstanding = (fee['outstandingAmount'] as num? ?? 0).toDouble();
    final progress = amount > 0 ? (paid / amount).clamp(0.0, 1.0) : 0.0;
    final color = _statusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassmorphismCard(
        padding: const EdgeInsets.all(18),
        borderColor: color.withOpacity(0.25),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_feeIcon(fee['feeType'] as String? ?? ''),
                      color: color, size: 18),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(fee['feeType'] as String? ?? 'Fee',
                          style: const TextStyle(
                              color: HubTheme.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(
                          'Due: ${fee['dueDate'] ?? '—'}',
                          style: const TextStyle(
                              color: HubTheme.textHint, fontSize: 11)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(_fmt(amount),
                        style: const TextStyle(
                            color: HubTheme.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: color.withOpacity(0.35)),
                      ),
                      child: Text(status,
                          style: TextStyle(
                              color: color,
                              fontSize: 10,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ],
            ),
            if (outstanding > 0) ...[
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Paid: ${_fmt(paid)}',
                      style: const TextStyle(
                          color: HubTheme.textHint, fontSize: 11)),
                  Text('Outstanding: ${_fmt(outstanding)}',
                      style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w600,
                          fontSize: 11)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: HubTheme.navySurface,
                  valueColor: AlwaysStoppedAnimation(color),
                  minHeight: 5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _feeIcon(String type) {
    if (type.contains('Tuition')) return Icons.school_rounded;
    if (type.contains('Exam')) return Icons.edit_note_rounded;
    if (type.contains('Library')) return Icons.local_library_rounded;
    if (type.contains('Transport')) return Icons.directions_bus_rounded;
    return Icons.receipt_rounded;
  }
}

class _FeeSkeleton extends StatelessWidget {
  const _FeeSkeleton();
  @override
  Widget build(BuildContext context) => Container(
        height: 200,
        decoration: BoxDecoration(
          color: HubTheme.navySurface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
            child: CircularProgressIndicator(
                color: HubTheme.cyan, strokeWidth: 2)),
      );
}
