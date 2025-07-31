// lib/screens/auth/login_page.dart

import 'package:flutter/material.dart';
import 'package:edupay_app/services/auth_service.dart';
import 'package:edupay_app/screens/admin/admin_dashboard.dart';
import 'package:edupay_app/utils/token_manager.dart';

import '../student/student_dashboard.dart'; // Import TokenManager

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // Check if user is already logged in
  }

  // Checks if a token exists and navigates to the appropriate dashboard
  Future<void> _checkLoginStatus() async {
    final token = await TokenManager.getToken();
    final role = await TokenManager.getRole();
    if (token != null && role != null) {
      if (role == 'ADMIN') {
        _navigateToAdminDashboard();
      } else if (role == 'STUDENT') {
        _navigateToStudentDashboard();
      }
    }
  }

  void _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final String username = _usernameController.text;
    final String password = _passwordController.text;

    try {
      final authResponse = await _authService.login(username, password);

      if (authResponse.role == 'ADMIN') {
        _navigateToAdminDashboard();
      } else if (authResponse.role == 'STUDENT') {
        _navigateToStudentDashboard();
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToAdminDashboard() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AdminDashboard()),
    );
  }

  void _navigateToStudentDashboard() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const StudentDashboard()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EduPay Login'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.school,
                size: 100,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 20),
              Text(
                'Welcome to EduPay',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
              const SizedBox(height: 20),
              // Optional: Admin Registration button (for initial setup)
              TextButton(
                onPressed: () async {
                  // This is a simplified admin registration. In a real app,
                  // you might have a separate, more secure registration flow.
                  try {
                    setState(() { _isLoading = true; });
                    await _authService.registerAdmin('initial_admin', 'secure_admin_pass');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Initial admin registered! You can now log in.')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Admin registration failed: ${e.toString().replaceFirst('Exception: ', '')}')),
                    );
                  } finally {
                    setState(() { _isLoading = false; });
                  }
                },
                child: const Text('Register Initial Admin (Dev Only)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// Note: The LoginPage is the entry point for users to log in to the EduPay application.
// It handles user authentication and redirects to the appropriate dashboard based on the user's role.