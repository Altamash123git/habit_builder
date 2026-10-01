import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized type scale for Marigold Nocturne:
/// - 'Fraunces' (display/headline — warm old-style display)
/// - 'Hanken Grotesk' (body/UI — clean, legible UI text)
/// - 'Space Mono' (metrics/timer/streaks — the app's rhythm metronome)
class AppTypography {
  AppTypography._();

  static TextStyle _fraunces(double size, FontWeight w, {double? height, double? letterSpacing}) =>
      GoogleFonts.fraunces(fontSize: size, fontWeight: w, height: height, letterSpacing: letterSpacing);

  static TextStyle _hanken(double size, FontWeight w, {double? height, double? letterSpacing}) =>
      GoogleFonts.hankenGrotesk(fontSize: size, fontWeight: w, height: height, letterSpacing: letterSpacing);

  static TextStyle _spaceMono(double size, FontWeight w, {double? height, double? letterSpacing}) =>
      GoogleFonts.spaceMono(fontSize: size, fontWeight: w, height: height, letterSpacing: letterSpacing);

  // Fraunces Display
  static TextStyle displayLarge = _fraunces(34, FontWeight.w500, height: 40 / 34, letterSpacing: -0.5);
  static TextStyle displayMedium = _fraunces(28, FontWeight.w500, height: 34 / 28, letterSpacing: -0.4);
  static TextStyle headlineLarge = _fraunces(24, FontWeight.w600, height: 1.25);
  static TextStyle headlineMedium = _fraunces(20, FontWeight.w600, height: 1.3);

  // Hanken Grotesk UI & Body
  static TextStyle titleLarge = _hanken(20, FontWeight.w600, height: 26 / 20);
  static TextStyle titleMedium = _hanken(18, FontWeight.w600, height: 24 / 18);
  static TextStyle bodyLarge = _hanken(16, FontWeight.w400, height: 24 / 16);
  static TextStyle bodyMedium = _hanken(14, FontWeight.w400, height: 20 / 14);
  static TextStyle bodySmall = _hanken(12.5, FontWeight.w400, height: 16 / 12.5);
  static TextStyle labelLarge = _hanken(14, FontWeight.w600, letterSpacing: 0.3);
  static TextStyle labelMedium = _hanken(13, FontWeight.w600, letterSpacing: 0.3);
  static TextStyle labelSmall = _hanken(11, FontWeight.w600, letterSpacing: 0.4);

  // Space Mono Metronome Metrics
  static TextStyle metricXL = _spaceMono(48, FontWeight.w700, height: 52 / 48);
  static TextStyle metric = _spaceMono(15, FontWeight.w500, height: 20 / 15);
  static TextStyle numeric = _spaceMono(28, FontWeight.w700, height: 1.0, letterSpacing: -0.5);
}
