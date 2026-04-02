// lib/presentation/widgets/glowing_orb_fab.dart
// Pulsing glowing orb FAB that opens the AI insights bottom sheet

import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:edupay_app/core/theme/hub_theme.dart';
import 'package:edupay_app/data/providers/hub_providers.dart';
import 'package:edupay_app/domain/models/edupay_user.dart';
import 'package:edupay_app/constants/api_constants.dart';
import 'package:edupay_app/utils/token_manager.dart';

class GlowingOrbFab extends ConsumerStatefulWidget {
  const GlowingOrbFab({super.key});

  @override
  ConsumerState<GlowingOrbFab> createState() => _GlowingOrbFabState();
}

class _GlowingOrbFabState extends ConsumerState<GlowingOrbFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.12).animate(
        CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _openAiSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AiInsightsSheet(ref: ref),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (_, child) => Transform.scale(
        scale: _scale.value,
        child: child,
      ),
      child: GestureDetector(
        onTap: _openAiSheet,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const SweepGradient(
              colors: [HubTheme.cyan, HubTheme.violet, HubTheme.cyan],
            ),
            boxShadow: HubTheme.neonGlow(HubTheme.cyan, radius: 20),
          ),
          child: const Icon(Icons.auto_awesome_rounded,
              color: Colors.black, size: 26),
        ),
      ),
    );
  }
}

// ─── AI Insights Bottom Sheet ──────────────────────────────────────────────────
class _AiInsightsSheet extends ConsumerStatefulWidget {
  final WidgetRef ref;
  const _AiInsightsSheet({required this.ref});

  @override
  ConsumerState<_AiInsightsSheet> createState() => _AiInsightsSheetState();
}

class _AiInsightsSheetState extends ConsumerState<_AiInsightsSheet> {
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scroll = ScrollController();
  bool _loading = false;

  List<Map<String, String>> get _history =>
      ref.watch(aiChatHistoryProvider);

  @override
  void initState() {
    super.initState();
    _loadInitialInsight();
  }

  Future<void> _loadInitialInsight() async {
    if (_history.isNotEmpty) return;
    final user = ref.read(hubUserProvider);
    final prompt = user?.role == EduPayRole.STUDENT
        ? 'Give me a brief personalized insight about my school fee status and any upcoming dues. Keep it under 3 sentences.'
        : 'Give me top 3 school financial insights for this month: projected cash flow, overdue fees summary, and one cost optimization tip. Be brief.';
    await _sendMessage(prompt, auto: true);
  }

  Future<void> _sendMessage(String message, {bool auto = false}) async {
    if (message.trim().isEmpty) return;
    setState(() => _loading = true);

    if (!auto) {
      ref.read(aiChatHistoryProvider.notifier).update(
            (s) => [...s, {'role': 'user', 'content': message}],
          );
      _msgCtrl.clear();
    }

    try {
      final token = await TokenManager.getToken();
      final res = await http.post(
        Uri.parse('${ApiConstants.BASE_URL}/ai/chat'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'question': message}),
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final answer = body['answer'] as String? ?? '...';
        ref.read(aiChatHistoryProvider.notifier).update(
              (s) => [...s, {'role': 'ai', 'content': answer}],
            );
      }
    } catch (_) {
      ref.read(aiChatHistoryProvider.notifier).update((s) => [
            ...s,
            {
              'role': 'ai',
              'content':
                  '⚡ AI service is unavailable. Check your connection.',
            }
          ]);
    } finally {
      setState(() => _loading = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.animateTo(
            _scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(hubUserProvider);
    final isAdmin = user?.role.canEdit ?? false;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.92,
      minChildSize: 0.4,
      builder: (_, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: HubTheme.navyMid,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: HubTheme.borderGlass),
        ),
        child: Column(
          children: [
            // ─── Handle ──────────────────────────────────────
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: HubTheme.borderGlass,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // ─── Header with orb ─────────────────────────────
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const SweepGradient(
                        colors: [HubTheme.cyan, HubTheme.violet, HubTheme.cyan],
                      ),
                      boxShadow:
                          HubTheme.neonGlow(HubTheme.cyan, radius: 10),
                    ),
                    child: const Icon(Icons.auto_awesome_rounded,
                        color: Colors.black, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('EduPay AI',
                          style: TextStyle(
                              color: HubTheme.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 15)),
                      Text(
                        isAdmin
                            ? 'School-level financial insights'
                            : 'Your personalized fee assistant',
                        style: const TextStyle(
                            color: HubTheme.textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Quick insight chips
                  if (isAdmin)
                    _ChipButton(
                      label: 'Cash Flow',
                      onTap: () => _sendMessage(
                          'Estimate cash flow for next month based on pending fees.'),
                    ),
                  if (!isAdmin)
                    _ChipButton(
                      label: 'Fee Help',
                      onTap: () => _sendMessage(
                          'Explain my outstanding fees in simple terms.'),
                    ),
                ],
              ),
            ),
            const Divider(color: HubTheme.borderGlass),
            // ─── Chat messages ───────────────────────────────
            Expanded(
              child: _history.isEmpty && _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: HubTheme.cyan, strokeWidth: 2))
                  : ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.all(16),
                      itemCount:
                          _history.length + (_loading ? 1 : 0),
                      itemBuilder: (_, i) {
                        if (i == _history.length) {
                          return const _TypingBubble();
                        }
                        final msg = _history[i];
                        final isUser = msg['role'] == 'user';
                        return _ChatBubble(
                            content: msg['content']!, isUser: isUser);
                      },
                    ),
            ),
            // ─── Input ───────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: HubTheme.navySurface,
                        borderRadius: BorderRadius.circular(24),
                        border:
                            Border.all(color: HubTheme.borderGlass),
                      ),
                      child: TextField(
                        controller: _msgCtrl,
                        style: const TextStyle(
                            color: HubTheme.textPrimary, fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: 'Ask AI anything...',
                          hintStyle: TextStyle(
                              color: HubTheme.textHint, fontSize: 13),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        onSubmitted: (v) => _sendMessage(v),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _sendMessage(_msgCtrl.text),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: HubTheme.cyanGradient,
                        boxShadow:
                            HubTheme.neonGlow(HubTheme.cyan, radius: 8),
                      ),
                      child: const Icon(Icons.send_rounded,
                          color: Colors.black, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _ChipButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: HubTheme.cyan.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: HubTheme.cyan.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: const TextStyle(
              color: HubTheme.cyan,
              fontSize: 11,
              fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String content;
  final bool isUser;
  const _ChatBubble({required this.content, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: isUser ? HubTheme.cyanGradient : null,
          color: isUser ? null : HubTheme.navySurface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border: isUser
              ? null
              : Border.all(color: HubTheme.borderGlass),
        ),
        child: Text(
          content,
          style: TextStyle(
            color: isUser ? Colors.black : HubTheme.textPrimary,
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: HubTheme.navySurface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
          ),
          border: Border.all(color: HubTheme.borderGlass),
        ),
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              final t = (_ctrl.value - i * 0.2).clamp(0.0, 1.0);
              final opacity = (sin(t * pi) * 0.8 + 0.2).clamp(0.2, 1.0);
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: HubTheme.cyan.withOpacity(opacity),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
