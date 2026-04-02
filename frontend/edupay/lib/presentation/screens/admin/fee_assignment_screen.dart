// lib/presentation/screens/admin/fee_assignment_screen.dart
// Admin fee assignment — ALL / CLASS / STUDENT + 1% late fee penalty

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:edupay_app/core/theme/hub_theme.dart';
import 'package:edupay_app/constants/api_constants.dart';
import 'package:edupay_app/presentation/widgets/glassmorphism_card.dart';
import 'package:edupay_app/utils/token_manager.dart';

enum FeeScope { ALL, CLASS, STUDENT }

class FeeAssignmentScreen extends StatefulWidget {
  const FeeAssignmentScreen({super.key});

  @override
  State<FeeAssignmentScreen> createState() => _FeeAssignmentScreenState();
}

class _FeeAssignmentScreenState extends State<FeeAssignmentScreen>
    with SingleTickerProviderStateMixin {
  // ─── Assign form ───────────────────────────────────────────────────────────
  final _assignFormKey = GlobalKey<FormState>();
  FeeScope _scope = FeeScope.ALL;
  int _selectedClass = 10;
  final _studentIdCtrl     = TextEditingController();
  String _feeType          = 'Tuition Fee';
  final _customFeeCtrl     = TextEditingController();
  final _amountCtrl        = TextEditingController();
  DateTime _dueDate        = DateTime.now().add(const Duration(days: 30));

  // ─── Late fee form ─────────────────────────────────────────────────────────
  FeeScope _lateScope = FeeScope.ALL;
  int _lateClass             = 10;
  final _lateStudentIdCtrl   = TextEditingController();

  // ─── State ─────────────────────────────────────────────────────────────────
  bool _assigning  = false;
  bool _lateFee    = false;
  Map<String, dynamic>? _assignResult;
  Map<String, dynamic>? _lateFeeResult;
  String? _assignError;
  String? _lateFeeError;

  // ─── Tab ───────────────────────────────────────────────────────────────────
  int _tab = 0; // 0 = Assign, 1 = Late Fee

  late AnimationController _successAnim;

  static const _feeTypes = [
    'Tuition Fee', 'Exam Fee', 'Library Fee',
    'Transport Fee', 'Sports Fee', 'Lab Fee', 'Other'
  ];

  @override
  void initState() {
    super.initState();
    _successAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
  }

  @override
  void dispose() {
    _studentIdCtrl.dispose();
    _customFeeCtrl.dispose();
    _amountCtrl.dispose();
    _lateStudentIdCtrl.dispose();
    _successAnim.dispose();
    super.dispose();
  }

  // ─── Assign fees API call ──────────────────────────────────────────────────
  Future<void> _assign() async {
    if (!_assignFormKey.currentState!.validate()) return;
    setState(() { _assigning = true; _assignResult = null; _assignError = null; });

    final effectiveFeeType = _feeType == 'Other' ? _customFeeCtrl.text.trim() : _feeType;
    final body = <String, dynamic>{
      'scopeType': _scope.name,
      'feeType':   effectiveFeeType,
      'amount':    double.tryParse(_amountCtrl.text.trim()) ?? 0,
      'dueDate':   DateFormat('yyyy-MM-dd').format(_dueDate),
    };
    if (_scope == FeeScope.CLASS)   body['standard']  = '$_selectedClass';
    if (_scope == FeeScope.STUDENT) body['studentId'] = _studentIdCtrl.text.trim();

    try {
      final token = await TokenManager.getToken();
      final res = await http.post(
        Uri.parse('${ApiConstants.BASE_URL}/fees/assign'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode(body),
      );
      if (res.statusCode == 200) {
        setState(() => _assignResult = jsonDecode(res.body) as Map<String, dynamic>);
        _successAnim.forward(from: 0);
        _amountCtrl.clear();
        _studentIdCtrl.clear();
      } else {
        final e = jsonDecode(res.body);
        setState(() => _assignError = e['message'] ?? 'Assignment failed');
      }
    } catch (e) {
      setState(() => _assignError = 'Connection error: $e');
    } finally {
      setState(() => _assigning = false);
    }
  }

  // ─── Apply late fee API call ───────────────────────────────────────────────
  Future<void> _applyLate() async {
    setState(() { _lateFee = true; _lateFeeResult = null; _lateFeeError = null; });

    String url = '${ApiConstants.BASE_URL}/fees/apply-late-charge?scopeType=${_lateScope.name}';
    if (_lateScope == FeeScope.CLASS)   url += '&standard=$_lateClass';
    if (_lateScope == FeeScope.STUDENT) url += '&studentId=${_lateStudentIdCtrl.text.trim()}';

    try {
      final token = await TokenManager.getToken();
      final res = await http.post(Uri.parse(url),
          headers: {'Authorization': 'Bearer $token'});
      if (res.statusCode == 200) {
        setState(() => _lateFeeResult = jsonDecode(res.body) as Map<String, dynamic>);
      } else {
        final e = jsonDecode(res.body);
        setState(() => _lateFeeError = e['message'] ?? 'Failed');
      }
    } catch (e) {
      setState(() => _lateFeeError = 'Connection error: $e');
    } finally {
      setState(() => _lateFee = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── Page header ──────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: HubTheme.kpiIncomeGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: HubTheme.neonGlow(HubTheme.cyan, radius: 8),
                ),
                child: const Icon(Icons.receipt_long_rounded,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Fee Management',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
                          color: HubTheme.textPrimary)),
                  Text('Assign fees or apply 1% late charge',
                      style: TextStyle(fontSize: 12, color: HubTheme.textSecondary)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ─── Tabs ─────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              _TabChip(
                label: '📋 Assign Fees',
                active: _tab == 0,
                onTap: () => setState(() => _tab = 0),
              ),
              const SizedBox(width: 10),
              _TabChip(
                label: '⚠️ Late Charge (1%)',
                active: _tab == 1,
                onTap: () => setState(() => _tab = 1),
                activeColor: HubTheme.amber,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ─── Tab content ──────────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _tab == 0 ? _buildAssignTab() : _buildLateChargeTab(),
          ),
        ),
      ],
    );
  }

  // ─── ASSIGN TAB ───────────────────────────────────────────────────────────
  Widget _buildAssignTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Scope
        _SectionLabel('WHO SHOULD PAY?'),
        const SizedBox(height: 10),
        _ScopePicker(
          selected: _scope,
          onChanged: (s) => setState(() => _scope = s),
        ),
        const SizedBox(height: 16),

        // Scope detail
        if (_scope == FeeScope.CLASS) ...[
          _SectionLabel('SELECT CLASS'),
          const SizedBox(height: 8),
          _ClassGrid(selected: _selectedClass,
              onChanged: (v) => setState(() => _selectedClass = v)),
          const SizedBox(height: 16),
        ],
        if (_scope == FeeScope.STUDENT) ...[
          _SectionLabel('STUDENT ID'),
          const SizedBox(height: 8),
          _DTextField(
            controller: _studentIdCtrl,
            hint: 'e.g. S042',
            icon: Icons.badge_rounded,
            validator: (v) => (v == null || v.isEmpty) ? 'Enter student ID' : null,
          ),
          const SizedBox(height: 16),
        ],

        // Form
        _SectionLabel('FEE DETAILS'),
        const SizedBox(height: 10),
        GlassmorphismCard(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _assignFormKey,
            child: Column(
              children: [
                // Fee type dropdown
                DropdownButtonFormField<String>(
                  value: _feeType,
                  dropdownColor: HubTheme.navySurface,
                  style: const TextStyle(color: HubTheme.textPrimary, fontSize: 13),
                  decoration: _inputDeco('Fee Type', Icons.category_rounded),
                  items: _feeTypes.map((t) =>
                      DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setState(() => _feeType = v!),
                ),
                if (_feeType == 'Other') ...[
                  const SizedBox(height: 12),
                  _DTextField(
                    controller: _customFeeCtrl,
                    hint: 'Custom fee type name',
                    icon: Icons.edit_rounded,
                    validator: (v) => (v == null || v.isEmpty) ? 'Enter fee type' : null,
                  ),
                ],
                const SizedBox(height: 12),

                // Amount
                _DTextField(
                  controller: _amountCtrl,
                  hint: 'Amount (₹)',
                  icon: Icons.currency_rupee_rounded,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter amount';
                    final d = double.tryParse(v);
                    if (d == null || d <= 0) return 'Enter a valid positive amount';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Due date
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: HubTheme.navySurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: HubTheme.borderGlass),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            color: HubTheme.textHint, size: 18),
                        const SizedBox(width: 12),
                        Text('Due Date: ${DateFormat('dd MMM yyyy').format(_dueDate)}',
                            style: const TextStyle(
                                color: HubTheme.textPrimary, fontSize: 13)),
                        const Spacer(),
                        const Icon(Icons.chevron_right_rounded,
                            color: HubTheme.textHint, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Preview
        _AssignPreview(
            scope: _scope,
            standard: _selectedClass,
            studentId: _studentIdCtrl.text,
            feeType: _feeType == 'Other' ? (_customFeeCtrl.text.isEmpty ? 'Custom' : _customFeeCtrl.text) : _feeType,
            amount: double.tryParse(_amountCtrl.text) ?? 0,
            dueDate: _dueDate),
        const SizedBox(height: 16),

        // Assign button
        _GradientButton(
          label: 'Assign Fee',
          icon: Icons.add_circle_outline_rounded,
          loading: _assigning,
          onTap: _assign,
          gradient: HubTheme.kpiIncomeGradient,
          glowColor: HubTheme.cyan,
        ),
        const SizedBox(height: 16),

        // Result
        if (_assignResult != null)
          ScaleTransition(
            scale: CurvedAnimation(parent: _successAnim, curve: Curves.elasticOut),
            child: _ResultCard(data: _assignResult!, isSuccess: true),
          ),
        if (_assignError != null)
          _ErrorCard(message: _assignError!),
        const SizedBox(height: 24),
      ],
    );
  }

  // ─── LATE CHARGE TAB ──────────────────────────────────────────────────────
  Widget _buildLateChargeTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Info banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: HubTheme.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: HubTheme.amber.withOpacity(0.35)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: HubTheme.amber, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('1% Late Fee Penalty',
                        style: TextStyle(color: HubTheme.amber,
                            fontWeight: FontWeight.w700, fontSize: 13)),
                    SizedBox(height: 2),
                    Text(
                        'Applies 1% of the outstanding amount as a late charge to every '
                        'overdue fee (past due date, with outstanding balance). '
                        'Can be scoped to all students, one class, or one student.',
                        style: TextStyle(color: HubTheme.textSecondary, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        _SectionLabel('APPLY LATE CHARGE TO'),
        const SizedBox(height: 10),
        _ScopePicker(
          selected: _lateScope,
          onChanged: (s) => setState(() => _lateScope = s),
          activeColor: HubTheme.amber,
        ),
        const SizedBox(height: 16),

        if (_lateScope == FeeScope.CLASS) ...[
          _SectionLabel('SELECT CLASS'),
          const SizedBox(height: 8),
          _ClassGrid(selected: _lateClass,
              onChanged: (v) => setState(() => _lateClass = v),
              activeColor: HubTheme.amber),
          const SizedBox(height: 16),
        ],
        if (_lateScope == FeeScope.STUDENT) ...[
          _SectionLabel('STUDENT ID'),
          const SizedBox(height: 8),
          _DTextField(
            controller: _lateStudentIdCtrl,
            hint: 'e.g. S042',
            icon: Icons.badge_rounded,
          ),
          const SizedBox(height: 16),
        ],

        _GradientButton(
          label: 'Apply 1% Late Charge',
          icon: Icons.warning_amber_rounded,
          loading: _lateFee,
          onTap: _applyLate,
          gradient: const LinearGradient(
              colors: [Color(0xFFFF6B35), Color(0xFFFFB300)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          glowColor: HubTheme.amber,
        ),
        const SizedBox(height: 16),

        if (_lateFeeResult != null)
          _LateFeeResultCard(data: _lateFeeResult!),
        if (_lateFeeError != null)
          _ErrorCard(message: _lateFeeError!),
        const SizedBox(height: 24),
      ],
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: HubTheme.cyan),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  InputDecoration _inputDeco(String label, IconData icon) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: HubTheme.textHint, fontSize: 13),
        prefixIcon: Icon(icon, color: HubTheme.textHint, size: 18),
        filled: true,
        fillColor: HubTheme.navySurface,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: HubTheme.borderGlass)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: HubTheme.borderGlass)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: HubTheme.cyan, width: 1.5)),
      );
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _ScopePicker extends StatelessWidget {
  final FeeScope selected;
  final ValueChanged<FeeScope> onChanged;
  final Color? activeColor;
  const _ScopePicker({required this.selected, required this.onChanged, this.activeColor});

  @override
  Widget build(BuildContext context) {
    final color = activeColor ?? HubTheme.cyan;
    return Row(
      children: FeeScope.values.map((s) {
        final active = selected == s;
        final (icon, label) = switch (s) {
          FeeScope.ALL => (Icons.people_alt_rounded, 'All Students'),
          FeeScope.CLASS => (Icons.class_outlined, 'By Class'),
          FeeScope.STUDENT => (Icons.person_rounded, 'One Student'),
        };
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(s),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              decoration: BoxDecoration(
                color: active ? color.withOpacity(0.12) : HubTheme.navySurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: active ? color : HubTheme.borderGlass,
                    width: active ? 1.5 : 1),
                boxShadow: active ? HubTheme.neonGlow(color, radius: 6) : null,
              ),
              child: Column(
                children: [
                  Icon(icon,
                      color: active ? color : HubTheme.textSecondary, size: 22),
                  const SizedBox(height: 6),
                  Text(label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: active ? HubTheme.textPrimary : HubTheme.textSecondary,
                          fontSize: 11,
                          fontWeight: active ? FontWeight.w600 : FontWeight.w400)),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ClassGrid extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;
  final Color? activeColor;
  const _ClassGrid({required this.selected, required this.onChanged, this.activeColor});

  @override
  Widget build(BuildContext context) {
    final color = activeColor ?? HubTheme.cyan;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(12, (i) {
        final cls = i + 1;
        final active = cls == selected;
        return GestureDetector(
          onTap: () => onChanged(cls),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: active ? color.withOpacity(0.15) : HubTheme.navySurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: active ? color : HubTheme.borderGlass,
                  width: active ? 1.5 : 1),
              boxShadow: active ? HubTheme.neonGlow(color, radius: 5) : null,
            ),
            child: Center(
              child: Text('$cls',
                  style: TextStyle(
                      color: active ? color : HubTheme.textSecondary,
                      fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                      fontSize: 15)),
            ),
          ),
        );
      }),
    );
  }
}

