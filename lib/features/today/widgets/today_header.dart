import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/cadence_ribbon.dart';
import '../../../shared/widgets/streak_flame.dart';
import '../../settings/settings_screen.dart';

class TodayHeader extends StatelessWidget {
  final String name;
  final int streak;
  const TodayHeader({super.key, required this.name, required this.streak});

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final allCompletedDates = state.habits.fold<Set<String>>({}, (set, h) => set..addAll(h.completedDates));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _showEditNameDialog(context, state),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_greeting,',
                      style: AppTypography.displayMedium.copyWith(
                        fontSize: 16,
                        color: context.colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name.isEmpty ? 'Friend' : name,
                            style: AppTypography.displayLarge.copyWith(
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              color: context.colors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.edit_outlined, size: 16, color: context.colors.textSecondary.withOpacity(0.6)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            StreakFlame(streak: streak, iconSize: 16),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: context.colors.card,
                  shape: BoxShape.circle,
                  border: Border.all(color: context.colors.border),
                ),
                child: Icon(Icons.settings_rounded, color: context.colors.textPrimary, size: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Compact Cadence Ribbon (14 days) under greeting
        CadenceRibbon(
          completedDates: allCompletedDates,
          daysCount: 14,
          compact: true,
          height: 22,
        ),
      ],
    );
  }

  void _showEditNameDialog(BuildContext context, AppState state) {
    final controller = TextEditingController(text: state.userName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Update Your Name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter your name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
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
  }
}
