import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';

class AppBottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;

  const AppBottomNav({super.key, required this.index, required this.onChanged});

  static final _items = [
    (icon: Icons.today_rounded, label: 'Today'),
    (icon: Icons.checklist_rounded, label: 'Routines'),
    (icon: Icons.repeat_rounded, label: 'Habits'),
    (icon: Icons.timer_rounded, label: 'Focus'),
    (icon: Icons.insights_rounded, label: 'Progress'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: context.colors.border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(context.colors.isDark ? 0.35 : 0.08),
            blurRadius: 18,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (i) {
          final selected = i == index;
          final item = _items[i];
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: AppDuration.base,
                curve: Curves.easeOut,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary.withOpacity(0.14) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.icon,
                      size: 21,
                      color: selected ? AppColors.primary : context.colors.textSecondary,
                    ),
                    const SizedBox(height: 3),
                    AnimatedDefaultTextStyle(
                      duration: AppDuration.base,
                      style: AppTypography.metric.copyWith(
                        fontSize: 10,
                        fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                        color: selected ? AppColors.primary : context.colors.textSecondary,
                      ),
                      child: Text(item.label),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
