// lib/presentation/screens/admin/broadcast_screen.dart
// Admin broadcast alert/info screen — ALL / CLASS / STUDENT scope

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:edupay_app/core/theme/hub_theme.dart';
import 'package:edupay_app/constants/api_constants.dart';
import 'package:edupay_app/presentation/widgets/glassmorphism_card.dart';
import 'package:edupay_app/utils/token_manager.dart';

enum BroadcastScope { ALL, CLASS, STUDENT }

enum BroadcastPriority { INFO, ALERT, URGENT }

class BroadcastScreen extends ConsumerStatefulWidget {
  const BroadcastScreen({super.key});

  @override
  ConsumerState<BroadcastScreen> createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends ConsumerState<BroadcastScreen>
    with SingleTickerProviderStateMixin {
  // Form
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();

  BroadcastScope _scope = BroadcastScope.ALL;
  BroadcastPriority _priority = BroadcastPriority.INFO;
  int _selectedClass = 10;
  final _studentIdCtrl = TextEditingController();

  bool _sending = false;
  String? _successMsg;
  String? _errorMsg;

  // Animation
  late AnimationController _successAnim;
  late Animation<double> _successScale;

  @override
  void initState() {
    super.initState();
    _successAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _successScale = CurvedAnimation(parent: _successAnim, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _messageCtrl.dispose();
    _studentIdCtrl.dispose();
    _successAnim.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _sending = true;
      _successMsg = null;
      _errorMsg = null;
    });

    final body = <String, dynamic>{
      'title': _titleCtrl.text.trim(),
      'message': _messageCtrl.text.trim(),
      'scopeType': _scope.name,
      'priority': _priority.name,
    };

    if (_scope == BroadcastScope.CLASS) body['standard'] = _selectedClass;
    if (_scope == BroadcastScope.STUDENT) body['studentId'] = _studentIdCtrl.text.trim();

    try {
      final token = await TokenManager.getToken();
      final res = await http.post(
        Uri.parse('${ApiConstants.BASE_URL}/announcements/broadcast'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (res.statusCode == 201) {
        setState(() {
          _successMsg = '✅ Broadcast sent successfully!';
          _titleCtrl.clear();
          _messageCtrl.clear();
          _studentIdCtrl.clear();
        });
        _successAnim.forward(from: 0);
      } else {
        final err = jsonDecode(res.body);
        setState(() => _errorMsg = err['message'] ?? 'Failed to send broadcast');
      }
    } catch (e) {
      setState(() => _errorMsg = 'Connection error: ${e.toString()}');
    } finally {
      setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header ──────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: HubTheme.cyanGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: HubTheme.neonGlow(HubTheme.cyan, radius: 10),
                ),
                child: const Icon(Icons.campaign_rounded,
                    color: Colors.black, size: 22),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Broadcast Alert',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: HubTheme.textPrimary)),
                  Text('Send notices to all students, a class, or one student',
                      style: TextStyle(
                          fontSize: 12, color: HubTheme.textSecondary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),

          // ─── Scope Selector ───────────────────────────────────
          _SectionLabel(label: 'WHO SHOULD RECEIVE THIS?'),
          const SizedBox(height: 10),
          Row(
            children: BroadcastScope.values.map((scope) {
              final active = _scope == scope;
              final (icon, label) = switch (scope) {
                BroadcastScope.ALL => (Icons.people_alt_rounded, 'All Students'),
                BroadcastScope.CLASS => (Icons.class_outlined, 'Class / Standard'),
                BroadcastScope.STUDENT => (Icons.person_rounded, 'One Student'),
              };
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _scope = scope),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      color: active
                          ? HubTheme.cyan.withOpacity(0.12)
                          : HubTheme.navySurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: active
                            ? HubTheme.cyan
                            : HubTheme.borderGlass,
                        width: active ? 1.5 : 1,
                      ),
                      boxShadow: active
                          ? HubTheme.neonGlow(HubTheme.cyan, radius: 6)
                          : null,
                    ),
                    child: Column(
                      children: [
                        Icon(icon,
                            color: active ? HubTheme.cyan : HubTheme.textSecondary,
                            size: 24),
                        const SizedBox(height: 6),
                        Text(label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: active
                                    ? HubTheme.textPrimary
                                    : HubTheme.textSecondary,
                                fontSize: 12,
                                fontWeight: active
                                    ? FontWeight.w600
                                    : FontWeight.w400)),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // ─── Scope Options ────────────────────────────────────
          if (_scope == BroadcastScope.CLASS) ...[
            _SectionLabel(label: 'SELECT CLASS / STANDARD'),
            const SizedBox(height: 10),
            _ClassPicker(
              selected: _selectedClass,
              onChanged: (v) => setState(() => _selectedClass = v),
            ),
            const SizedBox(height: 20),
          ],
          if (_scope == BroadcastScope.STUDENT) ...[
            _SectionLabel(label: 'STUDENT ID'),
            const SizedBox(height: 10),
            _DarkTextField(
              controller: _studentIdCtrl,
              hint: 'e.g. S042',
              icon: Icons.badge_rounded,
              validator: (v) => (v == null || v.isEmpty) ? 'Enter a student ID' : null,
            ),
            const SizedBox(height: 20),
          ],

          // ─── Priority ─────────────────────────────────────────
          _SectionLabel(label: 'PRIORITY'),
          const SizedBox(height: 10),
          Row(
            children: BroadcastPriority.values.map((p) {
              final active = _priority == p;
              final color = switch (p) {
                BroadcastPriority.INFO => HubTheme.cyan,
                BroadcastPriority.ALERT => HubTheme.amber,
                BroadcastPriority.URGENT => HubTheme.red,
              };
              return GestureDetector(
                onTap: () => setState(() => _priority = p),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: active ? color.withOpacity(0.14) : HubTheme.navySurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: active ? color : HubTheme.borderGlass,
                        width: active ? 1.5 : 1),
                  ),
                  child: Text(p.name,
                      style: TextStyle(
                          color: active ? color : HubTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // ─── Compose form ─────────────────────────────────────
          _SectionLabel(label: 'COMPOSE MESSAGE'),
          const SizedBox(height: 10),
          GlassmorphismCard(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _DarkTextField(
                    controller: _titleCtrl,
                    hint: 'Title (e.g. "Holiday Notice")',
                    icon: Icons.title_rounded,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Please enter a title' : null,
                  ),
                  const SizedBox(height: 14),
                  _DarkTextField(
                    controller: _messageCtrl,
                    hint: 'Write your message here...',
                    icon: Icons.message_rounded,
                    maxLines: 5,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Please enter a message' : null,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ─── Preview badge ────────────────────────────────────
          _BroadcastPreview(
            scope: _scope,
            standard: _selectedClass,
            studentId: _studentIdCtrl.text,
            priority: _priority,
          ),
          const SizedBox(height: 24),

          // ─── Send button ──────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 52,
            child: _sending
                ? const Center(
                    child: CircularProgressIndicator(
                        color: HubTheme.cyan, strokeWidth: 2))
                : DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: HubTheme.cyanGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: HubTheme.neonGlow(HubTheme.cyan, radius: 12),
                    ),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _send,
                      icon: const Icon(Icons.send_rounded,
                          color: Colors.black, size: 18),
                      label: const Text('Send Broadcast',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                              fontSize: 15)),
                    ),
                  ),
          ),
          const SizedBox(height: 16),

          // ─── Feedback ─────────────────────────────────────────
          if (_successMsg != null)
            ScaleTransition(
              scale: _successScale,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: HubTheme.green.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: HubTheme.green.withOpacity(0.35)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline_rounded,
                        color: HubTheme.green, size: 18),
                    const SizedBox(width: 10),
                    Text(_successMsg!,
                        style: const TextStyle(
                            color: HubTheme.green,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                  ],
                ),
              ),
            ),
          if (_errorMsg != null)
            Container(
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
                    child: Text(_errorMsg!,
                        style: const TextStyle(
                            color: HubTheme.red, fontSize: 13)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Class picker (1–12 grid) ──────────────────────────────────────────────────
class _ClassPicker extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;
  const _ClassPicker({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
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
              color: active ? HubTheme.cyan.withOpacity(0.15) : HubTheme.navySurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: active ? HubTheme.cyan : HubTheme.borderGlass,
                  width: active ? 1.5 : 1),
              boxShadow: active ? HubTheme.neonGlow(HubTheme.cyan, radius: 6) : null,
            ),
            child: Center(
              child: Text(
                '$cls',
                style: TextStyle(
                  color: active ? HubTheme.cyan : HubTheme.textSecondary,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ─── Broadcast preview badge ───────────────────────────────────────────────────
class _BroadcastPreview extends StatelessWidget {
  final BroadcastScope scope;
  final int standard;
  final String studentId;
  final BroadcastPriority priority;
  const _BroadcastPreview({
    required this.scope,
    required this.standard,
    required this.studentId,
    required this.priority,
  });

  @override
  Widget build(BuildContext context) {
    final target = switch (scope) {
      BroadcastScope.ALL => 'All Students',
      BroadcastScope.CLASS => 'Class $standard',
      BroadcastScope.STUDENT =>
        studentId.isEmpty ? 'Student (enter ID)' : 'Student $studentId',
    };
    final pColor = switch (priority) {
      BroadcastPriority.INFO => HubTheme.cyan,
      BroadcastPriority.ALERT => HubTheme.amber,
      BroadcastPriority.URGENT => HubTheme.red,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: HubTheme.navySurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: HubTheme.borderGlass),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              color: HubTheme.textHint, size: 15),
          const SizedBox(width: 8),
          Text('Sending to: ',
              style: const TextStyle(
                  color: HubTheme.textHint, fontSize: 12)),
          Text(target,
              style: const TextStyle(
                  color: HubTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12)),
          const SizedBox(width: 12),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: pColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: pColor.withOpacity(0.35)),
            ),
            child: Text(priority.name,
                style: TextStyle(
                    color: pColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ─── Reusable dark text field ──────────────────────────────────────────────────
class _DarkTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final int maxLines;
  final String? Function(String?)? validator;
  const _DarkTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(color: HubTheme.textPrimary, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(color: HubTheme.textHint, fontSize: 13),
        prefixIcon:
            Icon(icon, color: HubTheme.textHint, size: 18),
        filled: true,
        fillColor: HubTheme.navySurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: HubTheme.borderGlass),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: HubTheme.borderGlass),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: HubTheme.cyan, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: HubTheme.red, width: 1.5),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});
  @override
  Widget build(BuildContext context) => Text(
        label,
        style: const TextStyle(
            color: HubTheme.textHint,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2),
      );
}
