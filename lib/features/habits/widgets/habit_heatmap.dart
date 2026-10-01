import 'package:flutter/material.dart';
import '../../../shared/widgets/tempo_grid.dart';

/// The Tempo Grid (§8 Design PRD):
/// Habit heatmap restyled as a music/loom grid in marigold ink density.
class HabitHeatmap extends StatelessWidget {
  final Set<String> completedDates;
  final Color color;
  final int weeks;

  const HabitHeatmap({
    super.key,
    required this.completedDates,
    required this.color,
    this.weeks = 12,
  });

  @override
  Widget build(BuildContext context) {
    return TempoGrid(
      completedDates: completedDates,
      weeks: weeks,
    );
  }
}
