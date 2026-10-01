import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/misc_widgets.dart';
import '../routines/routine_detail_screen.dart';
import 'widgets/habit_quick_row.dart';
import 'widgets/routine_progress_card.dart';
import 'widgets/today_header.dart';
import 'widgets/today_hero_card.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final routines = state.todaysRoutines;
    final habits = state.habits;
    final totalTasks = routines.fold<int>(0, (s, r) => s + r.tasks.length);
    final doneTasks = routines.fold<int>(0, (s, r) => s + r.completedCount);
    final doneHabits = habits.where(state.isHabitDoneToday).length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Pinned top header — stays below status bar cleanly
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: TodayHeader(name: state.userName, streak: state.currentOverallStreak),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
                children: [
                  TodayHeroCard(doneTasks: doneTasks, totalTasks: totalTasks, doneHabits: doneHabits, totalHabits: habits.length),
                  const SizedBox(height: 24),
                  SectionHeader(title: "Today's routines"),
                  if (routines.isEmpty)
                    const _InlineEmpty(text: 'No routines scheduled for today. Head to the Routines tab to add one.')
                  else
                    for (final r in routines)
                      RoutineProgressCard(routine: r, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => RoutineDetailScreen(routineId: r.id)))),
                  const SizedBox(height: 20),
                  SectionHeader(title: 'Habits'),
                  if (habits.isEmpty)
                    const _InlineEmpty(text: 'No habits yet. Add your first one from the Habits tab.')
                  else
                    for (final h in habits) HabitQuickRow(habit: h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineEmpty extends StatelessWidget {
  final String text;
  const _InlineEmpty({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(text, style: TextStyle(color: context.colors.textSecondary, fontSize: 13)),
    );
  }
}
