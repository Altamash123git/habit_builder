import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/focus_session.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/misc_widgets.dart';
import 'widgets/timer_dial.dart';

enum _FocusMode { work, shortBreak, longBreak }

extension on _FocusMode {
  String get label => switch (this) {
        _FocusMode.work => 'Focus',
        _FocusMode.shortBreak => 'Short Break',
        _FocusMode.longBreak => 'Long Break',
      };

  IconData get icon => switch (this) {
        _FocusMode.work => Icons.center_focus_strong_rounded,
        _FocusMode.shortBreak => Icons.coffee_rounded,
        _FocusMode.longBreak => Icons.spa_rounded,
      };

  Color get color => switch (this) {
        _FocusMode.work => AppColors.verdigris500,
        _FocusMode.shortBreak => AppColors.verdigris300,
        _FocusMode.longBreak => AppColors.marigold500,
      };

  int minutes(AppState state) => switch (this) {
        _FocusMode.work => state.focusWorkMinutes,
        _FocusMode.shortBreak => state.focusShortBreakMinutes,
        _FocusMode.longBreak => state.focusLongBreakMinutes,
      };
}

class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  _FocusMode _mode = _FocusMode.work;
  int? _overrideSeconds;
  Timer? _timer;
  bool _running = false;
  int _completedWorkSessions = 0;

  int _getModeSeconds(AppState state) {
    return _mode.minutes(state) * 60;
  }

  int get _remainingSeconds {
    final state = context.read<AppState>();
    return _overrideSeconds ?? _getModeSeconds(state);
  }

  void _toggle() {
    if (_running) {
      _pause();
    } else {
      _start();
    }
  }

  void _start() {
    setState(() => _running = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remainingSeconds <= 1) {
        _complete();
      } else {
        setState(() => _overrideSeconds = _remainingSeconds - 1);
      }
    });
  }

  void _pause() {
    _timer?.cancel();
    setState(() => _running = false);
  }

  void _reset() {
    _timer?.cancel();
    final state = context.read<AppState>();
    setState(() {
      _running = false;
      _overrideSeconds = _getModeSeconds(state);
    });
  }

  void _complete() {
    _timer?.cancel();
    final state = context.read<AppState>();
    final mins = _mode.minutes(state);

    if (_mode == _FocusMode.work) {
      state.logFocusSession(mins, label: 'Focus');
      _completedWorkSessions++;
    } else {
      state.logFocusSession(mins, label: _mode.label);
    }

    final next = _mode == _FocusMode.work
        ? (_completedWorkSessions % 4 == 0 ? _FocusMode.longBreak : _FocusMode.shortBreak)
        : _FocusMode.work;

    setState(() {
      _running = false;
      _mode = next;
      _overrideSeconds = next.minutes(state) * 60;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_mode == _FocusMode.work ? 'Break over — time to focus! 🎯' : 'Great work! Take a break. ☕'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _switchMode(_FocusMode m) {
    _timer?.cancel();
    final state = context.read<AppState>();
    setState(() {
      _mode = m;
      _running = false;
      _overrideSeconds = m.minutes(state) * 60;
    });
  }

  Future<void> _showCustomDurationDialog(AppState state) async {
    int workMins = state.focusWorkMinutes;
    int shortMins = state.focusShortBreakMinutes;
    int longMins = state.focusLongBreakMinutes;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(
            children: [
              Icon(Icons.tune_rounded, color: AppColors.primary),
              SizedBox(width: 10),
              Text('Custom Timer Settings'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDurationRow('Focus Duration', workMins, AppColors.secondary, (v) => setDialogState(() => workMins = v.clamp(1, 180))),
              const SizedBox(height: 12),
              _buildDurationRow('Short Break', shortMins, AppColors.success, (v) => setDialogState(() => shortMins = v.clamp(1, 60))),
              const SizedBox(height: 12),
              _buildDurationRow('Long Break', longMins, AppColors.primary, (v) => setDialogState(() => longMins = v.clamp(1, 120))),
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
                await state.setFocusWorkMinutes(workMins);
                await state.setFocusShortBreakMinutes(shortMins);
                await state.setFocusLongBreakMinutes(longMins);
                if (mounted) {
                  setState(() {
                    _overrideSeconds = _getModeSeconds(state);
                  });
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Save Settings'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationRow(String title, int value, Color color, ValueChanged<int> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: context.colors.textPrimary)),
            ],
          ),
          Row(
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.remove_circle_outline, size: 20),
                onPressed: value > 1 ? () => onChanged(value - 1) : null,
              ),
              Text('$value m', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.add_circle_outline, size: 20),
                onPressed: () => onChanged(value + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _format(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final todayMinutes = state.focusMinutesOn(DateTime.now());
    final totalSecs = _getModeSeconds(state);
    final progress = (totalSecs > 0) ? (1 - (_remainingSeconds / totalSecs)).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Focus', style: Theme.of(context).textTheme.displayMedium),
                      const SizedBox(height: 4),
                      Text('$todayMinutes min focused today · distraction-free', style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                  IconButton.filledTonal(
                    icon: const Icon(Icons.tune_rounded),
                    tooltip: 'Timer settings',
                    onPressed: () => _showCustomDurationDialog(state),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
                children: [
                  const SizedBox(height: 12),

          // Custom Premium Segmented Pill Selector
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: context.colors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.colors.border),
            ),
            child: Row(
              children: [
                for (final m in _FocusMode.values)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _switchMode(m),
                      child: AnimatedContainer(
                        duration: AppDuration.fast,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _mode == m ? m.color.withOpacity(0.16) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _mode == m ? m.color : Colors.transparent,
                            width: 1.4,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(m.icon, color: _mode == m ? m.color : context.colors.textSecondary, size: 18),
                            const SizedBox(height: 4),
                            Text(
                              m.label,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: _mode == m ? FontWeight.w800 : FontWeight.w600,
                                color: _mode == m ? m.color : context.colors.textSecondary,
                              ),
                            ),
                            Text(
                              '${m.minutes(state)}m',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _mode == m ? m.color.withOpacity(0.8) : context.colors.textSecondary.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: TimerDial(
                progress: progress,
                timeLabel: _format(_remainingSeconds),
                modeLabel: _mode.label,
                color: _mode.color,
                running: _running,
              ),
            ),
          ),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _reset,
                  child: const Padding(padding: EdgeInsets.symmetric(vertical: 4), child: Text('Reset')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: GradientButton(
                  label: _running ? 'Pause' : (_remainingSeconds == totalSecs ? 'Start' : 'Resume'),
                  icon: _running ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  gradient: LinearGradient(colors: [_mode.color, _mode.color.withOpacity(0.8)]),
                  onTap: _toggle,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Focus Session History Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Focus History', style: Theme.of(context).textTheme.titleLarge),
              Text(
                '${state.focusSessions.length} sessions',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.colors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (state.focusSessions.isEmpty)
            AppCard(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
              child: Column(
                children: [
                  Icon(Icons.history_rounded, size: 36, color: context.colors.textSecondary.withOpacity(0.5)),
                  const SizedBox(height: 8),
                  Text('No sessions logged yet', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text('Start a timer above to track your daily deep work.', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            )
          else
            for (final session in state.focusSessions.take(10))
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _FocusHistoryTile(session: session),
              ),
          ],
        ),
      ),
    ],
  ),
),
);
  }
}

class _FocusHistoryTile extends StatelessWidget {
  final FocusSession session;
  const _FocusHistoryTile({required this.session});

  @override
  Widget build(BuildContext context) {
    final modeColor = (session.label ?? '').toLowerCase().contains('break') ? AppColors.success : AppColors.secondary;
    final dateStr = '${_monthName(session.date.month)} ${session.date.day} • ${_timeFormat(session.date)}';

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: modeColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              (session.label ?? '').toLowerCase().contains('break') ? Icons.coffee_rounded : Icons.center_focus_strong_rounded,
              color: modeColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      session.label ?? 'Focus Session',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: modeColor.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${session.minutes} min',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: modeColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  session.computedRemark,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.colors.textPrimary.withOpacity(0.9)),
                ),
                const SizedBox(height: 2),
                Text(
                  dateStr,
                  style: TextStyle(fontSize: 10.5, color: context.colors.textSecondary),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, size: 18, color: context.colors.textSecondary),
            onPressed: () async {
              await context.read<AppState>().deleteFocusSession(session.id);
            },
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[(month - 1).clamp(0, 11)];
  }

  String _timeFormat(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final ampm = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $ampm';
  }
}
