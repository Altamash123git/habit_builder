import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';

class StreakFlame extends StatelessWidget {
  final int streak;
  final double iconSize;
  const StreakFlame({super.key, required this.streak, this.iconSize = 15});

  @override
  Widget build(BuildContext context) {
    final active = streak > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: active ? AppColors.marigold500 : context.colors.card,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: active ? AppColors.marigold300 : context.colors.border),
        boxShadow: active
            ? [
                BoxShadow(
                  color: AppColors.marigold500.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.wb_sunny_rounded,
            size: iconSize,
            color: active ? AppColors.ink900 : context.colors.textSecondary,
          ),
          const SizedBox(width: 5),
          Text(
            '$streak',
            style: AppTypography.metric.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: active ? AppColors.ink900 : context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
