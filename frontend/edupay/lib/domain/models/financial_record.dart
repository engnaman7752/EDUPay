// lib/domain/models/financial_record.dart
// Financial record domain model

class FinancialRecord {
  final int id;
  final double amount;
  final String type;      // INCOME | EXPENSE
  final String category;  // FEES | SALARY | MAINTENANCE | EVENTS | OTHERS
  final DateTime recordDate;
  final String? notes;

  const FinancialRecord({
    required this.id,
    required this.amount,
    required this.type,
    required this.category,
    required this.recordDate,
    this.notes,
  });

  factory FinancialRecord.fromJson(Map<String, dynamic> json) {
    return FinancialRecord(
      id: json['id'] as int,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      category: json['category'] as String,
      recordDate: DateTime.parse(json['recordDate'] as String),
      notes: json['notes'] as String?,
    );
  }

  bool get isIncome => type == 'INCOME';
}

class DashboardSummary {
  final double totalIncome;
  final double totalExpenses;
  final double netBalance;
  final Map<String, double> categoryTotals;
  final List<FinancialRecord> recentActivity;

  const DashboardSummary({
    required this.totalIncome,
    required this.totalExpenses,
    required this.netBalance,
    required this.categoryTotals,
    required this.recentActivity,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    final catMap = <String, double>{};
    if (json['categoryTotals'] is Map) {
      (json['categoryTotals'] as Map).forEach((k, v) {
        catMap[k.toString()] = (v as num).toDouble();
      });
    }
    return DashboardSummary(
      totalIncome: (json['totalIncome'] as num? ?? 0).toDouble(),
      totalExpenses: (json['totalExpenses'] as num? ?? 0).toDouble(),
      netBalance: (json['netBalance'] as num? ?? 0).toDouble(),
      categoryTotals: catMap,
      recentActivity: (json['recentActivity'] as List? ?? [])
          .map((e) => FinancialRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Mock data for offline / demo mode
  static DashboardSummary get mock => DashboardSummary(
        totalIncome: 2487500,
        totalExpenses: 342000,
        netBalance: 2145500,
        categoryTotals: {
          'FEES': 1980000,
          'SALARY': 220000,
          'MAINTENANCE': 85000,
          'EVENTS': 42000,
        },
        recentActivity: [],
      );
}
