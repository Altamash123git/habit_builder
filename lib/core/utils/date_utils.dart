import 'package:flutter/material.dart';

class AppDate {
  AppDate._();

  /// 'HH:mm' (24h) <-> TimeOfDay helpers, used for routine/habit reminders.
  static String formatTimeOfDay(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  static TimeOfDay? parseTimeOfDay(String? raw) {
    if (raw == null) return null;
    final parts = raw.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  static String key(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static bool isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  static String weekdayShort(DateTime d) => const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d.weekday - 1];

  static String monthDay(DateTime d) => '${const [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][d.month - 1]} ${d.day}';

  /// Last [count] days ending today, oldest first.
  static List<DateTime> lastDays(int count) {
    final today = dateOnly(DateTime.now());
    return List.generate(count, (i) => today.subtract(Duration(days: count - 1 - i)));
  }

  /// Compute current streak (consecutive days up to today or yesterday)
  /// from a set of yyyy-MM-dd date keys.
  static int currentStreak(Set<String> dateKeys) {
    if (dateKeys.isEmpty) return 0;
    var cursor = dateOnly(DateTime.now());
    // allow the streak to still count if today isn't done yet but yesterday was
    if (!dateKeys.contains(key(cursor))) {
      cursor = cursor.subtract(const Duration(days: 1));
      if (!dateKeys.contains(key(cursor))) return 0;
    }
    int streak = 0;
    while (dateKeys.contains(key(cursor))) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  static int bestStreak(Set<String> dateKeys) {
    if (dateKeys.isEmpty) return 0;
    final dates = dateKeys.map((k) {
      final p = k.split('-');
      return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
    }).toList()
      ..sort();
    int best = 1, run = 1;
    for (int i = 1; i < dates.length; i++) {
      if (dates[i].difference(dates[i - 1]).inDays == 1) {
        run++;
      } else if (dates[i].difference(dates[i - 1]).inDays > 1) {
        run = 1;
      }
      if (run > best) best = run;
    }
    return best;
  }
}
