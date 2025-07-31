// lib/screens/student/student_dashboard.dart

import 'package:flutter/material.dart';
import 'package:edupay_app/services/auth_service.dart';
import 'package:edupay_app/services/student_service.dart'; // For student-specific data
import 'package:edupay_app/services/payment_service.dart'; // For payment initiation
import 'package:edupay_app/screens/auth/login_page.dart';
import 'package:edupay_app/screens/common/announcement_page.dart';
import 'package:edupay_app/screens/student/payment_history_page.dart';
import 'package:edupay_app/screens/student/receipt_view_page.dart';
import 'package:edupay_app/utils/token_manager.dart';
import 'package:edupay_app/models/fee.dart'; // Import Fee model
import 'package:edupay_app/models/payment_request.dart';

import '../../models/payment_callback.dart'; // Import PaymentRequest

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final StudentService _studentService = StudentService();
  final PaymentService _paymentService = PaymentService();
  String? _username;
  Fee? _latestFee; // To display latest fee status and link to receipt

  @override
  void initState() {
    super.initState();
    _loadUserDataAndFees();
  }

  Future<void> _loadUserDataAndFees() async {
    _username = await TokenManager.getUsername();
    try {
      final fees = await _studentService.getMyFees();
      if (fees.isNotEmpty) {
        // Find the fee with outstanding amount, or the latest one
        _latestFee = fees.firstWhere(
          (fee) => fee.outstandingAmount > 0,
          orElse: () => fees.first, // If all paid, just show the first one
        );
      }
    } catch (e) {
      _showSnackBar('Error loading fees: ${e.toString().replaceFirst('Exception: ', '')}', isError: true);
    }
    setState(() {}); // Refresh UI after data loaded
  }

  Future<void> _logout(BuildContext context) async {
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
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _showFeeStatus(BuildContext context) async {
    List<Fee> fees = [];
    try {
      fees = await _studentService.getMyFees();
    } catch (e) {
      _showSnackBar('Error fetching fees: ${e.toString().replaceFirst('Exception: ', '')}', isError: true);
      return;
    }

    if (fees.isEmpty) {
      _showSnackBar('No fee records found for you.', isError: false);
      return;
    }

    // Calculate total outstanding
    double totalOutstanding = fees.fold(0.0, (sum, fee) => sum + fee.outstandingAmount);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('My Fee Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...fees.map((fee) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  '${fee.feeType}: \$${fee.outstandingAmount.toStringAsFixed(2)} due by ${fee.dueDate.toIso8601String().split('T').first} (${fee.status})',
                  style: TextStyle(
                    fontWeight: fee.outstandingAmount > 0 ? FontWeight.bold : FontWeight.normal,
                    color: fee.outstandingAmount > 0 ? Colors.red : Colors.green,
                  ),
                ),
              )).toList(),
              const Divider(),
              Text(
                'Total Outstanding: \$${totalOutstanding.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.blueAccent),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
            // Only show "Pay Now" if there's an outstanding amount
            if (totalOutstanding > 0)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close current dialog
                  _initiatePayment(context, totalOutstanding);
                },
                child: const Text('Pay Now'),
              ),
          ],
        );
      },
    );
  }

  Future<void> _initiatePayment(BuildContext context, double amountToPay) async {
    final userId = await TokenManager.getUserId();
    if (userId == null) {
      _showSnackBar('User ID not found. Please log in again.', isError: true);
      return;
    }

    try {
      // Create a PaymentRequest. You might want to link it to a specific fee ID
      // or send a general payment for total outstanding.
      final paymentRequest = PaymentRequest(
        studentId: userId, // Assuming userId from token is the studentId in backend
        amount: amountToPay,
        currency: 'INR', // Or your desired currency
        description: 'EduPay Fee Payment',
      );

      _showSnackBar('Initiating online payment...');
      // Simulate calling Razorpay or other payment gateway.
      // In a real app, this would involve Razorpay Flutter SDK.
      // The backend will create the order and return necessary details.
      final Map<String, dynamic> orderDetails = await _paymentService.initiatePayment(paymentRequest);

      // --- Mock Razorpay Popup (Replace with actual Razorpay SDK integration) ---
      bool paymentSuccess = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Simulate Payment'),
            content: Text('Order ID: ${orderDetails['orderId']}\nAmount: \$${orderDetails['amount']}\n\nSimulate successful payment?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Fail'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Success'),
              ),
            ],
          );
        },
      ) ?? false; // Default to false if dialog is dismissed

      if (paymentSuccess) {
        // Simulate payment callback to backend
        final paymentCallback = PaymentCallback(
          razorpayPaymentId: 'mock_payment_id_${DateTime.now().millisecondsSinceEpoch}',
          razorpayOrderId: orderDetails['orderId'],
          razorpaySignature: 'mock_signature', // In real app, this comes from Razorpay
          status: 'success',
        );
        await _paymentService.handlePaymentCallback(paymentCallback);
        _showSnackBar('Payment successful and recorded!');
        _loadUserDataAndFees(); // Refresh fees after successful payment
      } else {
        final paymentCallback = PaymentCallback(
          razorpayPaymentId: 'mock_payment_id_failed_${DateTime.now().millisecondsSinceEpoch}',
          razorpayOrderId: orderDetails['orderId'],
          razorpaySignature: 'mock_signature',
          status: 'failed',
          errorMessage: 'User cancelled payment',
        );
        await _paymentService.handlePaymentCallback(paymentCallback);
        _showSnackBar('Payment cancelled or failed.', isError: true);
      }
    } catch (e) {
      _showSnackBar('Payment initiation failed: ${e.toString().replaceFirst('Exception: ', '')}', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${_username ?? 'Student'}!',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'View your academic and financial updates here.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    if (_latestFee != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Latest Fee Status:',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${_latestFee!.feeType}: \$${_latestFee!.outstandingAmount.toStringAsFixed(2)} due by ${_latestFee!.dueDate.toIso8601String().split('T').first}',
                            style: TextStyle(
                              color: _latestFee!.outstandingAmount > 0 ? Colors.red : Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: <Widget>[
                  _buildDashboardCard(
                    context,
                    icon: Icons.account_balance_wallet,
                    title: 'My Fee Status',
                    onTap: () => _showFeeStatus(context),
                  ),
                  _buildDashboardCard(
                    context,
                    icon: Icons.campaign,
                    title: 'Announcements',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AnnouncementPage(isAdmin: false)),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    context,
                    icon: Icons.history,
                    title: 'Payment History',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PaymentHistoryPage()),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    context,
                    icon: Icons.payment,
                    title: 'Pay Online',
                    onTap: () => _initiatePayment(context, _latestFee?.outstandingAmount ?? 0.0), // Pass outstanding
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 50, color: Theme.of(context).primaryColor),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
// Note: The StudentDashboard is the main screen for students to view their fees, announcements, and payment history.
// It allows students to initiate payments and view their latest fee status.