class _AssignPreview extends StatelessWidget {
  final FeeScope scope;
  final int standard;
  final String studentId;
  final String feeType;
  final double amount;
  final DateTime dueDate;
  const _AssignPreview({
    required this.scope, required this.standard, required this.studentId,
    required this.feeType, required this.amount, required this.dueDate,
  });

  @override
  Widget build(BuildContext context) {
    final target = switch (scope) {
      FeeScope.ALL => 'All Students',
      FeeScope.CLASS => 'Class $standard',
      FeeScope.STUDENT => studentId.isEmpty ? 'Student (enter ID)' : 'Student $studentId',
    };
    final amtStr = amount > 0
        ? '₹${NumberFormat('#,##,###').format(amount.toInt())}'
        : '₹—';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: HubTheme.navySurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: HubTheme.borderGlass),
      ),
      child: Row(
        children: [
          const Icon(Icons.preview_rounded,
              color: HubTheme.textHint, size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(TextSpan(
              style: const TextStyle(fontSize: 12),
              children: [
                const TextSpan(text: 'Assigning ', style: TextStyle(color: HubTheme.textHint)),
                TextSpan(text: feeType, style: const TextStyle(color: HubTheme.textPrimary, fontWeight: FontWeight.w600)),
                const TextSpan(text: '  ', style: TextStyle(color: HubTheme.textHint)),
                TextSpan(text: amtStr, style: const TextStyle(color: HubTheme.cyan, fontWeight: FontWeight.w700)),
                const TextSpan(text: '  →  ', style: TextStyle(color: HubTheme.textHint)),
                TextSpan(text: target, style: const TextStyle(color: HubTheme.textPrimary, fontWeight: FontWeight.w600)),
                const TextSpan(text: '  due ', style: TextStyle(color: HubTheme.textHint)),
                TextSpan(text: DateFormat('dd MMM yyyy').format(dueDate),
                    style: const TextStyle(color: HubTheme.textSecondary)),
              ],
            )),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isSuccess;
  const _ResultCard({required this.data, required this.isSuccess});

  @override
  Widget build(BuildContext context) {
    final assigned = data['assigned'] ?? 0;
    final feeType  = data['feeType'] ?? '';
    final amount   = (data['amount'] as num?)?.toDouble() ?? 0;
    final scope    = data['scope'] ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HubTheme.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: HubTheme.green.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: HubTheme.green, size: 22),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Fee Assigned Successfully!',
                  style: TextStyle(color: HubTheme.green,
                      fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 4),
              Text(
                '$feeType  •  ₹${NumberFormat('#,##,###').format(amount.toInt())}  •  $assigned student(s)  •  $scope',
                style: const TextStyle(color: HubTheme.textSecondary, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LateFeeResultCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _LateFeeResultCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final processed = data['processed'] ?? 0;
    final charge    = (data['totalLateCharge'] as num?)?.toDouble() ?? 0;
    final scope     = data['scope'] ?? 'ALL';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HubTheme.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: HubTheme.amber.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: HubTheme.amber, size: 22),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Late Charge Applied!',
                  style: TextStyle(color: HubTheme.amber,
                      fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 4),
              Text(
                '1% applied to $processed overdue fees  •  '
                'Total added: ₹${NumberFormat('#,##,###.##').format(charge)}  •  $scope',
                style: const TextStyle(color: HubTheme.textSecondary, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: HubTheme.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: HubTheme.red.withOpacity(0.35)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: HubTheme.red, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message,
                  style: const TextStyle(color: HubTheme.red, fontSize: 12)),
            ),
          ],
        ),
      );
}

