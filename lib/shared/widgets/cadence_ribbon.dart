import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/date_utils.dart';

/// The Cadence Ribbon (§8 Design PRD):
/// A horizontal woven ribbon representing past N days as vertical threads.
/// Chronological flow from Left to Right (Oldest day on Left -> Today on Right).
/// A kept day is a lit primary thread with ambient glow.
/// A missed day is a dim border gap.
class CadenceRibbon extends StatelessWidget {
  final Set<String> completedDates;
  final int daysCount;
  final bool compact;
  final double height;

  const CadenceRibbon({
    super.key,
    required this.completedDates,
    this.daysCount = 14,
    this.compact = false,
    this.height = 36,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // Chronological order: i = 0 is daysCount - 1 days ago (oldest, far left), i = daysCount - 1 is Today (far right)
    final days = List.generate(daysCount, (i) {
      final d = now.subtract(Duration(days: daysCount - 1 - i));
      final key = AppDate.key(d);
      final isCompleted = completedDates.contains(key);
      final isToday = i == daysCount - 1;
      return _RibbonThreadData(date: d, key: key, isCompleted: isCompleted, isToday: isToday);
    });

    final primaryColor = AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: days.map((day) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: _RibbonThread(data: day, height: height, primaryColor: primaryColor),
                ),
              );
            }).toList(),
          ),
        ),
        if (!compact) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${daysCount}d ago',
                style: AppTypography.metric.copyWith(fontSize: 10, color: context.colors.textSecondary),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Today',
                    style: AppTypography.metric.copyWith(fontSize: 10, color: primaryColor, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _RibbonThreadData {
  final DateTime date;
  final String key;
  final bool isCompleted;
  final bool isToday;

  _RibbonThreadData({
    required this.date,
    required this.key,
    required this.isCompleted,
    required this.isToday,
  });
}

class _RibbonThread extends StatelessWidget {
  final _RibbonThreadData data;
  final double height;
  final Color primaryColor;

  const _RibbonThread({
    required this.data,
    required this.height,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color threadColor = data.isCompleted
        ? primaryColor
        : context.colors.border.withOpacity(0.5);

    final dateLabel = AppDate.monthDay(data.date);
    final statusStr = data.isCompleted ? 'Completed' : 'Missed';

    return Tooltip(
      message: '${data.isToday ? "Today ($dateLabel)" : dateLabel}: $statusStr',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: height,
        decoration: BoxDecoration(
          color: threadColor,
          borderRadius: BorderRadius.circular(6),
          boxShadow: data.isCompleted
              ? [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.4),
                    blurRadius: 6,
                    spreadRadius: 0.5,
                  ),
                ]
              : null,
          border: data.isToday
              ? Border.all(
                  color: primaryColor,
                  width: data.isCompleted ? 1.8 : 1.2,
                )
              : null,
        ),
      ),
    );
  }
}
