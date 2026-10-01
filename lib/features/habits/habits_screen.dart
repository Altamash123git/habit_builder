import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/misc_widgets.dart';
import 'habit_create_edit.dart';
import 'habit_detail_screen.dart';
import 'widgets/habit_card.dart';

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  void _openEditor(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HabitEditorScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final habits = state.habits;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 75),
        child: FloatingActionButton(
          heroTag: null,
          backgroundColor: AppColors.primary,
          elevation: 4,
          onPressed: () => _openEditor(context),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Habits',
                    style: AppTypography.displayMedium.copyWith(
                      color: context.colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
                children: [
                  if (habits.isEmpty)
                    EmptyState(
                      icon: Icons.local_fire_department_rounded,
                      title: 'Build your first habit',
                      subtitle: 'Small daily actions compound. Add a habit, set a goal, and start your streak today.',
                      actionLabel: 'New habit',
                      onAction: () => _openEditor(context),
                    )
                  else
                    for (final h in habits)
                      HabitCard(habit: h, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => HabitDetailScreen(habitId: h.id)))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
