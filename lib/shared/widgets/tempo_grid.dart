import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/date_utils.dart';

/// The Tempo Grid (§8 Design PRD):
/// The habit heatmap restyled as a music/loom grid, using marigold ink density
/// instead of standard green squares.
class TempoGrid extends StatelessWidget {
  final Set<String> completedDates;
  final int weeks;

  const TempoGrid({
    super.key,
    required this.completedDates,
    this.weeks = 12,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // Total days: weeks * 7
    final totalDays = weeks * 7;
    // Align starting date to Monday
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startDate = startOfWeek.subtract(Duration(days: (weeks - 1) * 7));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Tempo Grid', style: AppTypography.titleMedium.copyWith(color: AppColors.linen100)),
            Text(
              '${completedDates.length} check-ins',
              style: AppTypography.metric.copyWith(fontSize: 12, color: AppColors.marigold500),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(weeks, (weekIdx) {
              return Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: Column(
                  children: List.generate(7, (dayIdx) {
                    final dayDate = startDate.add(Duration(days: weekIdx * 7 + dayIdx));
                    final key = AppDate.key(dayDate);
                    final isCompleted = completedDates.contains(key);
                    final isFuture = dayDate.isAfter(now);

                    Color cellColor;
                    if (isFuture) {
                      cellColor = Colors.transparent;
                    } else if (isCompleted) {
                      cellColor = AppColors.marigold500;
                    } else {
                      cellColor = context.colors.card;
                    }

                    return Container(
                      width: 16,
                      height: 16,
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: BoxDecoration(
                        color: cellColor,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: isCompleted
                            ? [
                                BoxShadow(
                                  color: AppColors.marigold500.withOpacity(0.35),
                                  blurRadius: 4,
                                  spreadRadius: 0.5,
                                ),
                              ]
                            : null,
                        border: Border.all(
                          color: isCompleted
                              ? AppColors.marigold300
                              : (isFuture ? context.colors.border.withOpacity(0.3) : context.colors.border),
                          width: 0.8,
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
