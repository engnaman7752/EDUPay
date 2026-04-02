// lib/presentation/screens/admin/admin_hub_view.dart
// Admin dashboard hub view with KPIs and financial ledger table

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:edupay_app/core/theme/hub_theme.dart';
import 'package:edupay_app/data/providers/hub_providers.dart';
import 'package:edupay_app/domain/models/financial_record.dart';
import 'package:edupay_app/presentation/widgets/glassmorphism_card.dart';

// ─── Currency formatter ────────────────────────────────────────────────────────
String _fmt(double v) =>
    '₹${NumberFormat('#,##,###').format(v.toInt())}';

class AdminHubView extends ConsumerStatefulWidget {
  const AdminHubView({super.key});

  @override
  ConsumerState<AdminHubView> createState() => _AdminHubViewState();
}

class _AdminHubViewState extends ConsumerState<AdminHubView> {
  // Table state
  int _rowsPerPage = 6;
  String _filterType = 'ALL';
  String _searchQuery = '';
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  // Sorting key resolver
  Comparable _sortKey(FinancialRecord r, int col) {
    switch (col) {
      case 0: return r.recordDate.millisecondsSinceEpoch;
      case 1: return r.type;
      case 2: return r.category;
      case 3: return r.amount;
      default: return r.recordDate.millisecondsSinceEpoch;
    }
  }

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final recordsAsync = ref.watch(financialRecordsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Page Title ──────────────────────────────────────────
          const Text('Finance Dashboard',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: HubTheme.textPrimary)),
          const SizedBox(height: 4),
          Text(
            DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
            style: const TextStyle(
                fontSize: 12, color: HubTheme.textSecondary),
          ),
          const SizedBox(height: 24),

          // ─── KPI Row ─────────────────────────────────────────────
          summaryAsync.when(
            data: (s) => _KpiRow(summary: s),
            loading: () => const _KpiSkeleton(),
            error: (_, __) => _KpiRow(summary: DashboardSummary.mock),
          ),
          const SizedBox(height: 28),

          // ─── Financial Ledger ────────────────────────────────────
          recordsAsync.when(
            data: (records) => _LedgerCard(
              records: records,
              filterType: _filterType,
              searchQuery: _searchQuery,
              sortColumnIndex: _sortColumnIndex,
              sortAscending: _sortAscending,
              rowsPerPage: _rowsPerPage,
              sortKey: _sortKey,
              onFilterChanged: (v) => setState(() => _filterType = v),
              onSearch: (v) => setState(() => _searchQuery = v),
              onSort: (col, asc) => setState(() {
                _sortColumnIndex = col;
                _sortAscending = asc;
              }),
            ),
            loading: () => const _TableSkeleton(),
            error: (_, __) => const Center(
                child: Text('Could not load records',
                    style: TextStyle(color: HubTheme.red))),
          ),
        ],
      ),
    );
  }
}

// ─── KPI Row ──────────────────────────────────────────────────────────────────
class _KpiRow extends StatelessWidget {
  final DashboardSummary summary;
  const _KpiRow({required this.summary});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final w = (constraints.maxWidth - 32) / 3;
      return Row(
        children: [
          SizedBox(
            width: w,
            child: KpiCard(
              label: 'Total Revenue',
              value: _fmt(summary.totalIncome),
              delta: '+12.4%',
              deltaPositive: true,
              icon: Icons.trending_up_rounded,
              gradient: HubTheme.kpiIncomeGradient,
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: w,
            child: KpiCard(
              label: 'Outstanding Fees',
              value: _fmt(summary.totalExpenses),
              delta: '-5.2%',
              deltaPositive: false,
              icon: Icons.account_balance_wallet_rounded,
              gradient: HubTheme.kpiOutstandingGradient,
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: w,
            child: KpiCard(
              label: 'Net Balance',
              value: _fmt(summary.netBalance),
              delta: '+8.1%',
              deltaPositive: true,
              icon: Icons.analytics_rounded,
              gradient: HubTheme.kpiStudentsGradient,
            ),
          ),
        ],
      );
    });
  }
}

// ─── Ledger Card ──────────────────────────────────────────────────────────────
class _LedgerCard extends StatelessWidget {
  final List<FinancialRecord> records;
  final String filterType;
  final String searchQuery;
  final int sortColumnIndex;
  final bool sortAscending;
  final int rowsPerPage;
  final Comparable Function(FinancialRecord, int) sortKey;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<String> onSearch;
  final void Function(int, bool) onSort;

  const _LedgerCard({
    required this.records,
    required this.filterType,
    required this.searchQuery,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.rowsPerPage,
    required this.sortKey,
    required this.onFilterChanged,
    required this.onSearch,
    required this.onSort,
  });

  List<FinancialRecord> get _filtered {
    var list = records.where((r) {
      if (filterType != 'ALL' && r.type != filterType) return false;
      if (searchQuery.isNotEmpty &&
          !r.category
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) &&
          !(r.notes ?? '')
              .toLowerCase()
              .contains(searchQuery.toLowerCase())) return false;
      return true;
    }).toList();

