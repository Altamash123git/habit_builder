import 'package:flutter/material.dart';
import '../utils/date_utils.dart';

enum HabitFrequency { daily, weekly }

class Habit {
  final String id;
  String title;
  IconData icon;
  Color color;
  HabitFrequency frequency;
  int weeklyTarget; // used when frequency == weekly
  bool archived;

  /// Target daily count for counter habits (e.g. 8 for 8 glasses of water, 10 for 10 pages).
  /// Default 1 = standard checkoff habit.
  int targetCount;

  /// Unit description for counter habits (e.g. 'glasses', 'cups', 'mins', 'pages', 'times').
  String unit;

  /// Daily recorded counts mapped by 'yyyy-MM-dd' date string.
  Map<String, int> dailyCounts;

  /// Optional free-text note — why this habit matters, how to do it, etc.
  String? notes;

  /// Optional short motivational line shown on the detail screen and used
  /// as the body of the daily reminder notification, if set.
  String? motivation;

  /// Optional target — "build this habit in N days" (e.g. 21/30/66/custom).
  /// Null means an open-ended, ongoing habit with no deadline.
  int? goalDays;

  /// When the habit was created / the goal clock started.
  DateTime startDate;

  /// If true, a best-effort "you haven't checked this off yet" notification
  /// is scheduled for the evening (see NotificationService).
  bool missedReminderEnabled;

  String? reminderTime; // 'HH:mm', 24h, local time — null means no daily reminder

  /// Dates (yyyy-MM-dd keys) on which the habit was checked off.
  Set<String> completedDates;

  Habit({
    required this.id,
    required this.title,
    this.icon = Icons.check_circle_rounded,
    this.color = const Color(0xFF4353FF),
    this.frequency = HabitFrequency.daily,
    this.weeklyTarget = 3,
    this.archived = false,
    this.targetCount = 1,
    this.unit = 'times',
    Map<String, int>? dailyCounts,
    this.notes,
    this.motivation,
    this.goalDays,
    DateTime? startDate,
    this.missedReminderEnabled = false,
    this.reminderTime,
    Set<String>? completedDates,
  })  : startDate = startDate ?? AppDate.dateOnly(DateTime.now()),
        dailyCounts = dailyCounts ?? <String, int>{},
        completedDates = completedDates ?? <String>{};

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'icon': icon.codePoint,
    'color': color.value,
    'frequency': frequency.name,
    'weeklyTarget': weeklyTarget,
    'archived': archived,
    'targetCount': targetCount,
    'unit': unit,
    'dailyCounts': dailyCounts,
    'notes': notes,
    'motivation': motivation,
    'goalDays': goalDays,
    'startDate': startDate.toIso8601String(),
    'missedReminderEnabled': missedReminderEnabled,
    'reminderTime': reminderTime,
    'completedDates': completedDates.toList(),
  };

  factory Habit.fromJson(Map<String, dynamic> j) => Habit(
    id: j['id'] as String,
    title: j['title'] as String,
    icon: parseHabitIcon(j['icon'] as int?),
    color: Color(j['color'] as int? ?? 0xFF4353FF),
    frequency: HabitFrequency.values.firstWhere((f) => f.name == j['frequency'], orElse: () => HabitFrequency.daily),
    weeklyTarget: j['weeklyTarget'] as int? ?? 3,
    archived: j['archived'] as bool? ?? false,
    targetCount: j['targetCount'] as int? ?? 1,
    unit: j['unit'] as String? ?? 'times',
    dailyCounts: ((j['dailyCounts'] as Map?) ?? {}).map((k, v) => MapEntry(k.toString(), (v as num).toInt())),
    notes: j['notes'] as String?,
    motivation: j['motivation'] as String?,
    goalDays: j['goalDays'] as int?,
    startDate: j['startDate'] != null ? DateTime.parse(j['startDate'] as String) : AppDate.dateOnly(DateTime.now()),
    missedReminderEnabled: j['missedReminderEnabled'] as bool? ?? false,
    reminderTime: j['reminderTime'] as String?,
    completedDates: ((j['completedDates'] as List?) ?? const []).map((e) => e as String).toSet(),
  );
}

const List<IconData> _kSupportedHabitIcons = [
  Icons.check_circle_rounded,
  Icons.water_drop_rounded,
  Icons.menu_book_rounded,
  Icons.directions_run_rounded,
  Icons.self_improvement_rounded,
  Icons.bedtime_rounded,
  Icons.no_food_rounded,
  Icons.edit_note_rounded,
  Icons.spa_rounded,
  Icons.fitness_center_rounded,
  Icons.emoji_food_beverage_rounded,
  Icons.savings_rounded,
  Icons.language_rounded,
  Icons.music_note_rounded,
  Icons.brush_rounded,
  Icons.eco_rounded,
  Icons.psychology_rounded,
  Icons.wb_sunny_rounded,
  Icons.nights_stay_rounded,
  Icons.work_rounded,
  Icons.school_rounded,
  Icons.favorite_rounded,
];

IconData parseHabitIcon(int? codePoint) {
  if (codePoint == null) return Icons.check_circle_rounded;
  for (final icon in _kSupportedHabitIcons) {
    if (icon.codePoint == codePoint) {
      return icon;
    }
  }
  return Icons.check_circle_rounded;
}

/// Goal / progress math kept alongside the model so every screen computes
/// it the same way.
extension HabitProgressX on Habit {
  bool get isCounterHabit => targetCount > 1;

  int getCountOn(DateTime date) {
    final key = AppDate.key(date);
    if (dailyCounts.containsKey(key)) {
      return dailyCounts[key]!;
    }
    return completedDates.contains(key) ? targetCount : 0;
  }

  int get currentCountToday => getCountOn(DateTime.now());

  double get dailyProgressToday => (currentCountToday / targetCount).clamp(0.0, 1.0);

  /// 1-indexed day count since the habit was created (today counts as day 1).
  int get daysSinceStart => AppDate.dateOnly(DateTime.now()).difference(startDate).inDays + 1;

  bool get hasGoal => goalDays != null && goalDays! > 0;

  /// Progress toward the day-count goal, based on total check-ins so far.
  /// Null when the habit has no deadline.
  double? get goalProgress {
    if (!hasGoal) return null;
    return (completedDates.length / goalDays!).clamp(0.0, 1.0);
  }

  bool get goalReached => hasGoal && completedDates.length >= goalDays!;

  int? get daysRemainingInGoal {
    if (!hasGoal) return null;
    return (goalDays! - completedDates.length).clamp(0, goalDays!);
  }

  /// Share of days since start that were completed — a simple, forgiving
  /// consistency metric shown on the detail screen.
  double get consistencyRate {
    final days = daysSinceStart.clamp(1, 1 << 30);
    return (completedDates.length / days).clamp(0.0, 1.0);
  }

  /// How many days since start were missed (past days, not completed).
  int get missedDaysCount => (daysSinceStart - completedDates.length).clamp(0, 1 << 30);

  /// Current consecutive days streak ending today or yesterday.
  int get currentStreak => AppDate.currentStreak(completedDates);
}