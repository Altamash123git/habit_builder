import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../onboarding/onboarding_screen.dart';
import '../shell/root_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    Timer(const Duration(milliseconds: 2400), _navigateToNextScreen);
  }

  void _navigateToNextScreen() {
    if (!mounted) return;
    final onboarded = context.read<AppState>().onboarded;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, __, ___) => onboarded ? const RootShell() : const OnboardingScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.bg,
      body: Stack(
        children: [
          Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.colors.card,
                        border: Border.all(color: context.colors.border),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.marigold500.withOpacity(0.25),
                            blurRadius: 28,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Image.asset(
                        'assets/images/applogo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.marigold500,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            size: 54,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Habit Tracker',
                      textAlign: TextAlign.center,
                      style: AppTypography.displayLarge.copyWith(
                        fontSize: 34,
                        fontWeight: FontWeight.w600,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Calm, Intentional Daily Rhythms',
                      style: AppTypography.bodyMedium.copyWith(
                        color: context.colors.textSecondary,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 48,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  SizedBox(
                    width: 36,
                    height: 3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: const LinearProgressIndicator(
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.marigold500),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
