// lib/screens/admin/fee_management_page.dart

import 'package:flutter/material.dart';
import 'package:edupay_app/models/fee.dart';
import 'package:edupay_app/models/student.dart';
import 'package:edupay_app/models/cash_deposit_request.dart';
import 'package:edupay_app/services/admin_service.dart';
import 'package:edupay_app/services/announcement_service.dart';
import 'package:edupay_app/models/announcement.dart';
// import 'package:edupay_app/services/student_service.dart'; // No longer needed directly for admin fee view

class FeeManagementPage extends StatefulWidget {
  const FeeManagementPage({super.key});

  @override
  State<FeeManagementPage> createState() => _FeeManagementPageState();
}

class _FeeManagementPageState extends State<FeeManagementPage> {
  final AdminService _adminService = AdminService();
  // final StudentService _studentService = StudentService(); // Removed as AdminService will fetch fees
  late Future<List<Student>> _studentsFuture;
  Student? _selectedStudent;
  late Future<List<Fee>> _feesFuture;

  @override
  void initState() {
    super.initState();
    _studentsFuture = _adminService.getAllStudents();
    _feesFuture = Future.value([]); // Initialize with empty list
  }

  Future<void> _refreshFees() async {
    if (_selectedStudent != null && _selectedStudent!.id != null) {
      setState(() {
        // Corrected: Use AdminService to get fees for the selected student
        _feesFuture = _adminService.getFeesForStudent(_selectedStudent!.id!);
      });
    } else {
      setState(() {
        _feesFuture = Future.value([]); // Clear fees if no student selected or ID is null
      });
    }
  }

