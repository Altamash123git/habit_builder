import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/routine.dart';
import '../models/habit.dart';
import '../models/focus_session.dart';
import '../services/storage_service.dart';
import '../services/templates.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import '../utils/date_utils.dart';

const _uuid = Uuid();
const int maxRoutinesFree = 3;
const int maxHabitsFree = 5;

/// Single source of truth for the app. Kept as a plain ChangeNotifier so the
/// whole project runs with zero code generation. See README for the path to
/// Riverpod + Drift if you want to scale this to the full PRD spec.
class AppState extends ChangeNotifier {
  final StorageService storage;
  final NotificationService notifications = NotificationService.instance;

  AppState(this.storage) {
    _routines = storage.loadRoutines();
    _habits = storage.loadHabits();
    _focusSessions = storage.loadFocusSessions();
    _themeMode = _parseThemeMode(storage.themeMode);
    _isPremium = storage.isPremium;
    _onboarded = storage.onboarded;
    _userName = storage.userName;
    _remindersEnabled = storage.remindersEnabled;
    _focusWorkMinutes = storage.focusWorkMinutes;
    _focusShortBreakMinutes = storage.focusShortBreakMinutes;
    _focusLongBreakMinutes = storage.focusLongBreakMinutes;
    _rolloverIfNewDay();
    if (_routines.isEmpty && _habits.isEmpty && _onboarded) {
      _seedSampleData();
    }
  }

  // ---------------- Theme ----------------
  late AppThemeMode _themeMode;
  AppThemeMode get themeMode => _themeMode;
  Future<void> setThemeMode(AppThemeMode mode) async {
    _themeMode = mode;
    await storage.setThemeMode(mode.name);
    notifyListeners();
  }

  AppThemeMode _parseThemeMode(String? raw) =>
      AppThemeMode.values.firstWhere((m) => m.name == raw, orElse: () => AppThemeMode.light);

  // ---------------- Onboarding / profile ----------------
  late bool _onboarded;
  bool get onboarded => _onboarded;

  late String _userName;
  String get userName => _userName;

  Future<void> updateUserName(String name) async {
    _userName = name;
    await storage.setUserName(name);
    notifyListeners();
  }

  Future<void> completeOnboarding({required String name, RoutineTemplate? starterTemplate}) async {
    _userName = name;
    await storage.setUserName(name);
    if (starterTemplate != null) {
      _routines.add(buildRoutineFromTemplate(starterTemplate));
    }
    _habits.addAll(defaultStarterHabits());
    _onboarded = true;
    await storage.setOnboarded(true);
    await storage.saveRoutines(_routines);
    await storage.saveHabits(_habits);
    final granted = await notifications.requestPermissions();
    if (granted && _remindersEnabled) {
      await notifications.scheduleEveningNudge();
    }
    notifyListeners();
  }

  void _seedSampleData() {
    // Safety net only — normal flow seeds via completeOnboarding().
  }

  // ---------------- Premium ----------------
  late bool _isPremium;
  bool get isPremium => _isPremium;

  /// Wire this to `in_app_purchase` in production (see README §Monetization).
  Future<void> setPremium(bool value) async {
    _isPremium = value;
    await storage.setPremium(value);
    notifyListeners();
  }

  bool get routineLimitReached => false;
  bool get habitLimitReached => false;

  // ---------------- Reminders ----------------
  late bool _remindersEnabled;
  bool get remindersEnabled => _remindersEnabled;

  Future<void> setRemindersEnabled(bool value) async {
    _remindersEnabled = value;
    await storage.setRemindersEnabled(value);
    if (value) {
      final granted = await notifications.requestPermissions();
      if (granted) {
        await notifications.scheduleEveningNudge();
        for (final r in _routines) {
          if (r.reminderTime != null) await _scheduleRoutineReminder(r);
        }
        for (final h in _habits) {
          if (h.reminderTime != null) await _scheduleHabitReminder(h);
          if (h.missedReminderEnabled) await _scheduleMissedReminder(h);
        }
      }
    } else {
      await notifications.cancelAll();
    }
    notifyListeners();
  }

  Future<void> _scheduleRoutineReminder(Routine r) async {
    final time = AppDate.parseTimeOfDay(r.reminderTime);
    if (time == null) return;
    await notifications.scheduleRoutineReminder(routineId: r.id, routineTitle: r.title, time: time, activeDays: r.activeDays);
  }

  Future<void> _scheduleHabitReminder(Habit h) async {
    final time = AppDate.parseTimeOfDay(h.reminderTime);
    if (time == null) return;
    await notifications.scheduleHabitReminder(habitId: h.id, habitTitle: h.title, time: time, motivation: h.motivation);
  }

  Future<void> _scheduleMissedReminder(Habit h) async {
    await notifications.scheduleHabitMissedReminder(habitId: h.id, habitTitle: h.title);
  }

