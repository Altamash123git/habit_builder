import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/habit.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/date_utils.dart';
import '../../shared/widgets/animated_check.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/misc_widgets.dart';
import '../../shared/widgets/progress_ring.dart';
import 'habit_create_edit.dart';
import 'widgets/habit_heatmap.dart';

class HabitDetailScreen extends StatelessWidget {
  final String habitId;
  const HabitDetailScreen({super.key, required this.habitId});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final habit = state.habits.firstWhere((h) => h.id == habitId);
    final currentStreak = AppDate.currentStreak(habit.completedDates);
    final bestStreak = AppDate.bestStreak(habit.completedDates);
    final isDoneToday = state.isHabitDoneToday(habit);
    final color = habit.color;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => HabitEditorScreen(existing: habit)),
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.error),
            onPressed: () => _confirmDelete(context, habit),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          20,
          16,
          20,
          40,
        ),
        children: [
              // Hero Header Section
              _HeroHeader(
                habit: habit,
                isDoneToday: isDoneToday,
                currentStreak: currentStreak,
                color: color,
              ),

              // Motivation Quote Banner
              if (habit.motivation != null && habit.motivation!.trim().isNotEmpty) ...[
                const SizedBox(height: 24),
                _MotivationQuoteCard(
                  motivation: habit.motivation!,
                  color: color,
                ),
              ],

              const SizedBox(height: 24),

              // Goal or Ongoing Habit Target Card
              if (habit.hasGoal)
                _GoalCard(habit: habit)
              else
                _OngoingCard(color: color),

              const SizedBox(height: 20),

              // Key Performance Stats Grid
              Row(
                children: [
                  Expanded(
                    child: _StatBox(
                      value: '$currentStreak',
                      label: 'Current streak',
                      icon: Icons.local_fire_department_rounded,
                      color: color,
                      isHighlighted: currentStreak > 0,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatBox(
                      value: '$bestStreak',
                      label: 'Best streak',
                      icon: Icons.emoji_events_rounded,
                      color: const Color(0xFFFFB800),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatBox(
                      value: '${(habit.consistencyRate * 100).round()}%',
                      label: 'Consistency',
                      icon: Icons.bolt_rounded,
                      color: const Color(0xFF00E676),
                    ),
                  ),
                ],
              ),

              // Notes Section
              if (habit.notes != null && habit.notes!.trim().isNotEmpty) ...[
                const SizedBox(height: 24),
                const SectionHeader(title: 'Notes'),
                const SizedBox(height: 10),
                AppCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.notes_rounded, size: 20, color: color.withOpacity(0.8)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          habit.notes!,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: context.colors.textPrimary,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Reminders Section
              const SizedBox(height: 24),
              const SectionHeader(title: 'Reminders'),
              const SizedBox(height: 10),
              AppCard(
                child: Column(
                  children: [
                    _ReminderRow(
                      icon: Icons.notifications_active_rounded,
                      title: 'Daily Reminder',
                      subtitle: habit.reminderTime == null
                          ? 'Not configured'
                          : 'Scheduled for ${habit.reminderTime}',
                      badgeText: habit.reminderTime,
                      active: habit.reminderTime != null,
                      color: color,
                    ),
                    Divider(height: 24, thickness: 1, color: context.colors.border.withOpacity(0.5)),
                    _ReminderRow(
                      icon: Icons.shield_moon_rounded,
                      title: 'Evening Nudge',
                      subtitle: habit.missedReminderEnabled
                          ? 'Gentle reminder if you miss your habit'
                          : 'Missed-day nudge disabled',
                      badgeText: habit.missedReminderEnabled ? 'Active' : 'Off',
                      active: habit.missedReminderEnabled,
                      color: color,
                    ),
                  ],
                ),
              ),

              // Heatmap / Activity Section
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Daily Activity Grid', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(
                        '${habit.completedDates.length} check-ins • 84-day window',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.colors.textSecondary, fontSize: 11.5),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (habit.currentStreak > 0)
                        Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '🔥 ${habit.currentStreak}d streak',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.secondary),
                          ),
                        ),
                      if (habit.missedDaysCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.error.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, size: 13, color: AppColors.error),
                              const SizedBox(width: 4),
                              Text(
                                '${habit.missedDaysCount} missed',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppCard(
                child: Column(
                  children: [
                    HabitHeatmap(completedDates: habit.completedDates, color: color),
                    const SizedBox(height: 14),
                    // Legend
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('Less', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10, color: context.colors.textSecondary)),
                        const SizedBox(width: 6),
                        ...List.generate(4, (i) {
                          return Container(
                            width: 10,
                            height: 10,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: i == 0
                                  ? context.colors.border.withOpacity(0.3)
                                  : color.withOpacity(0.25 * (i + 1)),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        }),
                        const SizedBox(width: 6),
                        Text('More', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10, color: context.colors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
  }

  Future<void> _confirmDelete(BuildContext context, Habit habit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 22),
            ),
            const SizedBox(width: 12),
            const Text('Delete habit?'),
          ],
        ),
        content: Text(
          '"${habit.title}" and its history will be permanently removed.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: context.colors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<AppState>().deleteHabit(habit.id);
      if (context.mounted) Navigator.of(context).pop();
    }
  }
}

