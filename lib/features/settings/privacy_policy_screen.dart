import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_card.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Header Hero Card
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.14),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.shield_outlined, color: AppColors.success, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Data Belongs To You',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'private, and local to your device.',
                        style: TextStyle(fontSize: 12.5, color: context.colors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const _PolicySection(
            icon: Icons.storage_rounded,
            title: '1. On-Device Local Storage',
            description:
                'Habit Tracker stores all your routines, habits, focus logs, and preferences strictly on your local device storage. No external servers or cloud databases receive your daily progress data.',
          ),
          const SizedBox(height: 14),

          const _PolicySection(
            icon: Icons.no_accounts_rounded,
            title: '2. Zero Tracking & No Accounts',
            description:
                'We do not collect personal identify information, email addresses, or usage telemetry. You do not need to register an account or sign in to use Habit Tracker.',
          ),
          const SizedBox(height: 14),

          const _PolicySection(
            icon: Icons.notifications_active_rounded,
            title: '3. Local Notifications',
            description:
                'Reminders and focus alerts are scheduled using system-level local notification services on your device. They operate entirely offline without network calls.',
          ),
          const SizedBox(height: 14),

          const _PolicySection(
            icon: Icons.download_for_offline_rounded,
            title: '4. Full Data Export & Ownership',
            description:
                'You retain complete ownership of your productivity records. You can export your data to formatted JSON at any time from the Settings menu.',
          ),
          const SizedBox(height: 24),

          Center(
            child: Text(
              'Last updated: August 2026 • Habit Tracker Team',
              style: TextStyle(fontSize: 11, color: context.colors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _PolicySection({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