  // ---------------- Day rollover ----------------
  void _rolloverIfNewDay() {
    final todayKey = AppDate.key(DateTime.now());
    if (storage.lastActiveDate != todayKey) {
      for (final r in _routines) {
        final last = r.lastCompletedDate;
        final stillToday = last != null && AppDate.key(last) == todayKey;
        if (!stillToday) {
          for (final t in r.tasks) {
            t.completedToday = false;
          }
        }
      }
      storage.setLastActiveDate(todayKey);
      storage.saveRoutines(_routines);
    }
  }

  // ---------------- Routines ----------------
  late List<Routine> _routines;
  List<Routine> get routines => List.unmodifiable(_routines.where((r) => !r.archived));
  List<Routine> get todaysRoutines {
    final weekday = DateTime.now().weekday;
    return routines.where((r) => r.activeDays.contains(weekday)).toList();
  }

  Future<void> addRoutine(Routine routine) async {
    _routines.add(routine);
    await storage.saveRoutines(_routines);
    if (_remindersEnabled && routine.reminderTime != null) await _scheduleRoutineReminder(routine);
    notifyListeners();
  }

  Future<void> updateRoutine(Routine routine) async {
    final i = _routines.indexWhere((r) => r.id == routine.id);
    if (i != -1) _routines[i] = routine;
    await storage.saveRoutines(_routines);
    if (routine.reminderTime != null && _remindersEnabled) {
      await _scheduleRoutineReminder(routine);
    } else {
      await notifications.cancelRoutineReminder(routine.id);
    }
    notifyListeners();
  }

  Future<void> deleteRoutine(String id) async {
    _routines.removeWhere((r) => r.id == id);
    await storage.saveRoutines(_routines);
    await notifications.cancelRoutineReminder(id);
    notifyListeners();
  }

  Future<void> toggleRoutineTask(String routineId, String taskId) async {
    final routine = _routines.firstWhere((r) => r.id == routineId);
    final task = routine.tasks.firstWhere((t) => t.id == taskId);
    task.completedToday = !task.completedToday;
    if (routine.isDoneToday) {
      routine.lastCompletedDate = AppDate.dateOnly(DateTime.now());
    }
    await storage.saveRoutines(_routines);
    notifyListeners();
  }

  // ---------------- Habits ----------------
  late List<Habit> _habits;
  List<Habit> get habits => List.unmodifiable(_habits.where((h) => !h.archived));

  Future<void> addHabit(Habit habit) async {
    _habits.add(habit);
    await storage.saveHabits(_habits);
    await _applyHabitReminders(habit);
    notifyListeners();
  }

  Future<void> updateHabit(Habit habit) async {
    final i = _habits.indexWhere((h) => h.id == habit.id);
    if (i != -1) _habits[i] = habit;
    await storage.saveHabits(_habits);
    await _applyHabitReminders(habit);
    notifyListeners();
  }

  Future<void> _applyHabitReminders(Habit habit) async {
    if (_remindersEnabled && habit.reminderTime != null) {
      await _scheduleHabitReminder(habit);
    } else {
      await notifications.cancelHabitReminder(habit.id);
    }
    if (_remindersEnabled && habit.missedReminderEnabled) {
      await _scheduleMissedReminder(habit);
    } else {
      await notifications.cancelHabitMissedReminder(habit.id);
    }
  }

  Future<void> deleteHabit(String id) async {
    _habits.removeWhere((h) => h.id == id);
    await storage.saveHabits(_habits);
    await notifications.cancelHabitReminder(id);
    await notifications.cancelHabitMissedReminder(id);
    notifyListeners();
  }

  Future<void> toggleHabitToday(String habitId) async {
    final habit = _habits.firstWhere((h) => h.id == habitId);
    final key = AppDate.key(DateTime.now());
    if (habit.completedDates.contains(key)) {
      habit.completedDates.remove(key);
      habit.dailyCounts.remove(key);
    } else {
      habit.completedDates.add(key);
      habit.dailyCounts[key] = habit.targetCount;
    }
    await storage.saveHabits(_habits);
    notifyListeners();
  }

  Future<void> updateHabitCount(String habitId, int count, {DateTime? date}) async {
    final targetDate = date ?? DateTime.now();
    final key = AppDate.key(targetDate);
    final habit = _habits.firstWhere((h) => h.id == habitId);
    final newCount = count.clamp(0, 9999);

    if (newCount == 0) {
      habit.dailyCounts.remove(key);
      habit.completedDates.remove(key);
    } else {
      habit.dailyCounts[key] = newCount;
      if (newCount >= habit.targetCount) {
        habit.completedDates.add(key);
      } else {
        habit.completedDates.remove(key);
      }
    }
    await storage.saveHabits(_habits);
    notifyListeners();
  }

