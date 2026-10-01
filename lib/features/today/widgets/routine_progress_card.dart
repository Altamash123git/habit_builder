import 'package:flutter/material.dart';
import '../../../core/models/routine.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/progress_ring.dart';

import '../../../core/theme/app_theme.dart';

class RoutineProgressCard extends StatelessWidget {
  final Routine routine;
  final VoidCallback onTap;
  const RoutineProgressCard({super.key, required this.routine, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = routine.category.color;
    final isDone = routine.isDoneToday;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withOpacity(0.18),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Icon(routine.category.icon, color: color, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    routine.title,
                    style: AppTypography.titleMedium.copyWith(color: context.colors.textPrimary),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${routine.completedCount}/${routine.tasks.length} tasks',
                    style: AppTypography.metric.copyWith(fontSize: 12, color: context.colors.textSecondary),
                  ),
                ],
              ),
            ),
            ProgressRing(
              progress: routine.progress,
              size: 42,
              strokeWidth: 5,
              color: isDone ? AppColors.marigold500 : AppColors.verdigris500,
              center: isDone ? const Icon(Icons.check_rounded, size: 18, color: AppColors.verdigris500) : null,
            ),
          ],
        ),
      ),
    );
  }
}