  Future<void> _showFeeForm({Fee? fee}) async {
    final bool isEditing = fee != null;
    final TextEditingController feeTypeController = TextEditingController(text: fee?.feeType);
    final TextEditingController amountController = TextEditingController(text: fee?.amount.toString());
    final TextEditingController dueDateController = TextEditingController(text: fee?.dueDate.toIso8601String().split('T').first);

    if (!isEditing && _selectedStudent == null) {
      _showSnackBar('Please select a student first to add a fee.', isError: true);
      return;
    }

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Fee' : 'Add New Fee'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isEditing)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Text('For Student: ${_selectedStudent!.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                TextField(
                  controller: feeTypeController,
                  decoration: const InputDecoration(labelText: 'Fee Type (e.g., Tuition, Exam)'),
                ),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: dueDateController,
                  decoration: const InputDecoration(labelText: 'Due Date (YYYY-MM-DD)'),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      dueDateController.text = pickedDate.toIso8601String().split('T').first;
                    }
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text(isEditing ? 'Update' : 'Add'),
              onPressed: () async {
                try {
                  final newFee = Fee(
                    id: fee?.id,
                    feeType: feeTypeController.text,
                    amount: double.parse(amountController.text),
                    amountPaid: isEditing ? fee!.amountPaid : 0.0,
                    outstandingAmount: isEditing ? double.parse(amountController.text) - fee!.amountPaid : double.parse(amountController.text),
                    dueDate: DateTime.parse(dueDateController.text),
                    status: isEditing ? fee!.status : 'Pending',
                    studentId: isEditing ? fee!.studentId : _selectedStudent!.id,
                  );

                  if (isEditing) {
                    await _adminService.updateFeeStatus(fee!.id!, newFee.status); // Assuming updateFeeStatus can handle full fee update
                    _showSnackBar('Fee updated successfully!');
                  } else {
                    await _adminService.addFee(newFee);
                    _showSnackBar('Fee added successfully!');
                  }
                  _refreshFees();
                  Navigator.of(context).pop();
                } catch (e) {
                  _showSnackBar('Error: ${e.toString().replaceFirst('Exception: ', '')}', isError: true);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _recordCashPayment(Fee fee) async {
    final TextEditingController amountController = TextEditingController();
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Record Cash for ${fee.feeType}'),
          content: TextField(
            controller: amountController,
            decoration: InputDecoration(labelText: 'Amount (Outstanding: \$${fee.outstandingAmount.toStringAsFixed(2)})'),
            keyboardType: TextInputType.number,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Record'),
              onPressed: () async {
                try {
                  final double amount = double.parse(amountController.text);
                  if (amount <= 0 || amount > fee.outstandingAmount) {
                    _showSnackBar('Invalid amount. Must be positive and not exceed outstanding.', isError: true);
                    return;
                  }
                  final cashRequest = CashDepositRequest(
                    studentId: fee.studentId!,
                    feeId: fee.id!,
                    amount: amount,
                  );
                  await _adminService.recordCashDeposit(cashRequest);
                  _showSnackBar('Cash payment recorded successfully!');
                  _refreshFees();
                  Navigator.of(context).pop();
                } catch (e) {
                  _showSnackBar('Error: ${e.toString().replaceFirst('Exception: ', '')}', isError: true);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAiNoticeDialog(Student student) async {
    final TextEditingController promptController = TextEditingController();
    bool isLoading = false;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('AI Notice for ${student.name}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Enter custom instructions for the AI (optional):'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: promptController,
                    decoration: const InputDecoration(
                      hintText: 'e.g., mention the upcoming exams',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  onPressed: isLoading
                      ? null
                      : () async {
                          setDialogState(() => isLoading = true);
                          try {
                            String aiNotice = await _adminService.generateAiNotice(student.id!, promptController.text);
                            Navigator.of(context).pop(); // Close this dialog
                            _showSendNoticeDialog(student, aiNotice); // Open confirmation
                          } catch (e) {
                            _showSnackBar('AI Error: ${e.toString().replaceAll('Exception: ', '')}', isError: true);
                            setDialogState(() => isLoading = false);
                          }
                        },
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Generate'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showSendNoticeDialog(Student student, String aiNotice) async {
    final TextEditingController noticeController = TextEditingController(text: aiNotice);
    final AnnouncementService announcementService = AnnouncementService();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Review & Send Announcement'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('To: ${student.name} (STUDENT:${student.id})', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextField(
                  controller: noticeController,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  maxLines: 10,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final newAnnouncement = Announcement(
                    id: 0,
                    title: 'Fee Status Notification',
                    content: noticeController.text,
                    targetAudience: 'STUDENT:${student.id}',
                    publishDate: DateTime.now(),
                  );
                  await announcementService.createAnnouncement(newAnnouncement);
                  _showSnackBar('AI Notice successfully sent to ${student.name}!');
                  Navigator.of(context).pop();
                } catch (e) {
                  _showSnackBar('Failed to send: ${e.toString().replaceAll('Exception: ', '')}', isError: true);
                }
              },
              child: const Text('Send Notice'),
            ),
          ],
        );
      },
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fee Management'),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder<List<Student>>(
              future: _studentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error loading students: ${snapshot.error.toString().replaceFirst('Exception: ', '')}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('No students available to manage fees for.');
                } else {
                  return Column(
                    children: [
                      DropdownButtonFormField<Student>(
                        decoration: const InputDecoration(
                          labelText: 'Select Student',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedStudent,
                        items: snapshot.data!.map((student) {
                          return DropdownMenuItem(
                            value: student,
                            child: Text('${student.name} (Roll: ${student.rollNo})'),
                          );
                        }).toList(),
                        onChanged: (Student? newValue) {
                          setState(() {
                            _selectedStudent = newValue;
                            if (newValue != null && newValue.id != null) {
                              _feesFuture = _adminService.getFeesForStudent(newValue.id!); // Corrected call
                            } else {
                              _feesFuture = Future.value([]);
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: _selectedStudent != null ? () => _showFeeForm() : null,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Fee for Selected Student'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (_selectedStudent != null)
                        FutureBuilder<List<Fee>>(
                          future: _feesFuture,
                          builder: (context, feeSnapshot) {
                            if (!feeSnapshot.hasData || feeSnapshot.data!.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            
                            double totalFees = 0;
                            double totalPaid = 0;
                            double totalOutstanding = 0;
                            
                            for (var f in feeSnapshot.data!) {
                              totalFees += f.amount;
                              totalPaid += f.amountPaid;
                              totalOutstanding += f.outstandingAmount;
                            }
                            
                            return Card(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        _buildSummaryColumn('Total Fees', totalFees, Colors.blue),
                                        _buildSummaryColumn('Total Paid', totalPaid, Colors.green),
                                        _buildSummaryColumn('Outstanding', totalOutstanding, Colors.red),
                                      ],
                                    ),
                                    if (totalOutstanding > 0)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 12.0),
                                        child: ElevatedButton.icon(
                                          onPressed: () async {
                                            try {
                                              await _adminService.payAllFees(_selectedStudent!.id!);
                                              _showSnackBar('All outstanding fees marked as paid!');
                                              _refreshFees();
                                            } catch (e) {
                                              _showSnackBar('Error: ${e.toString()}', isError: true);
                                            }
                                          },
                                          icon: const Icon(Icons.done_all),
                                          label: const Text('Deposit All Outstanding'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                            minimumSize: const Size(double.infinity, 40),
                                          ),
                                        ),
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: OutlinedButton.icon(
                                        onPressed: () => _showAiNoticeDialog(_selectedStudent!),
                                        icon: const Icon(Icons.auto_awesome),
                                        label: const Text('AI Generate Notice'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.deepPurple,
                                          minimumSize: const Size(double.infinity, 40),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  );
                }
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Fee>>(
              future: _feesFuture,
              builder: (context, snapshot) {
                if (_selectedStudent == null) {
                  return const Center(child: Text('Select a student to view their fees.'));
                } else if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error.toString().replaceFirst('Exception: ', '')}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No fees found for this student.'));
                } else {
                  return RefreshIndicator(
                    onRefresh: _refreshFees,
                    child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final fee = snapshot.data![index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: ListTile(
                            leading: Icon(
                              fee.status == 'Paid' ? Icons.check_circle : (fee.status == 'Pending' ? Icons.warning : Icons.info),
                              color: fee.status == 'Paid' ? Colors.green : (fee.status == 'Pending' ? Colors.orange : Colors.blue),
                            ),
                            title: Text(fee.feeType),
                            subtitle: Text(
                              'Amount: \$${fee.amount.toStringAsFixed(2)} | Paid: \$${fee.amountPaid.toStringAsFixed(2)}\n'
                                  'Outstanding: \$${fee.outstandingAmount.toStringAsFixed(2)} | Due: ${fee.dueDate.toIso8601String().split('T').first}\n'
                                  'Status: ${fee.status}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (fee.outstandingAmount > 0)
                                  IconButton(
                                    icon: const Icon(Icons.payments, color: Colors.blue),
                                    onPressed: () => _recordCashPayment(fee),
                                    tooltip: 'Record Cash Payment',
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.grey),
                                  onPressed: () {
                                    // _showFeeForm(fee: fee); // Implement full fee editing if needed
                                    _showSnackBar('Full fee editing not implemented yet.');
                                  },
                                  tooltip: 'Edit Fee Details',
                                ),
                              ],
                            ),
                            onTap: () {
                              _showSnackBar('Viewing details for ${fee.feeType}');
                            },
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryColumn(String title, double amount, Color color) {
    return Column(
      children: [
        Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
