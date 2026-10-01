import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/app_card.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Habit Tracker'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // App Header Card
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: AppGradients.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset("assets/images/applogo.png")
                  
                  //const Icon(Icons.check_circle_rounded, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 14),
                Text('Habit Tracker', style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: 4),
                Text(
                  'Routine Planner & Habit Tracker',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.colors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Purpose Section
          AppCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.auto_awesome_rounded, color: AppColors.secondary, size: 20),
                    SizedBox(width: 10),
                    Text('Our Philosophy', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Habit Tracker is designed to cultivate calm, intentional, and consistent daily rhythms. We believe consistency should feel rewarding, distraction-free, and delightful.',
                  style: TextStyle(fontSize: 13, height: 1.45, color: context.colors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Features List Card
          AppCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Core Features', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                const _FeatureItem(icon: Icons.checklist_rounded, title: 'Structured Routines', desc: 'Step-by-step morning, work, and evening flow checklists.'),
                const SizedBox(height: 10),
                const _FeatureItem(icon: Icons.local_fire_department_rounded, title: 'Habit Streaks', desc: 'Daily check-ins with visual heatmaps and streak counters.'),
                const SizedBox(height: 10),
                const _FeatureItem(icon: Icons.timer_rounded, title: 'Deep Focus Pomodoro', desc: 'Customizable focus & break timers with session history.'),
                const SizedBox(height: 10),
                const _FeatureItem(icon: Icons.shield_rounded, title: '100% Private', desc: 'Your data stays strictly on your device with zero tracking.'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Center(
            child: Text(
              'Crafted with ❤️ for consistent productivity',
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: context.colors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 2),
              Text(desc, style: TextStyle(fontSize: 11.5, color: context.colors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}
