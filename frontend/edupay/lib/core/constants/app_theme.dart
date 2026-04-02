// lib/core/constants/app_theme.dart
// Premium light theme for EduPay AI

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ===== Color Palette (Light Mode) =====
  static const Color primaryLight = Color(0xFFF8F9FA);
  static const Color primaryMid = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  
  // Specific requested colors
  static const Color electricBlue = Color(0xFF3F51B5); // Payment & WebSocket action layer
  static const Color softIndigo = Color(0xFFE8EAF6); // AI bubble
  static const Color mintGreen = Color(0xFFE8F5E9); // Success badges

  static const Color accentPurple = Color(0xFF7C4DFF);
  static const Color accentOrange = Color(0xFFFFB74D);
  static const Color accentRed = Color(0xFFEF5350);
  
  // Legacy aliases to prevent build breakages across the app
  static const Color accentBlue = electricBlue;
  static const Color accentGreen = mintGreen;
  static const Color cardDark = cardLight;
  static const Color primaryDark = primaryLight;
  
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color dividerColor = Color(0xFFEEEEEE);

  // ===== Gradients =====
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [electricBlue, accentPurple],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [electricBlue, accentPurple],
  );

  // ===== Theme Data =====
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: primaryLight,
      primaryColor: electricBlue,
      colorScheme: const ColorScheme.light(
        primary: electricBlue,
        secondary: accentPurple,
        surface: surfaceLight,
        error: accentRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.light().textTheme.copyWith(
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
        backgroundColor: electricBlue,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: cardLight,
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: electricBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: electricBlue, width: 1.5),
        ),
        hintStyle: const TextStyle(color: textHint),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: electricBlue,
        foregroundColor: Colors.white,
        elevation: 6,
      ),
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimary,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ===== Glassmorphism Card Decoration =====
  static BoxDecoration get glassCard => BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      );

  // ===== AI Chat Bubble Styles =====
  static BoxDecoration get userBubble => BoxDecoration(
        color: electricBlue,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(4),
        ),
        boxShadow: [
          BoxShadow(
            color: electricBlue.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      );

  static BoxDecoration get aiBubble => BoxDecoration(
        color: softIndigo,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(18),
        ),
        border: Border.all(color: electricBlue.withOpacity(0.1)),
      );
}
