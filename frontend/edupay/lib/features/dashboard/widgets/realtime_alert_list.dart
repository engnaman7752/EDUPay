// lib/features/dashboard/widgets/realtime_alert_list.dart
// Real-time notification list with WebSocket stream

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:edupay_app/core/constants/app_theme.dart';
import 'package:edupay_app/models/notification_message.dart';

class RealTimeAlertList extends StatefulWidget {
  final Stream<NotificationMessage> notificationStream;
  final List<NotificationMessage> initialNotifications;

  const RealTimeAlertList({
    super.key,
    required this.notificationStream,
    this.initialNotifications = const [],
  });

  @override
  State<RealTimeAlertList> createState() => _RealTimeAlertListState();
}

class _RealTimeAlertListState extends State<RealTimeAlertList> {
  final List<NotificationMessage> _notifications = [];
  StreamSubscription<NotificationMessage>? _subscription;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    _notifications.addAll(widget.initialNotifications);
    _subscription = widget.notificationStream.listen((notification) {
      setState(() {
        _notifications.insert(0, notification);
      });
      _listKey.currentState?.insertItem(0,
          duration: const Duration(milliseconds: 400));
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_notifications.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.glassCard,
        child: Column(
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 40,
              color: AppTheme.textHint.withOpacity(0.4),
            ),
            const SizedBox(height: 8),
            Text(
              'No notifications yet',
              style: TextStyle(
                color: AppTheme.textHint.withOpacity(0.6),
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return AnimatedList(
      key: _listKey,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      initialItemCount: _notifications.length,
      itemBuilder: (context, index, animation) {
        if (index >= _notifications.length) return const SizedBox();
        return _buildAlertCard(_notifications[index], animation);
      },
    );
  }

  Widget _buildAlertCard(
      NotificationMessage notification, Animation<double> animation) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: FadeTransition(
        opacity: animation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.cardDark,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _getTypeColor(notification.type).withOpacity(0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: _getTypeColor(notification.type).withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _getTypeColor(notification.type).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getTypeIcon(notification.type),
                      size: 16,
                      color: _getTypeColor(notification.type),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      notification.title,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    _formatTime(notification.createdAt),
                    style: const TextStyle(
                      color: AppTheme.textHint,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                notification.message,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              // AI Insight
              if (notification.insight != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.accentOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome,
                          size: 13, color: AppTheme.accentOrange),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          notification.insight!,
                          style: const TextStyle(
                            color: AppTheme.accentOrange,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'FEE_REMINDER':
        return AppTheme.accentOrange;
      case 'PAYMENT_CONFIRM':
        return AppTheme.accentGreen;
      case 'AI_INSIGHT':
        return AppTheme.accentPurple;
      default:
        return AppTheme.accentBlue;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'FEE_REMINDER':
        return Icons.payment_rounded;
      case 'PAYMENT_CONFIRM':
        return Icons.check_circle_rounded;
      case 'AI_INSIGHT':
        return Icons.auto_awesome;
      default:
        return Icons.notifications_rounded;
    }
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month}';
  }
}
