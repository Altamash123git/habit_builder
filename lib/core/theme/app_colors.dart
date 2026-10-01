import 'package:flutter/material.dart';

/// App brand palette matching applogo.png — Vibrant Royal Blue / Indigo
/// paired with crisp light and dark theme neutrals.
class AppColors {
  AppColors._();

  // Royal Blue / Indigo Ramp (Matching applogo.png)
  static const Color royalBlue500 = Color(0xFF4353FF); // Vibrant Royal Indigo Blue
  static const Color royalBlue300 = Color(0xFF7B88FF); // Light Indigo Blue
  static const Color royalBlue700 = Color(0xFF2C39C9); // Deep Royal Blue

  // Primary aliases
  static const Color primary = royalBlue500;
  static const Color primaryDark = royalBlue700;
  static const Color primaryLight = royalBlue300;

  // Backwards compatibility with marigold getters
  static const Color marigold500 = royalBlue500;
  static const Color marigold300 = royalBlue300;
  static const Color marigold700 = royalBlue700;

  // Core Ink Ramp (Dark Theme)
  static const Color ink900 = Color(0xFF0B0F19);
  static const Color ink800 = Color(0xFF0F172A);
  static const Color ink700 = Color(0xFF1E293B);
  static const Color ink600 = Color(0xFF334155);
  static const Color ink500 = Color(0xFF475569);

  // Core Linen Ramp (Text & Captions)
  static const Color linen100 = Color(0xFFF8FAFC);
  static const Color linen300 = Color(0xFFCBD5E1);
  static const Color linen500 = Color(0xFF94A3B8);

  // Accents
  static const Color verdigris500 = Color(0xFF10B981);
  static const Color verdigris300 = Color(0xFF34D399);
  static const Color rosewood500 = Color(0xFFEF4444);
  static const Color waterBlue = Color(0xFF0284C7);

  static const Color secondary = verdigris500;
  static const Color secondaryDark = Color(0xFF047857);

  static const Color streak = royalBlue500;
  static const Color streakGlow = royalBlue300;

  static const Color success = verdigris500;
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = rosewood500;

  // Light theme neutrals
  static const Color paper50 = Color(0xFFF8FAFC);
  static const Color paper100 = Color(0xFFFFFFFF);
  static const Color lightBg = paper50;
  static const Color lightSurface = paper100;
  static const Color lightCard = paper100;
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);

  // Dark theme neutrals
  static const Color darkBg = ink800;
  static const Color darkSurface = ink700;
  static const Color darkCard = ink700;
  static const Color darkBorder = ink600;
  static const Color darkTextPrimary = linen100;
  static const Color darkTextSecondary = linen500;

  // Category accents (routine/habit tags)
  static const List<Color> categoryAccents = [
    royalBlue500,
    waterBlue,
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
  ];
}
