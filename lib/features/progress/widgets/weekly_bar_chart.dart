import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/date_utils.dart';

/// Last-7-days completion-rate bar chart. Kept dependency-free
/// with plain animated bars for reliability across Flutter SDKs.
class WeeklyBarChart extends StatelessWidget {
  final List<double> values; // 0..1, oldest first, length 7
  const WeeklyBarChart({super.key, required this.values});

  @override
  Widget build(BuildContext context) {
    final days = AppDate.lastDays(7);
    return SizedBox(
      height: 150,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (i) {
          final v = values[i].clamp(0.0, 1.0);
          final isToday = i == 6;
          final isComplete = v >= 1.0;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: v),
                        duration: Duration(milliseconds: 500 + i * 60),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, _) => FractionallySizedBox(
                          heightFactor: value == 0 ? 0.04 : value,
                          child: Container(
                            decoration: BoxDecoration(
                              color: isComplete || isToday
                                  ? AppColors.marigold500
                                  : AppColors.verdigris500.withOpacity(0.55),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                              boxShadow: isComplete || isToday
                                  ? [
                                      BoxShadow(
                                        color: AppColors.marigold500.withOpacity(0.3),
                                        blurRadius: 6,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppDate.weekdayShort(days[i]).substring(0, 1),
                    style: AppTypography.metric.copyWith(
                      fontSize: 11,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: isToday ? AppColors.marigold500 : context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
