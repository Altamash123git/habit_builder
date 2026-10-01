import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/routine.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/progress_ring.dart';
import 'routine_editor_screen.dart';
import 'widgets/task_tile.dart';


class RoutineDetailScreen extends StatelessWidget {
  final String routineId;
  const RoutineDetailScreen({super.key, required this.routineId});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final routine = state.routines.firstWhere((r) => r.id == routineId);
    final color = routine.category.color;
    final categoryLabel = routine.category.label;

    final totalTasks = routine.tasks.length;
    final completedTasks = (routine.progress * totalTasks).round();
    final remainingTasks = totalTasks - completedTasks;
    final percentage = (routine.progress * 100).round();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Routine Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => RoutineEditorScreen(existing: routine)),
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.error),
            onPressed: () => _confirmDelete(context, routine.id, routine.title),
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
                title: routine.title,
                categoryLabel: categoryLabel,
                progress: routine.progress,
                percentage: percentage,
                completedTasks: completedTasks,
                totalTasks: totalTasks,
                color: color,
              ),

              const SizedBox(height: 24),

              // Routine Quick Stats Row
              _RoutineStatsRow(
                totalTasks: totalTasks,
                completedTasks: completedTasks,
                remainingTasks: remainingTasks,
                color: color,
              ),

              // Routine Complete Today Banner
              if (routine.isDoneToday) ...[
                const SizedBox(height: 20),
                _CompletionBanner(color: color),
              ],

              const SizedBox(height: 28),

              // Checklist Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Checklist',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color.withOpacity(0.25)),
                    ),
                    child: Text(
                      '$completedTasks/$totalTasks Done',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Tasks Checklist
              for (final task in routine.tasks) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TaskTile(
                    task: task,
                    accent: color,
                    onToggle: () => context.read<AppState>().toggleRoutineTask(routine.id, task.id),
                  ),
                ),
              ],
            ],
          ),
        );
  }

  Future<void> _confirmDelete(BuildContext context, String routineId, String title) async {
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
            const Text('Delete routine?'),
          ],
        ),
        content: Text(
          '"$title" and its tasks will be permanently removed.',
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
      await context.read<AppState>().deleteRoutine(routineId);
      if (context.mounted) Navigator.of(context).pop();
    }
  }
}

class _HeroHeader extends StatelessWidget {
  final String title;
  final String categoryLabel;
  final double progress;
  final int percentage;
  final int completedTasks;
  final int totalTasks;
  final Color color;

  const _HeroHeader({
    required this.title,
    required this.categoryLabel,
    required this.progress,
    required this.percentage,
    required this.completedTasks,
    required this.totalTasks,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Pill Tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withOpacity(0.25)),
                ),
                child: Text(
                  categoryLabel.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Routine Title
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 8),
              // Subtitle Progress Status
              Text(
                completedTasks == totalTasks
                    ? 'All $totalTasks tasks completed today ✨'
                    : '$completedTasks of $totalTasks tasks completed',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.colors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Progress Ring Container
        Container(
          padding: const EdgeInsets.all(4),
          child: ProgressRing(
            progress: progress,
            size: 72,
            strokeWidth: 8,
            color: color,
            center: Text(
              '$percentage%',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 14,
                color: color,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RoutineStatsRow extends StatelessWidget {
  final int totalTasks;
  final int completedTasks;
  final int remainingTasks;
  final Color color;

  const _RoutineStatsRow({
    required this.totalTasks,
    required this.completedTasks,
    required this.remainingTasks,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatMiniCard(
            value: '$totalTasks',
            label: 'Total Tasks',
            icon: Icons.format_list_bulleted_rounded,
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatMiniCard(
            value: '$completedTasks',
            label: 'Completed',
            icon: Icons.task_alt_rounded,
            color: const Color(0xFF00E676),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatMiniCard(
            value: '$remainingTasks',
            label: 'Remaining',
            icon: Icons.pending_actions_rounded,
            color: remainingTasks > 0 ? color : context.colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _StatMiniCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatMiniCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 10.5,
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletionBanner extends StatelessWidget {
  final Color color;
  const _CompletionBanner({required this.color});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color.withOpacity(0.95),
          color,
          HSLColor.fromColor(color).withHue((HSLColor.fromColor(color).hue + 20) % 360).toColor(),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.celebration_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:  [
                Text(
                  'Routine Complete! 🎉',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Routine complete for today. Great consistency!',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12.5,
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