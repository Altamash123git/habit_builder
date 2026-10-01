import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_tokens.dart';

class ThemeSelector extends StatelessWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Row(
      children: [
        for (final mode in AppThemeMode.values)
          Expanded(
            child: GestureDetector(
              onTap: () => context.read<AppState>().setThemeMode(mode),
              child: AnimatedContainer(
                duration: AppDuration.fast,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: state.themeMode == mode ? AppColors.primary.withOpacity(0.14) : context.colors.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: state.themeMode == mode ? AppColors.primary : context.colors.border,
                    width: state.themeMode == mode ? 1.6 : 1.0,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      switch (mode) {
                        AppThemeMode.light => Icons.light_mode_rounded,
                        AppThemeMode.dark => Icons.dark_mode_rounded,
                      },
                      color: state.themeMode == mode ? AppColors.primary : context.colors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      switch (mode) { AppThemeMode.light => 'Light', AppThemeMode.dark => 'Dark' },
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: state.themeMode == mode ? AppColors.primary : context.colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
