import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_tokens.dart';

/// Satisfying check circle button — fills with brand primary/accent color
/// and shows a clean, intuitive checkmark when checked.
class AnimatedCheck extends StatelessWidget {
  final bool checked;
  final VoidCallback onTap;
  final double size;
  final Color color;

  const AnimatedCheck({
    super.key,
    required this.checked,
    required this.onTap,
    this.size = 28,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppDuration.glow,
        curve: Curves.easeOutCubic,
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: checked ? activeColor : context.colors.card,
          border: Border.all(
            color: checked ? activeColor : context.colors.border,
            width: checked ? 2 : 1.8,
          ),
          boxShadow: checked
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.35),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: AnimatedSwitcher(
          duration: AppDuration.fast,
          transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
          child: checked
              ? Icon(Icons.check_rounded, key: const ValueKey('checked'), size: size * 0.6, color: Colors.white)
              : const SizedBox.shrink(key: ValueKey('unchecked')),
        ),
      ),
    );
  }
}
