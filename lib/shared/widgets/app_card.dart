import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_tokens.dart';

/// Standard elevated card used across the app. Wraps its child with the
/// brand's soft-shadow + rounded-corner language and an optional tap
/// animation (press-scale) so every tappable card feels alive.
class AppCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Gradient? gradient;
  final bool showShadow;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = AppSpacing.cardPadding,
    this.color,
    this.gradient,
    this.showShadow = true,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDuration.fast,
    lowerBound: 0,
    upperBound: 0.03,
  );
  late final Animation<double> _scale = Tween(begin: 1.0, end: 0.97).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final border = context.colors.border;
    final card = AnimatedBuilder(
      animation: _scale,
      builder: (context, child) => Transform.scale(scale: _scale.value, child: child),
      child: Container(
        alignment: Alignment.center,
        padding: widget.padding,
        decoration: BoxDecoration(
          color: widget.gradient == null ? (widget.color ?? context.colors.card) : null,
          gradient: widget.gradient,
          borderRadius: AppRadius.cardBorder,
          border: widget.gradient == null
              ? Border.all(color: border.withOpacity(0.7), width: 1.0)
              : Border.all(color: Colors.white.withOpacity(0.15), width: 1.0),
          boxShadow: widget.showShadow ? AppShadows.card(context) : [],
        ),
        child: widget.child,
      ),
    );

    if (widget.onTap == null) return card;
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: card,
    );
  }
}