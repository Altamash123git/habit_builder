import 'package:flutter/material.dart';
import '../../../core/models/routine.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/animated_check.dart';
import '../../../shared/widgets/app_card.dart';

class TaskTile extends StatelessWidget {
  final RoutineTask task;
  final Color accent;
  final VoidCallback onToggle;

  const TaskTile({super.key, required this.task, required this.accent, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        showShadow: false,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            AnimatedCheck(checked: task.completedToday, onTap: onToggle, color: accent),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: context.colors.textPrimary,
                          decoration: task.completedToday ? TextDecoration.lineThrough : null,
                        ),
                  ),
                  if (task.time != null) ...[
                    const SizedBox(height: 3),
                    Text(task.time!, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
