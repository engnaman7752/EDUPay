// lib/presentation/widgets/hub_sidebar.dart
// Left navigation sidebar for EduPay AI Hub

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edupay_app/core/theme/hub_theme.dart';
import 'package:edupay_app/data/providers/hub_providers.dart';
import 'package:edupay_app/domain/models/edupay_user.dart';
import 'package:edupay_app/utils/token_manager.dart';
import 'package:edupay_app/screens/auth/login_page.dart';

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}

// Nav items per role
List<_NavItem> _itemsFor(EduPayRole role) {
  if (role == EduPayRole.STUDENT) {
    return const [
      _NavItem(Icons.dashboard_rounded, 'Dashboard'),
      _NavItem(Icons.receipt_long_rounded, 'My Fees'),
      _NavItem(Icons.history_rounded, 'Payments'),
      _NavItem(Icons.campaign_rounded, 'Notices'),
      _NavItem(Icons.smart_toy_rounded, 'AI Chat'),
    ];
  }
  return const [
    _NavItem(Icons.dashboard_rounded, 'Dashboard'),
    _NavItem(Icons.people_alt_rounded, 'Students'),
    _NavItem(Icons.account_balance_wallet_rounded, 'Finances'),
    _NavItem(Icons.bar_chart_rounded, 'Reports'),
    _NavItem(Icons.campaign_rounded, 'Notices'),
    _NavItem(Icons.smart_toy_rounded, 'AI Chat'),
    _NavItem(Icons.manage_accounts_rounded, 'Users'),
  ];
}

class HubSidebar extends ConsumerWidget {
  final bool expanded;
  const HubSidebar({super.key, this.expanded = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(hubUserProvider);
    final navIndex = ref.watch(navIndexProvider);
    final items = _itemsFor(user?.role ?? EduPayRole.STUDENT);
    final w = expanded ? 220.0 : 70.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: w,
      decoration: BoxDecoration(
        color: HubTheme.navyMid.withOpacity(0.95),
        border: Border(
          right: BorderSide(color: HubTheme.borderGlass, width: 1),
        ),
      ),
      child: Column(
        children: [
          // ─── Logo ────────────────────────────────────────────────
          Container(
            height: 70,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: expanded
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                const SizedBox(width: 12),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: HubTheme.cyanGradient,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: HubTheme.neonGlow(HubTheme.cyan, radius: 12),
                  ),
                  child: const Icon(Icons.school_rounded,
                      color: Colors.black, size: 20),
                ),
                if (expanded) ...[
                  const SizedBox(width: 10),
                  const Text(
                    'EduPay AI',
                    style: TextStyle(
                      color: HubTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(color: HubTheme.borderGlass, height: 1),
          const SizedBox(height: 8),

          // ─── Nav Items ───────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              itemBuilder: (context, i) {
                final active = navIndex == i;
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: active
                        ? HubTheme.cyan.withOpacity(0.12)
                        : Colors.transparent,
                    boxShadow: active
                        ? [
                            BoxShadow(
                                color: HubTheme.cyan.withOpacity(0.15),
                                blurRadius: 8)
                          ]
                        : null,
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () =>
                        ref.read(navIndexProvider.notifier).state = i,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 12),
                      child: Row(
                        mainAxisAlignment: expanded
                            ? MainAxisAlignment.start
                            : MainAxisAlignment.center,
                        children: [
                          Icon(
                            items[i].icon,
                            size: 20,
                            color: active
                                ? HubTheme.cyan
                                : HubTheme.textSecondary,
                          ),
                          if (expanded) ...[
                            const SizedBox(width: 10),
                            Text(
                              items[i].label,
                              style: TextStyle(
                                color: active
                                    ? HubTheme.textPrimary
                                    : HubTheme.textSecondary,
                                fontSize: 13,
                                fontWeight: active
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ─── User footer ─────────────────────────────────────────
          const Divider(color: HubTheme.borderGlass, height: 1),
          InkWell(
            onTap: () async {
              await TokenManager.clearAuthData();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (_) => false,
                );
              }
            },
            child: Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: expanded
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                children: [
                  const Icon(Icons.logout_rounded,
                      size: 18, color: HubTheme.textSecondary),
                  if (expanded) ...[
                    const SizedBox(width: 10),
                    Text(
                      user?.username ?? 'Logout',
                      style: const TextStyle(
                          color: HubTheme.textSecondary, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
