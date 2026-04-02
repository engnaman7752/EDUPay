// lib/domain/models/edupay_user.dart
// Domain-level user model with role enum

enum EduPayRole { ADMIN, ANALYST, VIEWER, STUDENT }

extension EduPayRoleExt on EduPayRole {
  String get label {
    switch (this) {
      case EduPayRole.ADMIN:    return 'Admin';
      case EduPayRole.ANALYST:  return 'Analyst';
      case EduPayRole.VIEWER:   return 'Viewer';
      case EduPayRole.STUDENT:  return 'Student';
    }
  }

  bool get canEdit => this == EduPayRole.ADMIN;
  bool get canViewFinance =>
      this == EduPayRole.ADMIN ||
      this == EduPayRole.ANALYST ||
      this == EduPayRole.VIEWER;
  bool get isStudent => this == EduPayRole.STUDENT;
}

class EduPayUser {
  final String id;
  final String username;
  final String token;
  final EduPayRole role;
  final String? studentId; // only for STUDENT role
  final String? standard;  // class (1-12) for student

  const EduPayUser({
    required this.id,
    required this.username,
    required this.token,
    required this.role,
    this.studentId,
    this.standard,
  });

  factory EduPayUser.fromAuthResponse(Map<String, dynamic> json) {
    final roleStr = (json['role'] as String? ?? 'STUDENT').toUpperCase();
    final role = EduPayRole.values.firstWhere(
      (r) => r.name == roleStr,
      orElse: () => EduPayRole.STUDENT,
    );
    return EduPayUser(
      id: json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      token: json['token'] ?? '',
      role: role,
    );
  }
}
