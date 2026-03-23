// lib/screens/student/student_dashboard.dart
// Enhanced Student Dashboard with AI FAB, Notification Bell, and Premium UI

import 'package:flutter/material.dart';
import 'package:edupay_app/core/constants/app_theme.dart';
import 'package:edupay_app/features/ai_chat/views/chat_screen.dart';
import 'package:edupay_app/features/dashboard/widgets/fee_status_card.dart';
import 'package:edupay_app/features/dashboard/widgets/realtime_alert_list.dart';
import 'package:edupay_app/models/notification_message.dart';
import 'package:edupay_app/services/auth_service.dart';
import 'package:edupay_app/services/student_service.dart';
import 'package:edupay_app/services/payment_service.dart';
import 'package:edupay_app/services/notification_service.dart';
import 'package:edupay_app/screens/auth/login_page.dart';
import 'package:edupay_app/screens/common/announcement_page.dart';
import 'package:edupay_app/screens/student/payment_history_page.dart';
import 'package:edupay_app/utils/token_manager.dart';
import 'package:edupay_app/models/fee.dart';
import 'package:edupay_app/models/payment_request.dart';
import '../../models/payment_callback.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard>
    with TickerProviderStateMixin {
  final StudentService _studentService = StudentService();
  final PaymentService _paymentService = PaymentService();
  final NotificationWsService _notificationService = NotificationWsService();

  String? _username;
  List<Fee> _fees = [];
  int _unreadCount = 0;
  List<NotificationMessage> _notifications = [];

  // Notification bell animation
  late AnimationController _bellAnimController;
  late Animation<double> _bellAnimation;

  @override
  void initState() {
    super.initState();
    _bellAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _bellAnimation = Tween<double>(begin: 0, end: 0.1).animate(
      CurvedAnimation(parent: _bellAnimController, curve: Curves.elasticIn),
    );
    _loadData();
    _connectWebSocket();
  }

  @override
  void dispose() {
    _bellAnimController.dispose();
    _notificationService.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    _username = await TokenManager.getUsername();
    try {
      _fees = await _studentService.getMyFees();
      _unreadCount = await _notificationService.getUnreadCount();
      _notifications = await _notificationService.getNotifications();
    } catch (e) {
      // Silently handle errors on initial load
    }
    if (mounted) setState(() {});
  }

  void _connectWebSocket() {
    _notificationService.connect();
    _notificationService.notificationStream.listen((notification) {
      setState(() {
        _unreadCount++;
        _notifications.insert(0, notification);
      });
      // Pulse the bell
      _bellAnimController.forward().then((_) {
        _bellAnimController.reverse();
      });
    });
  }

  double get _totalFees => _fees.fold(0.0, (sum, f) => sum + f.amount);
  double get _totalPaid => _fees.fold(0.0, (sum, f) => sum + f.amountPaid);
  double get _totalOutstanding =>
      _fees.fold(0.0, (sum, f) => sum + f.outstandingAmount);

  Future<void> _logout(BuildContext context) async {
    _notificationService.disconnect();
    await AuthService().logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.accentRed : AppTheme.accentGreen,
      ),
    );
  }

  Future<void> _initiatePayment(BuildContext context, double amountToPay) async {
    final userId = await TokenManager.getUserId();
    if (userId == null) {
      _showSnackBar('User ID not found. Please log in again.', isError: true);
      return;
    }

    try {
      final paymentRequest = PaymentRequest(
        studentId: userId,
        amount: amountToPay,
        currency: 'INR',
        description: 'EduPay Fee Payment',
      );

      _showSnackBar('Initiating online payment...');
      final Map<String, dynamic> orderDetails =
          await _paymentService.initiatePayment(paymentRequest);

      bool paymentSuccess = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: AppTheme.cardDark,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                title: const Text('Simulate Payment',
                    style: TextStyle(color: AppTheme.textPrimary)),
                content: Text(
                  'Order: ${orderDetails['orderId']}\nAmount: ₹${orderDetails['amount']}\n\nSimulate successful payment?',
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Fail',
                        style: TextStyle(color: AppTheme.accentRed)),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Success'),
                  ),
                ],
              );
            },
          ) ??
          false;

      if (paymentSuccess) {
        final paymentCallback = PaymentCallback(
          razorpayPaymentId:
              'mock_payment_id_${DateTime.now().millisecondsSinceEpoch}',
          razorpayOrderId: orderDetails['orderId'],
          razorpaySignature: 'mock_signature',
          status: 'success',
        );
        await _paymentService.handlePaymentCallback(paymentCallback);
        _showSnackBar('Payment successful and recorded!');
        _loadData();
      } else {
        final paymentCallback = PaymentCallback(
          razorpayPaymentId:
              'mock_payment_id_failed_${DateTime.now().millisecondsSinceEpoch}',
          razorpayOrderId: orderDetails['orderId'],
          razorpaySignature: 'mock_signature',
          status: 'failed',
          errorMessage: 'User cancelled payment',
        );
        await _paymentService.handlePaymentCallback(paymentCallback);
        _showSnackBar('Payment cancelled or failed.', isError: true);
      }
    } catch (e) {
      _showSnackBar(
          'Payment failed: ${e.toString().replaceFirst('Exception: ', '')}',
          isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppTheme.accentBlue,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== Fee Status Card =====
              FeeStatusCard(
                studentName: _username ?? 'Student',
                totalFees: _totalFees,
                totalPaid: _totalPaid,
                aiInsight: _totalOutstanding > 0
                    ? 'Early payment could help you avoid late fee charges!'
                    : 'All fees are up to date. Great job! 🎉',
              ),
              const SizedBox(height: 24),

              // ===== Quick Actions Grid =====
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.4,
                children: [
                  _buildActionCard(
                    icon: Icons.account_balance_wallet_rounded,
                    title: 'My Fees',
                    color: AppTheme.accentBlue,
                    onTap: () => _showFeeStatus(context),
                  ),
                  _buildActionCard(
                    icon: Icons.campaign_rounded,
                    title: 'Announcements',
                    color: AppTheme.accentOrange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const AnnouncementPage(isAdmin: false)),
                      );
                    },
                  ),
                  _buildActionCard(
                    icon: Icons.history_rounded,
                    title: 'Pay History',
                    color: AppTheme.accentGreen,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const PaymentHistoryPage()),
                      );
                    },
                  ),
                  _buildActionCard(
                    icon: Icons.payment_rounded,
                    title: 'Pay Online',
                    color: AppTheme.accentPurple,
                    onTap: () => _initiatePayment(context, _totalOutstanding),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ===== Real-time Notifications =====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Notifications',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  if (_unreadCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.accentRed.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$_unreadCount new',
                        style: const TextStyle(
                          color: AppTheme.accentRed,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              RealTimeAlertList(
                notificationStream: _notificationService.notificationStream,
                initialNotifications:
                    _notifications.length > 5
                        ? _notifications.sublist(0, 5)
                        : _notifications,
              ),
            ],
          ),
        ),
      ),

      // ===== AI Chat FAB =====
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.accentGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accentPurple.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const ChatScreen(),
                transitionsBuilder: (_, animation, __, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    )),
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 400),
              ),
            );
          },
          child: const Icon(Icons.auto_awesome, size: 26),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.primaryMid,
      automaticallyImplyLeading: false,
      title: const Text('Dashboard'),
      actions: [
        // Notification Bell with badge + pulse
        Stack(
          alignment: Alignment.center,
          children: [
            RotationTransition(
              turns: _bellAnimation,
              child: IconButton(
                icon: const Icon(Icons.notifications_none_rounded),
                onPressed: () {
                  // Could navigate to full notification list
                  setState(() => _unreadCount = 0);
                },
              ),
            ),
            if (_unreadCount > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppTheme.accentRed,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    _unreadCount > 9 ? '9+' : '$_unreadCount',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.logout_rounded),
          onPressed: () => _logout(context),
          tooltip: 'Logout',
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 26, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showFeeStatus(BuildContext context) async {
    List<Fee> fees = [];
    try {
      fees = await _studentService.getMyFees();
    } catch (e) {
      _showSnackBar(
          'Error fetching fees: ${e.toString().replaceFirst('Exception: ', '')}',
          isError: true);
      return;
    }

    if (fees.isEmpty) {
      _showSnackBar('No fee records found.', isError: false);
      return;
    }

    double totalOutstanding = fees.fold(0.0, (sum, fee) => sum + fee.outstandingAmount);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('My Fee Status',
              style: TextStyle(color: AppTheme.textPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...fees.map((fee) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      '${fee.feeType}: ₹${fee.outstandingAmount.toStringAsFixed(2)} due by ${fee.dueDate.toIso8601String().split('T').first} (${fee.status})',
                      style: TextStyle(
                        fontWeight: fee.outstandingAmount > 0
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: fee.outstandingAmount > 0
                            ? AppTheme.accentOrange
                            : AppTheme.accentGreen,
                        fontSize: 13,
                      ),
                    ),
                  )),
              const Divider(color: AppTheme.dividerColor),
              Text(
                'Total Outstanding: ₹${totalOutstanding.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accentBlue,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close', style: TextStyle(color: AppTheme.textHint)),
            ),
            if (totalOutstanding > 0)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _initiatePayment(context, totalOutstanding);
                },
                child: const Text('Pay Now'),
              ),
          ],
        );
      },
    );
  }
}