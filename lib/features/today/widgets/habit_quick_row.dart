import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/habit.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/animated_check.dart';
import '../../../shared/widgets/app_card.dart';

class HabitQuickRow extends StatelessWidget {
  final Habit habit;
  const HabitQuickRow({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final done = state.isHabitDoneToday(habit);
    final count = habit.currentCountToday;
    final isCounter = habit.isCounterHabit;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        showShadow: false,
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: habit.color.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: habit.color.withOpacity(0.3)),
                  ),
                  child: Icon(habit.icon, color: habit.color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.title,
                        style: AppTypography.titleMedium.copyWith(
                          fontSize: 15,
                          color: done ? context.colors.textSecondary : context.colors.textPrimary,
                          decoration: done ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      if (isCounter) ...[
                        const SizedBox(height: 3),
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
                  // Decrement button (-1) if count > 0
                  if (count > 0)
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline_rounded, size: 22),
                      color: context.colors.textSecondary,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      onPressed: () => context.read<AppState>().incrementHabitCount(habit.id, delta: -1),
                    ),
                  const SizedBox(width: 4),
                  // Quick Increment (+1) button
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
                        Text('+1 ${habit.unit == 'glasses' ? 'glass' : ''}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                AnimatedCheck(
                  checked: done,
                  onTap: () => context.read<AppState>().toggleHabitToday(habit.id),
                  color: habit.color,
                  size: 28,
                ),
              ],
            ),
            if (isCounter) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: habit.dailyProgressToday,
                  minHeight: 4,
                  backgroundColor: context.colors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(done ? AppColors.verdigris500 : habit.color),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
