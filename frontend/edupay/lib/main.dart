//Jai Shri Shyam
// EduPay App - Main Entry Point
// lib/main.dart

import 'package:flutter/material.dart';
import 'package:edupay_app/screens/auth/login_page.dart'; // Import My LoginPage

void main() {
  runApp(const EduPayApp());
}

class EduPayApp extends StatelessWidget {
  const EduPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduPay', // My application title
      theme: ThemeData(
        primarySwatch: Colors.blue, // My primary app color
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter', // Ensure you have the 'Inter' font set up in pubspec.yaml if you use it
        useMaterial3: true, // Use Material 3 design
      ),
      home: const LoginPage(), // Set the initial screen to LoginPage
      debugShowCheckedModeBanner: false, // Set to false for production
    );
  }
}
