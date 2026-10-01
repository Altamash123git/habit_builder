import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// A calm, animated circular progress ring with a single solid stroke color.
/// Used for "today's completion", routine progress, and habit rate.
class ProgressRing extends StatelessWidget {
  final double progress; // 0..1
  final double size;
  final double strokeWidth;
  final Widget? center;
  final List<Color>? gradientColors;
  final Color? color;

  const ProgressRing({
    super.key,
    required this.progress,
    this.size = 84,
    this.strokeWidth = 9,
    this.center,
    this.gradientColors,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ??
        (progress >= 1.0
            ? AppColors.marigold500
            : (gradientColors != null && gradientColors!.isNotEmpty
                ? gradientColors!.first
                : AppColors.verdigris500));

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress.clamp(0, 1)),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _RingPainter(
            progress: value,
            strokeWidth: strokeWidth,
            trackColor: context.colors.border,
            solidColor: effectiveColor,
          ),
          child: center == null ? null : Center(child: center),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color trackColor;
  final Color solidColor;

  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.trackColor,
    required this.solidColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, track);

    if (progress <= 0) return;

    final rect = Rect.fromCircle(center: center, radius: radius);
    final sweep = Paint()
      ..color = solidColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * progress, false, sweep);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.solidColor != solidColor;
}
