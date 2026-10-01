import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

import '../../../core/theme/app_theme.dart';

class TimerDial extends StatelessWidget {
  final double progress; // 0..1 remaining
  final String timeLabel;
  final String modeLabel;
  final Color color;
  final bool running;

  const TimerDial({
    super.key,
    required this.progress,
    required this.timeLabel,
    required this.modeLabel,
    required this.color,
    required this.running,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(280, 280),
            painter: _DialPainter(
              progress: progress,
              trackColor: context.colors.border,
              color: color,
              running: running,
            ),
          ),
          AnimatedScale(
            scale: running ? 1.0 : 0.96,
            duration: const Duration(milliseconds: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  modeLabel.toUpperCase(),
                  style: AppTypography.metric.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  timeLabel,
                  style: AppTypography.metricXL.copyWith(
                    fontSize: 48,
                    color: context.colors.textPrimary,
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

class _DialPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color color;
  final bool running;

  _DialPainter({
    required this.progress,
    required this.trackColor,
    required this.color,
    required this.running,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, track);

    if (progress <= 0) return;

    if (running) {
      final glowPaint = Paint()
        ..color = AppColors.marigold500.withOpacity(0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi / 2, 2 * math.pi * progress, false, glowPaint);
    }

    final arc = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi / 2, 2 * math.pi * progress, false, arc);
  }

  @override
  bool shouldRepaint(covariant _DialPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color || oldDelegate.running != running;
}
