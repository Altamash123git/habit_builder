import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Spacing scale — use these instead of magic numbers everywhere.
class AppSpacing {
  AppSpacing._();
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 20);
  static const EdgeInsets cardPadding = EdgeInsets.all(18);
}

/// Corner radius scale — Marigold Nocturne shapes:
/// cards 20, sheets 28, buttons/FAB 16, chips full, inputs 14.
class AppRadius {
  AppRadius._();
  static const double input = 14;
  static const double button = 16;
  static const double card = 20;
  static const double sheet = 28;
  static const double pill = 999;

  static BorderRadius get cardBorder => BorderRadius.circular(card);
  static BorderRadius get buttonBorder => BorderRadius.circular(button);
  static BorderRadius get sheetBorder => const BorderRadius.vertical(top: Radius.circular(sheet));
  static BorderRadius get chipBorder => BorderRadius.circular(pill);
  static BorderRadius get chip => BorderRadius.circular(pill);
}

/// Motion durations & curves — calm, purposeful nocturne feel.
class AppDuration {
  AppDuration._();
  static const Duration fast = Duration(milliseconds: 160);
  static const Duration base = Duration(milliseconds: 260);
  static const Duration glow = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 420);
  static const Duration celebrate = Duration(milliseconds: 900);
  static const Curve curve = Curves.easeOutCubic;
  static const Curve bounce = Curves.easeOutBack;
}

/// Saffron Glow & Hairline Lamplight Shadows
class AppShadows {
  AppShadows._();

  static List<BoxShadow> card(BuildContext context) {
    return [
      BoxShadow(
        color: AppColors.marigold500.withOpacity(0.06),
        blurRadius: 16,
        spreadRadius: 0,
        offset: const Offset(0, 4),
      ),
    ];
  }

  static List<BoxShadow> soft(BuildContext context) {
    return [
      BoxShadow(
        color: AppColors.marigold500.withOpacity(0.04),
        blurRadius: 8,
        spreadRadius: 0,
        offset: const Offset(0, 2),
      ),
    ];
  }

  /// Ambient saffron glow bloom behind active / lit elements (streaks, timer, FAB)
  static List<BoxShadow> glow(Color color, {double opacity = 0.22}) => [
        BoxShadow(
          color: color.withOpacity(opacity),
          blurRadius: 16,
          spreadRadius: 2,
          offset: Offset.zero,
        ),
      ];
}

/// Signature Marigold Nocturne gradients
class AppGradients {
  AppGradients._();

  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.marigold500, AppColors.marigold300],
  );

  static const LinearGradient streak = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.marigold500, AppColors.marigold700],
  );

  static const LinearGradient focus = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.verdigris500, AppColors.verdigris300],
  );

  static const LinearGradient premium = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.ink700, AppColors.marigold500, AppColors.verdigris500],
  );
}
