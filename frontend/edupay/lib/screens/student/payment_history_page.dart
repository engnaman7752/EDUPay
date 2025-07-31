// lib/screens/student/payment_history_page.dart

import 'package:flutter/material.dart';
import 'package:edupay_app/models/payment_history.dart';
import 'package:edupay_app/services/student_service.dart'; // StudentService has getPaymentHistory
import 'package:edupay_app/screens/student/receipt_view_page.dart';

class PaymentHistoryPage extends StatefulWidget {
  const PaymentHistoryPage({super.key});

  @override
  State<PaymentHistoryPage> createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  final StudentService _studentService = StudentService();
  late Future<List<PaymentHistoryDto>> _paymentHistoryFuture;

  @override
  void initState() {
    super.initState();
    _paymentHistoryFuture = _studentService.getPaymentHistory();
  }

  Future<void> _refreshPaymentHistory() async {
    setState(() {
      _paymentHistoryFuture = _studentService.getPaymentHistory();
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment History'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<PaymentHistoryDto>>(
        future: _paymentHistoryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error.toString().replaceFirst('Exception: ', '')}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No payment history found.'));
          } else {
            return RefreshIndicator(
              onRefresh: _refreshPaymentHistory,
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final payment = snapshot.data![index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      leading: Icon(
                        payment.paymentMethod == 'Cash' ? Icons.money : Icons.credit_card,
                        color: Theme.of(context).primaryColor,
                        size: 30,
                      ),
                      title: Text('Amount: \$${payment.amount.toStringAsFixed(2)}'),
                      subtitle: Text(
                        'Date: ${payment.paymentDate.toLocal().toString().split(' ')[0]} | Method: ${payment.paymentMethod}\n'
                        'Status: ${payment.status}'
                        '${payment.recordedByAdminName != null ? '\nRecorded by: ${payment.recordedByAdminName}' : ''}',
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReceiptViewPage(
                                transactionId: payment.transactionId,
                                amount: payment.amount,
                                paymentMethod: payment.paymentMethod,
                                paymentDate: payment.paymentDate,
                                studentName: payment.studentName,
                                feeType: payment.feeType,
                                recordedByAdminName: payment.recordedByAdminName,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('View Receipt'),
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
