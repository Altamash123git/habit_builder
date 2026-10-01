import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/habit.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/date_utils.dart';
import '../../../shared/widgets/animated_check.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/cadence_ribbon.dart';
import '../../../shared/widgets/streak_flame.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback onTap;
  const HabitCard({super.key, required this.habit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final done = state.isHabitDoneToday(habit);
    final streak = AppDate.currentStreak(habit.completedDates);
    final isCounter = habit.isCounterHabit;
    final count = habit.currentCountToday;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedCheck(
                  checked: done,
                  onTap: () => context.read<AppState>().toggleHabitToday(habit.id),
                  color: habit.color,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: habit.color.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: habit.color.withOpacity(0.3)),
                  ),
                  child: Icon(habit.icon, color: habit.color, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.title,
                        style: AppTypography.titleMedium.copyWith(
                          color: done ? context.colors.textSecondary : context.colors.textPrimary,
                          decoration: done ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      if (isCounter) ...[
                        const SizedBox(height: 2),
                        Text(
                          '$count / ${habit.targetCount} ${habit.unit}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: done ? AppColors.verdigris500 : habit.color,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isCounter) ...[
                  ElevatedButton(
                    onPressed: () => context.read<AppState>().incrementHabitCount(habit.id, delta: 1),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: done ? AppColors.verdigris500 : habit.color,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add_rounded, size: 16),
                        const SizedBox(width: 2),
                        Text('+1', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                StreakFlame(streak: streak, iconSize: 14),
              ],
            ),
            const SizedBox(height: 12),
            // Compact ribbon preview
            CadenceRibbon(
              completedDates: habit.completedDates,
              daysCount: 14,
              compact: true,
              height: 14,
            ),
          ],
        ),
      ),
    );
  }
}
