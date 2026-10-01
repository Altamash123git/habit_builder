import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/state/app_state.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';

class CadenceApp extends StatelessWidget {
  const CadenceApp({super.key});

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<AppState>().themeMode;
    final theme = switch (mode) {
      AppThemeMode.light => AppTheme.light(),
      AppThemeMode.dark => AppTheme.dark(),
    };

    return MaterialApp(
      title: 'Habit Tracker',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: const SplashScreen(),
    );
  }
}