class _GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool loading;
  final VoidCallback onTap;
  final LinearGradient gradient;
  final Color glowColor;
  const _GradientButton({
    required this.label, required this.icon, required this.loading,
    required this.onTap, required this.gradient, required this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: loading
          ? const Center(child: CircularProgressIndicator(color: HubTheme.cyan, strokeWidth: 2))
          : DecoratedBox(
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: HubTheme.neonGlow(glowColor, radius: 12),
              ),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: onTap,
                icon: Icon(icon, color: Colors.black, size: 18),
                label: Text(label,
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
              ),
            ),
    );
  }
}

class _DTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  const _DTextField({
    required this.controller, required this.hint, required this.icon,
    this.maxLines = 1, this.keyboardType, this.validator,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(color: HubTheme.textPrimary, fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: HubTheme.textHint, fontSize: 13),
          prefixIcon: Icon(icon, color: HubTheme.textHint, size: 18),
          filled: true,
          fillColor: HubTheme.navySurface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: HubTheme.borderGlass)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: HubTheme.borderGlass)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: HubTheme.cyan, width: 1.5)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: HubTheme.red, width: 1.5)),
        ),
      );
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  final Color? activeColor;
  const _TabChip({required this.label, required this.active, required this.onTap, this.activeColor});

  @override
  Widget build(BuildContext context) {
    final color = activeColor ?? HubTheme.cyan;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.14) : HubTheme.navySurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: active ? color : HubTheme.borderGlass,
              width: active ? 1.5 : 1),
          boxShadow: active ? HubTheme.neonGlow(color, radius: 6) : null,
        ),
        child: Text(label,
            style: TextStyle(
                color: active ? color : HubTheme.textSecondary,
                fontSize: 12,
                fontWeight: active ? FontWeight.w700 : FontWeight.w400)),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          color: HubTheme.textHint, fontSize: 10,
          fontWeight: FontWeight.w700, letterSpacing: 1.2));
}
