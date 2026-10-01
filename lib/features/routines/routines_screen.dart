import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/misc_widgets.dart';
import 'routine_detail_screen.dart';
import 'routine_editor_screen.dart';
import 'widgets/routine_card.dart';

class RoutinesScreen extends StatelessWidget {
  const RoutinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final routines = state.routines;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 75),
        child: FloatingActionButton(
          backgroundColor: AppColors.primary,
          elevation: 4,
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RoutineEditorScreen())),
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
                    'Routines',
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
                  if (routines.isEmpty)
                    EmptyState(
                      icon: Icons.checklist_rounded,
                      title: 'Start your first routine',
                      subtitle: 'Pick a template or build your own morning, work, or self-care routine in seconds.',
                      actionLabel: 'New routine',
                      onAction: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RoutineEditorScreen())),
                    )
                  else
                    for (final r in routines)
                      RoutineCard(routine: r, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => RoutineDetailScreen(routineId: r.id)))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