class _HeroHeader extends StatelessWidget {
  final Habit habit;
  final bool isDoneToday;
  final int currentStreak;
  final Color color;

  const _HeroHeader({
    required this.habit,
    required this.isDoneToday,
    required this.currentStreak,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon Badge with ambient glow
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color.withOpacity(0.14),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withOpacity(0.3), width: 1.5),
              ),
              child: Icon(habit.icon, color: color, size: 30),
            ),
            const SizedBox(width: 16),

            // Title & Status Tag
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDoneToday
                          ? const Color(0xFF00E676).withOpacity(0.12)
                          : color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDoneToday
                            ? const Color(0xFF00E676).withOpacity(0.3)
                            : color.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isDoneToday
                              ? Icons.check_circle_rounded
                              : Icons.local_fire_department_rounded,
                          size: 13,
                          color: isDoneToday ? const Color(0xFF00E676) : color,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isDoneToday
                              ? 'Done Today ✨'
                              : '$currentStreak Day Streak',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDoneToday ? const Color(0xFF00E676) : color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Interactive Animated Check Button
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                /*boxShadow: isDoneToday
                    ? [
                  BoxShadow(
                    color: color.withOpacity(0.35),
                    blurRadius: 18,
                    spreadRadius: 2,
                  )
                ]
                    : null,*/
              ),
              child: AnimatedCheck(
                checked: isDoneToday,
                onTap: () => context.read<AppState>().toggleHabitToday(habit.id),
                color: color,
                size: 42,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MotivationQuoteCard extends StatelessWidget {
  final String motivation;
  final Color color;

  const _MotivationQuoteCard({required this.motivation, required this.color});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color,
          color.withOpacity(0.85),
          HSLColor.fromColor(color).withHue((HSLColor.fromColor(color).hue + 15) % 360).toColor(),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -15,
            child: Icon(
              Icons.format_quote_rounded,
              color: Colors.white.withOpacity(0.15),
              size: 90,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 3.5,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  '"$motivation"',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                    height: 1.45,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final Habit habit;
  const _GoalCard({required this.habit});

  @override
  Widget build(BuildContext context) {
    final color = habit.color;
    final progress = habit.goalProgress ?? 0.0;
    final reached = habit.goalReached;
    final remaining = habit.daysRemainingInGoal;
    final goalDays = habit.goalDays;
    final done = habit.completedDates.length;

    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                child: ProgressRing(
                  progress: progress,
                  size: 72,
                  strokeWidth: 8,
                  gradientColors: [color, color.withOpacity(0.5)],
                  center: reached
                      ? Icon(Icons.emoji_events_rounded, color: color, size: 28)
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$done',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          color: color,
                          height: 1.0,
                        ),
                      ),
                      Text(
                        '/$goalDays d',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          reached ? 'Habit Formed! 🎉' : 'Goal Progress',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${(progress * 100).round()}%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      reached
                          ? 'Outstanding! You reached your $goalDays-day goal — keep going to solidify it.'
                          : '$remaining day${remaining == 1 ? '' : 's'} remaining to achieve your $goalDays-day target.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.colors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: color.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _OngoingCard extends StatelessWidget {
  final Color color;
  const _OngoingCard({required this.color});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.all_inclusive_rounded, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ongoing Habit',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  'No deadline set. You can set a target duration anytime in edit mode.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.colors.textSecondary,
                    height: 1.3,
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

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final bool isHighlighted;

  const _StatBox({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 11,
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? badgeText;
  final bool active;
  final Color color;

  const _ReminderRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.badgeText,
    required this.active,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: active ? color.withOpacity(0.12) : context.colors.border.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: active ? color : context.colors.textSecondary,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (badgeText != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: active ? color.withOpacity(0.1) : context.colors.border.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: active ? color.withOpacity(0.3) : Colors.transparent,
              ),
            ),
            child: Text(
              badgeText!,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: active ? color : context.colors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }
}

/// Enhanced AppCard Widget with smooth interaction feedback & subtle border
