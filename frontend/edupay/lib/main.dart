//Jai Shri Shyam
// EduPay App - Main Entry Point (Enhanced with AI & Real-time features)
// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edupay_app/core/constants/app_theme.dart';
import 'package:edupay_app/screens/auth/login_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: EduPayApp(),
    ),
  );
}

class EduPayApp extends StatelessWidget {
  const EduPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduPay AI',
      theme: AppTheme.lightTheme,
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
