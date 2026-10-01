import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_bottom_nav.dart';
import '../focus/focus_screen.dart';
import '../habits/habits_screen.dart';
import '../progress/progress_screen.dart';
import '../routines/routines_screen.dart';
import '../today/today_screen.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  final _screens = const [
    TodayScreen(),
    RoutinesScreen(),
    HabitsScreen(),
    FocusScreen(),
    ProgressScreen(),
  ];

  Future<bool> _showExitConfirmationDialog() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: context.colors.card,
        title: Text(
          'Exit Habit Tracker?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: context.colors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to close the app?',
          style: TextStyle(
            color: context.colors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: context.colors.textSecondary, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Exit App', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_index != 0) {
          setState(() => _index = 0);
          return;
        }
        final shouldExit = await _showExitConfirmationDialog();
        if (shouldExit && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: context.colors.bg,
        extendBody: true,
        body: IndexedStack(index: _index, children: _screens),
        bottomNavigationBar: AppBottomNav(index: _index, onChanged: (i) => setState(() => _index = i)),
      ),
    );
  }
}
