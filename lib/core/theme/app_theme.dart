import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_tokens.dart';
import 'app_typography.dart';

enum AppThemeMode { light, dark }

class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(
        brightness: Brightness.light,
        bg: AppColors.lightBg,
        surface: AppColors.lightSurface,
        card: AppColors.lightCard,
        border: AppColors.lightBorder,
        textPrimary: AppColors.lightTextPrimary,
        textSecondary: AppColors.lightTextSecondary,
      );

  static ThemeData dark() => _build(
        brightness: Brightness.dark,
        bg: AppColors.darkBg,
        surface: AppColors.darkSurface,
        card: AppColors.darkCard,
        border: AppColors.darkBorder,
        textPrimary: AppColors.darkTextPrimary,
        textSecondary: AppColors.darkTextSecondary,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color bg,
    required Color surface,
    required Color card,
    required Color border,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: isDark ? AppColors.marigold500 : AppColors.marigold700,
      onPrimary: AppColors.ink900,
      secondary: isDark ? AppColors.verdigris500 : Color(0xFF1F5A4E),
      onSecondary: Colors.white,
      tertiary: AppColors.marigold300,
      onTertiary: AppColors.ink900,
      error: AppColors.rosewood500,
      onError: Colors.white,
      surface: surface,
      onSurface: textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bg,
      canvasColor: bg,
      splashFactory: InkRipple.splashFactory,
      fontFamily: AppTypography.bodyMedium.fontFamily,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge.copyWith(color: textPrimary),
        displayMedium: AppTypography.displayMedium.copyWith(color: textPrimary),
        headlineLarge: AppTypography.headlineLarge.copyWith(color: textPrimary),
        headlineMedium: AppTypography.headlineMedium.copyWith(color: textPrimary),
        titleLarge: AppTypography.titleLarge.copyWith(color: textPrimary),
        titleMedium: AppTypography.titleMedium.copyWith(color: textPrimary),
        bodyLarge: AppTypography.bodyLarge.copyWith(color: textPrimary),
        bodyMedium: AppTypography.bodyMedium.copyWith(color: textSecondary),
        bodySmall: AppTypography.bodySmall.copyWith(color: textSecondary),
        labelLarge: AppTypography.labelLarge.copyWith(color: textPrimary),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: bg,
        foregroundColor: textPrimary,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTypography.headlineMedium.copyWith(color: textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: IconThemeData(color: textPrimary, size: 20),
      ),
      cardColor: card,
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card), side: BorderSide(color: border, width: 1.0)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card), side: BorderSide(color: border)),
        titleTextStyle: AppTypography.titleLarge.copyWith(color: textPrimary, fontWeight: FontWeight.bold),
        contentTextStyle: AppTypography.bodyMedium.copyWith(color: textSecondary),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.marigold500,
        foregroundColor: AppColors.ink900,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.ink600 : surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: AppTypography.bodyMedium.copyWith(color: textSecondary.withOpacity(0.7)),
        labelStyle: AppTypography.bodyMedium.copyWith(color: textSecondary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.input), borderSide: BorderSide(color: border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.input), borderSide: BorderSide(color: border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.input), borderSide: const BorderSide(color: AppColors.marigold500, width: 1.6)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.marigold500,
          foregroundColor: AppColors.ink900,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: AppTypography.labelLarge,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: BorderSide(color: border),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.marigold500, textStyle: AppTypography.labelLarge),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: card,
        selectedColor: AppColors.marigold500.withOpacity(0.18),
        secondarySelectedColor: AppColors.marigold500.withOpacity(0.18),
        labelStyle: AppTypography.labelMedium.copyWith(color: textPrimary),
        secondaryLabelStyle: AppTypography.labelMedium.copyWith(color: AppColors.marigold500, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill), side: BorderSide(color: border)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        elevation: 0,
        pressElevation: 0,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        modalBackgroundColor: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.sheetBorder),
        showDragHandle: false,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.verdigris500),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? AppColors.ink900 : textSecondary),
        trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? AppColors.marigold500 : border),
      ),
      iconTheme: IconThemeData(color: textPrimary),
      extensions: [CadenceColors(bg: bg, surface: surface, card: card, border: border, textPrimary: textPrimary, textSecondary: textSecondary, isDark: isDark)],
    );
  }
}

/// Custom theme extension so widgets can read semantic tokens without
/// re-deriving them from brightness everywhere.
class CadenceColors extends ThemeExtension<CadenceColors> {
  final Color bg;
  final Color surface;
  final Color card;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final bool isDark;

  const CadenceColors({
    required this.bg,
    required this.surface,
    required this.card,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.isDark,
  });

  @override
  CadenceColors copyWith({Color? bg, Color? surface, Color? card, Color? border, Color? textPrimary, Color? textSecondary, bool? isDark}) {
    return CadenceColors(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      card: card ?? this.card,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      isDark: isDark ?? this.isDark,
    );
  }

  @override
  CadenceColors lerp(ThemeExtension<CadenceColors>? other, double t) {
    if (other is! CadenceColors) return this;
    return CadenceColors(
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      card: Color.lerp(card, other.card, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }
}

extension CadenceColorsX on BuildContext {
  CadenceColors get colors => Theme.of(this).extension<CadenceColors>()!;
}
