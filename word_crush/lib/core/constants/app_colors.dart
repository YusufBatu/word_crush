// ============================================================
// core/constants/app_colors.dart
// ============================================================
import 'package:flutter/material.dart';

class AppColors {
  // Background
  static const Color background = Color(0xFF0F0E17);
  static const Color surface = Color(0xFF1A1A2E);
  static const Color surfaceLight = Color(0xFF16213E);

  // Primary gradient
  static const Color primaryStart = Color(0xFF6C63FF);
  static const Color primaryEnd   = Color(0xFFE040FB);

  // Cell colors
  static const Color cellDefault    = Color(0xFF1E2040);
  static const Color cellSelected   = Color(0xFFFFD700);
  static const Color cellGlow       = Color(0xFFFFEB3B);
  static const Color cellRowClear   = Color(0xFF00BCD4);
  static const Color cellAreaClear  = Color(0xFFFF5722);
  static const Color cellColClear   = Color(0xFF4CAF50);
  static const Color cellMega       = Color(0xFFE040FB);

  // Text
  static const Color textPrimary    = Color(0xFFEEEEEE);
  static const Color textSecondary  = Color(0xFF9E9E9E);
  static const Color textGold       = Color(0xFFFFD700);

  // UI
  static const Color gold           = Color(0xFFFFD700);
  static const Color success        = Color(0xFF4CAF50);
  static const Color danger         = Color(0xFFFF5252);
  static const Color warning        = Color(0xFFFFB300);

  // Glassmorphism
  static Color glassWhite = Colors.white.withOpacity(0.06);
  static Color glassBorder = Colors.white.withOpacity(0.15);

  // Power cell colors
  static const Map<String, Color> powerColors = {
    'rowClear':  Color(0xFF00BCD4),
    'areaClear': Color(0xFFFF5722),
    'colClear':  Color(0xFF4CAF50),
    'mega':      Color(0xFFE040FB),
  };
}
