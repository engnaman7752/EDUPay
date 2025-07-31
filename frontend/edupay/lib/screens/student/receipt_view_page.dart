// lib/screens/student/receipt_view_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

class ReceiptViewPage extends StatelessWidget {
  final String transactionId;
  final double amount;
  final String paymentMethod;
  final DateTime paymentDate;
  final String studentName;
  final String? feeType; // Optional
  final String? recordedByAdminName; // Optional

  const ReceiptViewPage({
    super.key,
    required this.transactionId,
    required this.amount,
    required this.paymentMethod,
    required this.paymentDate,
    required this.studentName,
    this.feeType,
    this.recordedByAdminName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Receipt'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'EduPay Payment Receipt',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Divider(height: 30, thickness: 1),
                  _buildReceiptRow('Transaction ID:', transactionId),
                  _buildReceiptRow('Student Name:', studentName),
                  if (feeType != null && feeType!.isNotEmpty)
                    _buildReceiptRow('Fee Type:', feeType!),
                  _buildReceiptRow('Amount Paid:', '\$${amount.toStringAsFixed(2)}', isAmount: true),
                  _buildReceiptRow('Payment Method:', paymentMethod),
                  _buildReceiptRow('Payment Date:', DateFormat('yyyy-MM-dd HH:mm').format(paymentDate.toLocal())),
                  if (recordedByAdminName != null && recordedByAdminName!.isNotEmpty)
                    _buildReceiptRow('Recorded By:', recordedByAdminName!),
                  const Divider(height: 30, thickness: 1),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Thank you for your payment!',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontStyle: FontStyle.italic),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement print/share receipt functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Print/Share Receipt functionality coming soon!')),
                        );
                      },
                      icon: const Icon(Icons.print),
                      label: const Text('Print / Share Receipt'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isAmount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isAmount ? FontWeight.bold : FontWeight.normal,
              color: isAmount ? Colors.green.shade700 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