  Future<void> incrementHabitCount(String habitId, {int delta = 1, DateTime? date}) async {
    final targetDate = date ?? DateTime.now();
    final habit = _habits.firstWhere((h) => h.id == habitId);
    final current = habit.getCountOn(targetDate);
    await updateHabitCount(habitId, current + delta, date: targetDate);
  }

  bool isHabitDoneToday(Habit habit) => habit.completedDates.contains(AppDate.key(DateTime.now()));

  // ---------------- Focus Custom Durations ----------------
  late int _focusWorkMinutes;
  int get focusWorkMinutes => _focusWorkMinutes;
  Future<void> setFocusWorkMinutes(int mins) async {
    _focusWorkMinutes = mins;
    await storage.setFocusWorkMinutes(mins);
    notifyListeners();
  }

  late int _focusShortBreakMinutes;
  int get focusShortBreakMinutes => _focusShortBreakMinutes;
  Future<void> setFocusShortBreakMinutes(int mins) async {
    _focusShortBreakMinutes = mins;
    await storage.setFocusShortBreakMinutes(mins);
    notifyListeners();
  }

  late int _focusLongBreakMinutes;
  int get focusLongBreakMinutes => _focusLongBreakMinutes;
  Future<void> setFocusLongBreakMinutes(int mins) async {
    _focusLongBreakMinutes = mins;
    await storage.setFocusLongBreakMinutes(mins);
    notifyListeners();
  }

  // ---------------- Focus sessions ----------------
  late List<FocusSession> _focusSessions;
  List<FocusSession> get focusSessions => List.unmodifiable(_focusSessions.reversed);

  Future<void> logFocusSession(int minutes, {String? label, String? remark}) async {
    final session = FocusSession(
      id: _uuid.v4(),
      date: DateTime.now(),
      minutes: minutes,
      label: label,
      remark: remark,
    );
    _focusSessions.add(session);
    await storage.saveFocusSessions(_focusSessions);
    if (_remindersEnabled) {
      await notifications.showFocusSessionComplete(modeLabel: label ?? 'Focus session', minutes: minutes);
    }
    notifyListeners();
  }

  Future<void> deleteFocusSession(String id) async {
    _focusSessions.removeWhere((s) => s.id == id);
    await storage.saveFocusSessions(_focusSessions);
    notifyListeners();
  }

  int get totalFocusMinutes => _focusSessions.fold(0, (sum, s) => sum + s.minutes);

  int focusMinutesOn(DateTime day) => _focusSessions
      .where((s) => AppDate.isSameDay(s.date, day))
      .fold(0, (sum, s) => sum + s.minutes);

  // ---------------- JSON Export ----------------
  String exportDataAsJson() {
    final data = {
      'app': 'Cadence',
      'exportedAt': DateTime.now().toIso8601String(),
      'userName': _userName,
      'themeMode': _themeMode.name,
      'isPremium': _isPremium,
      'routines': _routines.map((r) => r.toJson()).toList(),
      'habits': _habits.map((h) => h.toJson()).toList(),
      'focusSessions': _focusSessions.map((s) => s.toJson()).toList(),
      'focusSettings': {
        'workMinutes': _focusWorkMinutes,
        'shortBreakMinutes': _focusShortBreakMinutes,
        'longBreakMinutes': _focusLongBreakMinutes,
      },
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  // ---------------- Aggregate stats (for progress + achievements) ----------------
  int get bestOverallStreak {
    final allDates = <String>{};
    for (final h in _habits) {
      allDates.addAll(h.completedDates);
    }
    for (final r in _routines) {
      if (r.lastCompletedDate != null) allDates.add(AppDate.key(r.lastCompletedDate!));
    }
    return AppDate.bestStreak(allDates);
  }

  int get currentOverallStreak {
    final allDates = <String>{};
    for (final h in _habits) {
      allDates.addAll(h.completedDates);
    }
    for (final r in _routines) {
      if (r.lastCompletedDate != null) allDates.add(AppDate.key(r.lastCompletedDate!));
    }
    return AppDate.currentStreak(allDates);
  }

  int get totalCompletions {
    final routineTaskCompletions = _routines.fold<int>(0, (sum, r) => sum + r.completedCount);
    final habitCompletions = _habits.fold<int>(0, (sum, h) => sum + h.completedDates.length);
    return routineTaskCompletions + habitCompletions;
  }

  double completionRateOn(DateTime day) {
    final key = AppDate.key(day);
    int done = 0, total = 0;
    for (final h in _habits) {
      total++;
      if (h.completedDates.contains(key)) done++;
    }
    if (total == 0) return 0;
    return done / total;
  }

  Future<void> resetAllData() async {
    await storage.wipeAll();
    await notifications.cancelAll();
    _routines = [];
    _habits = [];
    _focusSessions = [];
    _onboarded = false;
    notifyListeners();
  }
}