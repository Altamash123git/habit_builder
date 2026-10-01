import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/progress_ring.dart';

import '../../../core/theme/app_theme.dart';

class TodayHeroCard extends StatelessWidget {
  final int doneTasks;
  final int totalTasks;
  final int doneHabits;
  final int totalHabits;

  const TodayHeroCard({
    super.key,
    required this.doneTasks,
    required this.totalTasks,
    required this.doneHabits,
    required this.totalHabits,
  });

  @override
  Widget build(BuildContext context) {
    final totalDone = doneTasks + doneHabits;
    final totalAll = totalTasks + totalHabits;
    final progress = totalAll == 0 ? 0.0 : totalDone / totalAll;
    final isComplete = progress >= 1.0 && totalAll > 0;

    return AppCard(
      showShadow: true,
      child: Row(
        children: [
          ProgressRing(
            progress: progress,
            size: 78,
            strokeWidth: 8,
            color: isComplete ? AppColors.marigold500 : AppColors.verdigris500,
            center: Text(
              '${(progress * 100).round()}%',
              style: AppTypography.metric.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isComplete ? AppColors.marigold500 : AppColors.verdigris500,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  totalAll == 0
                      ? 'Add a routine or habit to begin'
                      : (isComplete ? 'Day complete — lamps lit' : 'Today\'s rhythm'),
                  style: AppTypography.headlineMedium.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$totalDone of $totalAll tasks & habits completed',
                  style: AppTypography.metric.copyWith(
                    fontSize: 12.5,
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
