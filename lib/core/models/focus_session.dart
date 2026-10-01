class FocusSession {
  final String id;
  final DateTime date;
  final int minutes;
  final String? label;
  final String? remark;

  FocusSession({
    required this.id,
    required this.date,
    required this.minutes,
    this.label,
    this.remark,
  });

  String get computedRemark {
    if (remark != null && remark!.isNotEmpty) return remark!;
    final l = (label ?? '').toLowerCase();
    if (l.contains('short break')) return '☕ Refresh & Recharge';
    if (l.contains('long break')) return '🌿 Complete Mind Reset';
    if (minutes >= 45) return '⚡ High Productivity Flow State';
    if (minutes >= 25) return '🎯 Deep Work Master';
    if (minutes >= 15) return '🔥 Solid Focus Session';
    return '🌱 Quick Power Focus';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'minutes': minutes,
        'label': label,
        'remark': remark,
      };

  factory FocusSession.fromJson(Map<String, dynamic> j) => FocusSession(
        id: j['id'] as String,
        date: DateTime.parse(j['date'] as String),
        minutes: j['minutes'] as int,
        label: j['label'] as String?,
        remark: j['remark'] as String?,
      );
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon; // emoji, keeps this dependency-free
  final bool Function(int bestStreak, int totalCompletions, int focusMinutes) isUnlocked;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
  });
}

final List<Achievement> kAchievements = [
  Achievement(
    id: 'first_step',
    title: 'First Step',
    description: 'Complete your first routine or habit',
    icon: '🌱',
    isUnlocked: (streak, total, focus) => total >= 1,
  ),
  Achievement(
    id: 'three_day',
    title: 'Momentum',
    description: 'Reach a 3-day streak',
    icon: '🔥',
    isUnlocked: (streak, total, focus) => streak >= 3,
  ),
  Achievement(
    id: 'week_streak',
    title: 'One Week Strong',
    description: 'Reach a 7-day streak',
    icon: '⭐',
    isUnlocked: (streak, total, focus) => streak >= 7,
  ),
  Achievement(
    id: 'month_streak',
    title: 'Unstoppable',
    description: 'Reach a 30-day streak',
    icon: '🏆',
    isUnlocked: (streak, total, focus) => streak >= 30,
  ),
  Achievement(
    id: 'focus_hour',
    title: 'Deep Work',
    description: 'Log 60 minutes of focus time',
    icon: '🎯',
    isUnlocked: (streak, total, focus) => focus >= 60,
  ),
  Achievement(
    id: 'fifty_completions',
    title: 'Consistent',
    description: 'Complete 50 tasks or habit check-ins',
    icon: '💫',
    isUnlocked: (streak, total, focus) => total >= 50,
  ),
];
