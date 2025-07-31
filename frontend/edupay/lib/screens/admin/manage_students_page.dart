// lib/screens/admin/manage_students_page.dart

import 'package:flutter/material.dart';
import 'package:edupay_app/models/student.dart';
import 'package:edupay_app/services/admin_service.dart';

class ManageStudentsPage extends StatefulWidget {
  const ManageStudentsPage({super.key});

  @override
  State<ManageStudentsPage> createState() => _ManageStudentsPageState();
}

class _ManageStudentsPageState extends State<ManageStudentsPage> {
  final AdminService _adminService = AdminService();
  late Future<List<Student>> _studentsFuture;

  @override
  void initState() {
    super.initState();
    _studentsFuture = _adminService.getAllStudents();
  }

  Future<void> _refreshStudents() async {
    setState(() {
      _studentsFuture = _adminService.getAllStudents();
    });
  }

  Future<void> _showStudentForm({Student? student}) async {
    final bool isEditing = student != null;
    final TextEditingController studentIdController = TextEditingController(text: student?.studentId);
    final TextEditingController nameController = TextEditingController(text: student?.name);
    final TextEditingController rollNoController = TextEditingController(text: student?.rollNo);
    final TextEditingController mobileNoController = TextEditingController(text: student?.mobileNo);
    final TextEditingController standardController = TextEditingController(text: student?.standard);

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Student' : 'Add New Student'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: studentIdController,
                  decoration: const InputDecoration(labelText: 'Student ID'),
                  enabled: !isEditing, // Student ID usually not editable
                ),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: rollNoController,
                  decoration: const InputDecoration(labelText: 'Roll No'),
                ),
                TextField(
                  controller: mobileNoController,
                  decoration: const InputDecoration(labelText: 'Mobile No (Password)'),
                  keyboardType: TextInputType.phone,
                ),
                TextField(
                  controller: standardController,
                  decoration: const InputDecoration(labelText: 'Standard'),
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
                  final newStudent = Student(
                    id: student?.id,
                    studentId: studentIdController.text,
                    name: nameController.text,
                    rollNo: rollNoController.text,
                    mobileNo: mobileNoController.text,
                    standard: standardController.text,
                  );

                  if (isEditing) {
                    await _adminService.updateStudent(student!.id!, newStudent);
                    _showSnackBar('Student updated successfully!');
                  } else {
                    await _adminService.addStudent(newStudent);
                    _showSnackBar('Student added successfully!');
                  }
                  _refreshStudents();
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

  Future<void> _deleteStudent(int id) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this student? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await _adminService.deleteStudent(id);
        _showSnackBar('Student deleted successfully!');
        _refreshStudents();
      } catch (e) {
        _showSnackBar('Error: ${e.toString().replaceFirst('Exception: ', '')}', isError: true);
      }
    }
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
        title: const Text('Manage Students'),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () => _showStudentForm(),
              icon: const Icon(Icons.person_add),
              label: const Text('Add New Student'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Student>>(
              future: _studentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error.toString().replaceFirst('Exception: ', '')}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No students found. Add a new student!'));
                } else {
                  return RefreshIndicator(
                    onRefresh: _refreshStudents,
                    child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final student = snapshot.data![index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(student.rollNo),
                            ),
                            title: Text(student.name),
                            subtitle: Text('ID: ${student.studentId} | Class: ${student.standard} | Mobile: ${student.mobileNo}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _showStudentForm(student: student),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteStudent(student.id!),
                                ),
                              ],
                            ),
                            onTap: () {
                              // Optionally view full details
                              _showSnackBar('Viewing details for ${student.name}');
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
}
// This file is part of the EduPay project, which is an educational payment management system.
// It is designed to help administrators manage student records efficiently.