    list.sort((a, b) {
      final ka = sortKey(a, sortColumnIndex);
      final kb = sortKey(b, sortColumnIndex);
      final cmp = ka.compareTo(kb);
      return sortAscending ? cmp : -cmp;
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final data = _filtered;

    return GlassmorphismCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar
          Row(
            children: [
              const Text('Financial Ledger',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: HubTheme.textPrimary)),
              const Spacer(),
              // Search
              SizedBox(
                width: 200,
                height: 36,
                child: TextField(
                  style: const TextStyle(
                      color: HubTheme.textPrimary, fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: const TextStyle(
                        color: HubTheme.textHint, fontSize: 12),
                    prefixIcon: const Icon(Icons.search,
                        color: HubTheme.textHint, size: 16),
                    filled: true,
                    fillColor: HubTheme.navySurface,
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide:
                          const BorderSide(color: HubTheme.borderGlass),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide:
                          const BorderSide(color: HubTheme.borderGlass),
                    ),
                  ),
                  onChanged: onSearch,
                ),
              ),
              const SizedBox(width: 12),
              // Filter chips
              ..._filterChips(),
            ],
          ),
          const SizedBox(height: 16),

          // Table
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Theme(
              data: Theme.of(context).copyWith(
                dataTableTheme: DataTableThemeData(
                  headingRowColor:
                      WidgetStateProperty.all(HubTheme.navySurface),
                  dataRowColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.hovered)) {
                      return HubTheme.cyan.withOpacity(0.04);
                    }
                    return Colors.transparent;
                  }),
                  dividerThickness: 0.5,
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  sortColumnIndex: sortColumnIndex,
                  sortAscending: sortAscending,
                  headingRowHeight: 44,
                  dataRowMaxHeight: 52,
                  columnSpacing: 24,
                  columns: [
                    _col('Date', 0),
                    _col('Type', 1),
                    _col('Category', 2),
                    _col('Amount', 3),
                    const DataColumn(
                        label: Text('Notes',
                            style: TextStyle(
                                color: HubTheme.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600))),
                  ],
                  rows: data.take(rowsPerPage).map((r) {
                    return DataRow(cells: [
                      DataCell(Text(
                          DateFormat('dd MMM yy').format(r.recordDate),
                          style: const TextStyle(
                              color: HubTheme.textSecondary,
                              fontSize: 12))),
                      DataCell(_TypeBadge(type: r.type)),
                      DataCell(Text(r.category,
                          style: const TextStyle(
                              color: HubTheme.textPrimary,
                              fontSize: 12))),
                      DataCell(Text(
                        _fmt(r.amount),
                        style: TextStyle(
                          color: r.isIncome ? HubTheme.green : HubTheme.red,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      )),
                      DataCell(Text(r.notes ?? '—',
                          style: const TextStyle(
                              color: HubTheme.textHint, fontSize: 11))),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ),
          // Pagination footer
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Showing ${data.take(rowsPerPage).length} of ${data.length} records',
                  style: const TextStyle(
                      color: HubTheme.textHint, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  DataColumn _col(String label, int index) => DataColumn(
        label: Text(label,
            style: const TextStyle(
                color: HubTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
        onSort: onSort,
      );

  List<Widget> _filterChips() {
    return ['ALL', 'INCOME', 'EXPENSE'].map((f) {
      final active = filterType == f;
      return GestureDetector(
        onTap: () => onFilterChanged(f),
        child: Container(
          margin: const EdgeInsets.only(left: 6),
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: active
                ? HubTheme.cyan.withOpacity(0.15)
                : HubTheme.navySurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: active
                  ? HubTheme.cyan.withOpacity(0.5)
                  : HubTheme.borderGlass,
            ),
          ),
          child: Text(
            f,
            style: TextStyle(
              color: active ? HubTheme.cyan : HubTheme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }).toList();
  }
}

class _TypeBadge extends StatelessWidget {
  final String type;
  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final isIncome = type == 'INCOME';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: (isIncome ? HubTheme.green : HubTheme.red).withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (isIncome ? HubTheme.green : HubTheme.red).withOpacity(0.35),
        ),
      ),
      child: Text(
        type,
        style: TextStyle(
          color: isIncome ? HubTheme.green : HubTheme.red,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

// ─── Skeleton loaders ──────────────────────────────────────────────────────────
class _KpiSkeleton extends StatelessWidget {
  const _KpiSkeleton();
  @override
  Widget build(BuildContext context) => Row(
        children: List.generate(
            3,
            (_) => Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    height: 130,
                    decoration: BoxDecoration(
                      color: HubTheme.navySurface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                )),
      );
}

class _TableSkeleton extends StatelessWidget {
  const _TableSkeleton();
  @override
  Widget build(BuildContext context) => Container(
        height: 300,
        decoration: BoxDecoration(
          color: HubTheme.navySurface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
            child: CircularProgressIndicator(
                color: HubTheme.cyan, strokeWidth: 2)),
      );
}
