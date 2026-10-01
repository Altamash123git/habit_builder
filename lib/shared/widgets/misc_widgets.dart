import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_theme.dart';

/// Full-width primary CTA button with high-contrast text and smooth scale response.
class GradientButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final Gradient gradient;

  const GradientButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.gradient = AppGradients.primary,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) => setState(() => _scale = 1),
      onTapCancel: () => setState(() => _scale = 1),
      child: AnimatedScale(
        scale: _scale,
        duration: AppDuration.fast,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppRadius.button),
            boxShadow: AppShadows.glow(AppColors.primary, opacity: 0.3),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: AppTypography.labelLarge.copyWith(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Section title + optional trailing action, used at the top of list groups.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionHeader({super.key, required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTypography.titleLarge.copyWith(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                action!,
                style: AppTypography.metric.copyWith(
                  fontSize: 12.5,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Warm empty state with clear CTA action.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: context.colors.card,
              shape: BoxShape.circle,
              border: Border.all(color: context.colors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.1),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Icon(icon, color: AppColors.primary, size: 30),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTypography.headlineMedium.copyWith(color: context.colors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              subtitle,
              style: AppTypography.bodyMedium.copyWith(color: context.colors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: 200,
              child: GradientButton(label: actionLabel!, onTap: onAction ?? () {}),
            ),
          ],
        ],
      ),
    );
  }
}

/// Small "Premium" pill badge.
class PremiumBadge extends StatelessWidget {
  const PremiumBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.workspace_premium_rounded, size: 12, color: Colors.white),
          SizedBox(width: 3),
          Text(
            'PREMIUM',
            style: TextStyle(
              color: Colors.white,
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
