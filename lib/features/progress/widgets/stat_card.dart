import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_card.dart';

import '../../../core/theme/app_theme.dart';

class StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const StatCard({super.key, required this.icon, required this.color, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.metric.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(color: context.colors.textSecondary),
          ),
        ],
      ),
    );
  }
}
