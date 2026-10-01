import 'package:flutter/material.dart';
import '../../../core/models/routine.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_card.dart';

import '../../../core/theme/app_theme.dart';

class RoutineCard extends StatelessWidget {
  final Routine routine;
  final VoidCallback onTap;
  const RoutineCard({super.key, required this.routine, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final categoryColor = routine.category.color;
    final isDone = routine.isDoneToday;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: AppCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: categoryColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(routine.category.icon, size: 13, color: categoryColor),
                      const SizedBox(width: 5),
                      Text(
                        routine.category.label,
                        style: AppTypography.labelSmall.copyWith(color: categoryColor),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (isDone)
                  const Icon(Icons.check_rounded, color: AppColors.verdigris500, size: 20)
                else
                  Text(
                    '${routine.completedCount}/${routine.tasks.length}',
                    style: AppTypography.metric.copyWith(fontSize: 12, color: context.colors.textSecondary),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              routine.title,
              style: AppTypography.titleLarge.copyWith(color: context.colors.textPrimary),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: routine.progress),
                duration: const Duration(milliseconds: 600),
                builder: (context, value, _) => LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  backgroundColor: context.colors.border,
                  valueColor: AlwaysStoppedAnimation(
                    isDone ? AppColors.marigold500 : AppColors.verdigris500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
