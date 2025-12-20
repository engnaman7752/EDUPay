// lib/models/student.dart

import 'dart:convert';

class Student {
  final int? id;
  final String studentId;
  final String name;
  final String rollNo;
  final String mobileNo;
  final String standard;
  // Note: 'admin' field from backend entity is not directly included here,
  // as it's managed by the backend based on the authenticated admin.

  Student({
    this.id,
    required this.studentId,
    required this.name,
    required this.rollNo,
    required this.mobileNo,
    required this.standard,
  });

  // Create a Student object from a JSON map
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] as int?,
      studentId: json['studentId'] as String,
      name: json['name'] as String,
      rollNo: json['rollNo'] as String,
      mobileNo: json['mobileNo'] as String,
      standard: json['standard'] as String,
    );
  }

  // Convert a Student object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'name': name,
      'rollNo': rollNo,
      'mobileNo': mobileNo,
      'standard': standard,
    };
  }
}
// Function to parse a list of students from a JSON string
List<Student> parseStudents(String jsonString) {
  final List<dynamic> jsonList = json.decode(jsonString);
  return jsonList.map((json) => Student.fromJson(json)).toList();
}
// Function to convert a list of students to a JSON string
String studentsToJson(List<Student> students) {
  final List<Map<String, dynamic>> jsonList =
      students.map((student) => student.toJson()).toList();
  return json.encode(jsonList);
}



