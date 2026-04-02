// lib/core/theme/hub_theme.dart
// Dark glassmorphism theme constants for EduPay AI Hub

import 'package:flutter/material.dart';

class HubTheme {
  // ─── Core Palette ─────────────────────────────────────────────
  static const Color navyDeep   = Color(0xFF070B14);
  static const Color navyMid    = Color(0xFF0D1321);
  static const Color navySurface = Color(0xFF111827);
  static const Color glassWhite = Color(0x14FFFFFF); // 8% white
  static const Color borderGlass = Color(0x26FFFFFF); // 15% white

  static const Color cyan    = Color(0xFF00E5FF);
  static const Color cyanDim = Color(0xFF0097A7);
  static const Color violet  = Color(0xFF7B2FFF);
  static const Color amber   = Color(0xFFFFB300);
  static const Color green   = Color(0xFF00E676);
  static const Color red     = Color(0xFFFF1744);

  static const Color textPrimary   = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textHint      = Color(0xFF4A5568);

  // ─── Gradients ────────────────────────────────────────────────
  static const LinearGradient cyanGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [cyan, violet],
  );

  static const LinearGradient kpiIncomeGradient = LinearGradient(
    colors: [Color(0xFF00B4D8), Color(0xFF0096C7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient kpiOutstandingGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient kpiStudentsGradient = LinearGradient(
    colors: [Color(0xFF7B2FFF), Color(0xFF9D4EDD)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── Glass card decoration ─────────────────────────────────────
  static BoxDecoration glassCard({
    double borderRadius = 16,
    Color? borderColor,
    List<BoxShadow>? shadows,
  }) =>
      BoxDecoration(
        color: glassWhite,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? borderGlass,
          width: 1,
        ),
        boxShadow: shadows ??
            [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
      );

  // ─── Neon glow box shadow ──────────────────────────────────────
  static List<BoxShadow> neonGlow(Color color, {double radius = 18}) => [
        BoxShadow(color: color.withOpacity(0.45), blurRadius: radius, spreadRadius: 2),
        BoxShadow(color: color.withOpacity(0.18), blurRadius: radius * 2),
      ];

  // ─── ThemeData ─────────────────────────────────────────────────
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: navyDeep,
        primaryColor: cyan,
        fontFamily: 'Inter',
        colorScheme: const ColorScheme.dark(
          primary: cyan,
          secondary: violet,
          surface: navySurface,
          error: red,
          onPrimary: Colors.black,
          onSecondary: Colors.white,
          onSurface: textPrimary,
        ),
        dividerColor: borderGlass,
        textTheme: const TextTheme(
          displaySmall:
              TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 32),
          headlineMedium:
              TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 24),
          headlineSmall:
              TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 20),
          titleLarge:
              TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 16),
          titleMedium:
              TextStyle(color: textSecondary, fontWeight: FontWeight.w500, fontSize: 14),
          bodyMedium: TextStyle(color: textSecondary, fontSize: 13),
          labelSmall: TextStyle(color: textHint, fontSize: 11),
        ),
      );
}
