import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/focus_session.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/date_utils.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/cadence_ribbon.dart';
import '../../shared/widgets/misc_widgets.dart';
import '../../shared/widgets/tempo_grid.dart';
import 'widgets/stat_card.dart';
import 'widgets/weekly_bar_chart.dart';

import '../../core/theme/app_theme.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final days = AppDate.lastDays(7);
    final weekValues = days.map((d) => state.completionRateOn(d)).toList();

    final allCompletedDates = state.habits.fold<Set<String>>({}, (set, h) => set..addAll(h.completedDates));
    final unlocked = kAchievements.where((a) => a.isUnlocked(state.bestOverallStreak, state.totalCompletions, state.totalFocusMinutes)).toList();
    final locked = kAchievements.where((a) => !unlocked.contains(a)).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Progress',
                  style: AppTypography.displayMedium.copyWith(
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
                children: [
                  // Cadence Ribbon (28 days)
          SectionHeader(title: 'Cadence Ribbon'),
          AppCard(
            child: CadenceRibbon(
              completedDates: allCompletedDates,
              daysCount: 28,
              compact: false,
              height: 28,
            ),
          ),
          const SizedBox(height: 22),

          // Stat Cards Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              StatCard(icon: Icons.local_fire_department_rounded, color: AppColors.marigold500, value: '${state.currentOverallStreak}', label: 'Current streak'),
              StatCard(icon: Icons.emoji_events_rounded, color: AppColors.marigold300, value: '${state.bestOverallStreak}', label: 'Best streak'),
              StatCard(icon: Icons.timer_rounded, color: AppColors.verdigris500, value: '${state.totalFocusMinutes}m', label: 'Focus time'),
              StatCard(icon: Icons.check_circle_outline_rounded, color: AppColors.verdigris300, value: '${state.totalCompletions}', label: 'Completions'),
            ],
          ),
          const SizedBox(height: 24),

          // Tempo Grid Heatmap
          AppCard(
            child: TempoGrid(completedDates: allCompletedDates, weeks: 12),
          ),
          const SizedBox(height: 24),

          SectionHeader(title: 'This week'),
          AppCard(
            child: WeeklyBarChart(values: weekValues),
          ),
          const SizedBox(height: 24),

          SectionHeader(title: 'Achievements'),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final a in unlocked) _AchievementChip(achievement: a, unlocked: true),
              for (final a in locked) _AchievementChip(achievement: a, unlocked: false),
            ],
          ),
        ],
      ),
    ),
  ],
),
),
);
  }
}

class _AchievementChip extends StatelessWidget {
  final Achievement achievement;
  final bool unlocked;
  const _AchievementChip({required this.achievement, required this.unlocked});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: unlocked ? 1 : 0.45,
      child: Container(
        width: 104,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: unlocked ? AppColors.marigold500 : context.colors.border,
            width: unlocked ? 1.4 : 1.0,
          ),
          boxShadow: unlocked
              ? [
                  BoxShadow(
                    color: AppColors.marigold500.withOpacity(0.2),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Text(achievement.icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(
              achievement.title,
              textAlign: TextAlign.center,
              style: AppTypography.labelMedium.copyWith(
                fontSize: 11.5,
                color: unlocked ? AppColors.marigold500 : context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
