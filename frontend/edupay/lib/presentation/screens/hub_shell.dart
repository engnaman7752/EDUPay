// lib/presentation/screens/hub_shell.dart
// Main EduPay AI Hub shell — multi-column layout with RBAC routing

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edupay_app/core/theme/hub_theme.dart';
import 'package:edupay_app/data/providers/hub_providers.dart';
import 'package:edupay_app/domain/models/edupay_user.dart';
import 'package:edupay_app/presentation/widgets/hub_sidebar.dart';
import 'package:edupay_app/presentation/widgets/glowing_orb_fab.dart';
import 'package:edupay_app/presentation/screens/admin/admin_hub_view.dart';
import 'package:edupay_app/presentation/screens/student/student_hub_view.dart';

class HubShell extends ConsumerStatefulWidget {
  final EduPayUser user;
  const HubShell({super.key, required this.user});

  @override
  ConsumerState<HubShell> createState() => _HubShellState();
}

class _HubShellState extends ConsumerState<HubShell> {
  bool _sidebarExpanded = false;

  @override
  void initState() {
    super.initState();
    // Inject user into Riverpod state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(hubUserProvider.notifier).state = widget.user;
    });
  }

  @override
  Widget build(BuildContext context) {
    final navIndex = ref.watch(navIndexProvider);
    final user = widget.user;

    return Theme(
      data: HubTheme.darkTheme,
      child: Scaffold(
        backgroundColor: HubTheme.navyDeep,
        // Floating AI orb
        floatingActionButton: const GlowingOrbFab(),
        body: Stack(
          children: [
            // ─── Background particle glow ──────────────────────────
            Positioned(
              top: -100,
              left: -80,
              child: _GlowBlob(color: HubTheme.cyan.withOpacity(0.08),
                  size: 500),
            ),
            Positioned(
              bottom: -80,
              right: -60,
              child: _GlowBlob(color: HubTheme.violet.withOpacity(0.07),
                  size: 400),
            ),

            // ─── Main layout ───────────────────────────────────────
            Row(
              children: [
                // Sidebar
                MouseRegion(
                  onEnter: (_) => setState(() => _sidebarExpanded = true),
                  onExit: (_) => setState(() => _sidebarExpanded = false),
                  child: HubSidebar(expanded: _sidebarExpanded),
                ),

                // Main content
                Expanded(
                  child: Column(
                    children: [
                      // Top bar
                      _TopBar(user: user, navIndex: navIndex),
                      // Content area
                      Expanded(
                        child: _buildContent(user, navIndex),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(EduPayUser user, int navIndex) {
    if (user.role.isStudent) {
      // Students always see their own hub regardless of nav
      return const StudentHubView();
    }

    // Admin/Analyst/Viewer routing by nav index
    switch (navIndex) {
      case 0: // Dashboard / Finances
        return const AdminHubView();
      case 1: // Students (placeholder)
        return _PlaceholderView(
            icon: Icons.people_alt_rounded, label: 'Students');
      case 2: // Finances
        return const AdminHubView();
      case 3: // Reports
        return _PlaceholderView(
            icon: Icons.bar_chart_rounded, label: 'Reports');
      case 4: // Notices
        return _PlaceholderView(
            icon: Icons.campaign_rounded, label: 'Notices');
      case 5: // AI Chat
        return _PlaceholderView(
            icon: Icons.smart_toy_rounded,
            label: 'AI Chat',
            subtitle: 'Tap the glowing orb in the bottom-right corner!');
      case 6: // Users
        return user.role.canEdit
            ? _PlaceholderView(
                icon: Icons.manage_accounts_rounded, label: 'User Management')
            : _AccessDenied();
      default:
        return const AdminHubView();
    }
  }
}

// ─── Top app bar ───────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final EduPayUser user;
  final int navIndex;
  const _TopBar({required this.user, required this.navIndex});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: HubTheme.navyMid.withOpacity(0.8),
            border: const Border(
              bottom: BorderSide(color: HubTheme.borderGlass, width: 1),
            ),
          ),
          child: Row(
            children: [
              // Breadcrumb
              Text('EduPay AI',
                  style: TextStyle(
                      color: HubTheme.textHint,
                      fontSize: 13)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Icon(Icons.chevron_right,
                    color: HubTheme.textHint, size: 14),
              ),
              Text(
                user.role.isStudent ? 'My Dashboard' : 'Finance Hub',
                style: const TextStyle(
                    color: HubTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              // Role badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: HubTheme.cyan.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: HubTheme.cyan.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: HubTheme.green,
                        boxShadow: HubTheme.neonGlow(HubTheme.green,
                            radius: 4),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${user.username} • ${user.role.label}',
                      style: const TextStyle(
                          color: HubTheme.cyan,
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Background glow blob ──────────────────────────────────────────────────────
class _GlowBlob extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, Colors.transparent]),
        ),
      );
}

// ─── Placeholder for unimplemented sections ────────────────────────────────────
class _PlaceholderView extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  const _PlaceholderView(
      {required this.icon, required this.label, this.subtitle});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: HubTheme.cyan.withOpacity(0.4)),
            const SizedBox(height: 16),
            Text(label,
                style: const TextStyle(
                    color: HubTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              subtitle ?? 'This section is coming soon.',
              style: const TextStyle(
                  color: HubTheme.textSecondary, fontSize: 13),
            ),
          ],
        ),
      );
}

class _AccessDenied extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline_rounded,
                size: 56, color: HubTheme.red.withOpacity(0.6)),
            const SizedBox(height: 16),
            const Text('Access Denied',
                style: TextStyle(
                    color: HubTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('You do not have permission to view this section.',
                style: TextStyle(
                    color: HubTheme.textSecondary, fontSize: 13)),
          ],
        ),
      );
}
