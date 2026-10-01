import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/misc_widgets.dart';
import 'about_screen.dart';
import 'privacy_policy_screen.dart';
import 'widgets/premium_sheet.dart';
import 'widgets/theme_selector.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const String _appPackageName = 'com.example.cadence';
  static const String _supportEmail = 'onlineshoppingappinfo@gmail.com';
  static const String _feedbackEmail = 'onlineshoppingappinfo@gmail.com';

  Future<void> _safeShare(BuildContext context, String text, {String? subject}) async {
    try {
      await Share.share(text, subject: subject);
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: text));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Content copied to clipboard! (Rebuild app to enable native share sheet) 📋'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _launchUrlUri(BuildContext context, Uri uri, {String? fallbackMessage}) async {
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        await Clipboard.setData(ClipboardData(text: uri.toString()));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(fallbackMessage ?? 'Link copied to clipboard!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        await Clipboard.setData(ClipboardData(text: uri.toString()));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(fallbackMessage ?? 'Link copied to clipboard!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _launchEmail(BuildContext context, {required String email, required String subject, String body = ''}) async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': subject,
        if (body.isNotEmpty) 'body': body,
      },
    );
    await _launchUrlUri(context, uri, fallbackMessage: 'Email app not found. Address $email copied to clipboard.');
  }

  Future<void> _launchPlayStore(BuildContext context) async {
    final Uri storeUri = Uri.parse('https://play.google.com/store/apps/details?id=$_appPackageName');
    await _launchUrlUri(context, storeUri, fallbackMessage: 'Could not open Play Store. Link copied to clipboard.');
  }

  void _showExportDialog(BuildContext context, AppState state) {
    final jsonStr = state.exportDataAsJson();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.download_rounded, color: AppColors.primary),
            SizedBox(width: 10),
            Text('Export Data (JSON)'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your complete routine, habit, and focus data in JSON format:'),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 180),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.colors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.colors.border),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      jsonStr,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          OutlinedButton.icon(
            icon: const Icon(Icons.share_rounded, size: 16),
            label: const Text('Share Data'),
            onPressed: () {
              Navigator.pop(ctx);
              _safeShare(context, jsonStr, subject: 'Cadence Data Export');
            },
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: const Text('Copy JSON'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: jsonStr));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('JSON data copied to clipboard! 📋'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showRatingDialog(BuildContext context) {
    int selectedStars = 5;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Column(
            children: [
              Icon(Icons.star_rounded, color: Colors.amber, size: 44),
              SizedBox(height: 8),
              Text('Rate My To Do', style: TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                selectedStars == 5
                    ? 'Awesome! Rating 5 stars redirects to Play Store.'
                    : 'Rating 4 stars or less opens email for direct feedback.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12.5),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final starIndex = i + 1;
                  return IconButton(
                    iconSize: 32,
                    icon: Icon(
                      starIndex <= selectedStars ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: Colors.amber,
                    ),
                    onPressed: () => setDialogState(() => selectedStars = starIndex),
                  );
                }),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                if (selectedStars == 5) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Thank you! Redirecting to Play Store for rating... ⭐'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  await _launchPlayStore(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Opening email to share your $selectedStars-star feedback... 💌'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  await _launchEmail(
                    context,
                    email: _feedbackEmail,
                    subject: 'Habit Tracker App Feedback ($selectedStars Stars)',
                    body: 'Hi Team,\n\nI rated the app $selectedStars stars. Here is my feedback:\n\n',
                  );
                }
              },
              child: Text(selectedStars == 5 ? 'Rate on Play Store' : 'Send Email Feedback'),
            ),
          ],
        ),
      ),
    );
  }

  void _shareApp(BuildContext context) {
    const shareMessage =
        'Check out Habit Tracker — Routine Planner & Habit Tracker! Build calm, consistent daily habits and deep focus rhythms: https://play.google.com/store/apps/details?id=$_appPackageName';
    _safeShare(context, shareMessage, subject: 'Try Habit Tracker App');
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        children: [
          const SectionHeader(title: 'Profile'),
          AppCard(
            child: _SettingsRow(
              icon: Icons.person_outline_rounded,
              label: state.userName.isEmpty ? 'Your Name: Friend (Tap to edit)' : 'Your Name: ${state.userName}',
              onTap: () {
                final controller = TextEditingController(text: state.userName);
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: const Text('Update Your Name'),
                    content: TextField(
                      controller: controller,
                      autofocus: true,
                      decoration: const InputDecoration(hintText: 'Enter your name'),
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                      ElevatedButton(
                        onPressed: () async {
                          final newName = controller.text.trim();
                          if (newName.isNotEmpty) {
                            await state.updateUserName(newName);
                          }
                          if (ctx.mounted) Navigator.pop(ctx);
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 26),
          const SectionHeader(title: 'Notifications'),
          AppCard(
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.notifications_active_rounded, size: 20, color: context.colors.textPrimary),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Reminders Enabled', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: context.colors.textPrimary)),
                          const SizedBox(height: 2),
                          Text('Routine & habit reminders, plus daily check-ins', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: state.remindersEnabled,
                      onChanged: (v) => context.read<AppState>().setRemindersEnabled(v),
                    ),
                  ],
                ),
               /* const Divider(height: 20),
                _SettingsRow(
                  icon: Icons.notifications_none_rounded,
                  label: 'Send Test Notification',
                  onTap: () async {
                    final sent = await state.notifications.sendTestNotification();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(sent ? 'Test notification sent! Check your notification tray. 🔔' : 'Notification permission disabled in system settings.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),*/
              ],
            ),
          ),
          const SizedBox(height: 26),
          const SectionHeader(title: 'Appearance'),
          const ThemeSelector(),
          const SizedBox(height: 26),
          const SectionHeader(title: 'Data Management'),
          AppCard(
            child: Column(
              children: [
                _SettingsRow(
                  icon: Icons.download_rounded,
                  label: 'Export Data (JSON)',
                  onTap: () => _showExportDialog(context, state),
                ),
                const Divider(height: 20),
                _SettingsRow(
                  icon: Icons.delete_forever_rounded,
                  label: 'Reset All Data',
                  color: AppColors.error,
                  onTap: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        title: const Text('Reset everything?'),
                        content: const Text('This permanently deletes all routines, habits, and focus history from this device.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Reset'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true && context.mounted) {
                      await context.read<AppState>().resetAllData();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('All data has been reset.'), behavior: SnackBarBehavior.floating),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          const SectionHeader(title: 'Support & Feedback'),
          AppCard(
            child: Column(
              children: [
                _SettingsRow(
                  icon: Icons.star_outline_rounded,
                  label: 'Rate Habit Tracker App',
                  onTap: () => _showRatingDialog(context),
                ),
                const Divider(height: 20),
                _SettingsRow(
                  icon: Icons.share_outlined,
                  label: 'Share App with Friends',
                  onTap: () => _shareApp(context),
                ),
                const Divider(height: 20),
                _SettingsRow(
                  icon: Icons.mail_outline_rounded,
                  label: 'Give Feedback via Email',
                  onTap: () => _launchEmail(
                    context,
                    email: _supportEmail,
                    subject: 'Habit Tracker App Support & Feedback',
                    body: 'Hi Team,\n\nI have a question or suggestion:\n\n',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          const SectionHeader(title: 'About'),
          AppCard(
            child: Column(
              children: [
                _SettingsRow(
                  icon: Icons.privacy_tip_outlined,
                  label: 'Privacy Policy',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())),
                ),
                const Divider(height: 20),
                _SettingsRow(
                  icon: Icons.info_outline_rounded,
                  label: 'About Habit Tracker',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen())),
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback? onTap;

  const _SettingsRow({required this.icon, required this.label, this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = color ?? context.colors.textPrimary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: c),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: c))),
            if (onTap != null) Icon(Icons.chevron_right_rounded, color: context.colors.textSecondary),
          ],
        ),
      ),
    );
  }
}
