// lib/core/constants/app_theme.dart
// Premium dark theme for EduPay AI

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ===== Color Palette =====
  static const Color primaryDark = Color(0xFF0D1B2A);
  static const Color primaryMid = Color(0xFF1B2838);
  static const Color surfaceDark = Color(0xFF162032);
  static const Color cardDark = Color(0xFF1E2D40);
  static const Color accentBlue = Color(0xFF4FC3F7);
  static const Color accentPurple = Color(0xFF7C4DFF);
  static const Color accentGreen = Color(0xFF66BB6A);
  static const Color accentOrange = Color(0xFFFFB74D);
  static const Color accentRed = Color(0xFFEF5350);
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFB0BEC5);
  static const Color textHint = Color(0xFF78909C);
  static const Color dividerColor = Color(0xFF2C3E50);

  // ===== Gradients =====
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A237E), Color(0xFF4A148C)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E2D40), Color(0xFF263850)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentBlue, accentPurple],
  );

  // ===== Theme Data =====
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: primaryDark,
      primaryColor: accentBlue,
      colorScheme: const ColorScheme.dark(
        primary: accentBlue,
        secondary: accentPurple,
        surface: surfaceDark,
        error: accentRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme.copyWith(
              headlineLarge: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: textPrimary,
                letterSpacing: -0.5,
              ),
              headlineSmall: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
              titleMedium: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
              titleSmall: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textSecondary,
              ),
              bodyMedium: const TextStyle(
                fontSize: 14,
                color: textSecondary,
              ),
              bodySmall: const TextStyle(
                fontSize: 12,
                color: textHint,
              ),
            ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryMid,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: accentBlue),
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentBlue, width: 1.5),
        ),
        hintStyle: const TextStyle(color: textHint),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentPurple,
        foregroundColor: Colors.white,
        elevation: 8,
      ),
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cardDark,
        contentTextStyle: const TextStyle(color: textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ===== Glassmorphism Card Decoration =====
  static BoxDecoration get glassCard => BoxDecoration(
        color: cardDark.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      );

  // ===== AI Chat Bubble Styles =====
  static BoxDecoration get userBubble => BoxDecoration(
        gradient: accentGradient,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(4),
        ),
        boxShadow: [
          BoxShadow(
            color: accentBlue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      );

  static BoxDecoration get aiBubble => BoxDecoration(
        color: cardDark,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(18),
        ),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      );
}
