import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/routine.dart';
import '../models/habit.dart';
import '../models/focus_session.dart';

/// Offline-first, on-device persistence. Everything is stored as JSON in
/// SharedPreferences. This keeps the reference implementation dependency
/// light and build_runner-free; swap for Drift/Isar behind this same
/// interface if you need relational queries at scale (see README).
class StorageService {
  static const _kRoutines = 'cadence.routines';
  static const _kHabits = 'cadence.habits';
  static const _kFocusSessions = 'cadence.focus_sessions';
  static const _kThemeMode = 'cadence.theme_mode';
  static const _kOnboarded = 'cadence.onboarded';
  static const _kPremium = 'cadence.premium';
  static const _kUserName = 'cadence.user_name';
  static const _kLastActiveDate = 'cadence.last_active_date';
  static const _kRemindersEnabled = 'cadence.reminders_enabled';
  static const _kFocusWorkMinutes = 'cadence.focus_work_minutes';
  static const _kFocusShortBreakMinutes = 'cadence.focus_short_break_minutes';
  static const _kFocusLongBreakMinutes = 'cadence.focus_long_break_minutes';

  final SharedPreferences _prefs;
  StorageService(this._prefs);

  static Future<StorageService> create() async => StorageService(await SharedPreferences.getInstance());

  int get focusWorkMinutes => _prefs.getInt(_kFocusWorkMinutes) ?? 25;
  Future<void> setFocusWorkMinutes(int mins) => _prefs.setInt(_kFocusWorkMinutes, mins);

  int get focusShortBreakMinutes => _prefs.getInt(_kFocusShortBreakMinutes) ?? 5;
  Future<void> setFocusShortBreakMinutes(int mins) => _prefs.setInt(_kFocusShortBreakMinutes, mins);

  int get focusLongBreakMinutes => _prefs.getInt(_kFocusLongBreakMinutes) ?? 15;
  Future<void> setFocusLongBreakMinutes(int mins) => _prefs.setInt(_kFocusLongBreakMinutes, mins);

  // ---- Routines ----
  List<Routine> loadRoutines() {
    final raw = _prefs.getString(_kRoutines);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => Routine.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveRoutines(List<Routine> routines) =>
      _prefs.setString(_kRoutines, jsonEncode(routines.map((r) => r.toJson()).toList()));

  // ---- Habits ----
  List<Habit> loadHabits() {
    final raw = _prefs.getString(_kHabits);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => Habit.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveHabits(List<Habit> habits) =>
      _prefs.setString(_kHabits, jsonEncode(habits.map((h) => h.toJson()).toList()));

  // ---- Focus sessions ----
  List<FocusSession> loadFocusSessions() {
    final raw = _prefs.getString(_kFocusSessions);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => FocusSession.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveFocusSessions(List<FocusSession> sessions) =>
      _prefs.setString(_kFocusSessions, jsonEncode(sessions.map((s) => s.toJson()).toList()));

  // ---- Settings ----
  String? get themeMode => _prefs.getString(_kThemeMode);
  Future<void> setThemeMode(String mode) => _prefs.setString(_kThemeMode, mode);

  bool get onboarded => _prefs.getBool(_kOnboarded) ?? false;
  Future<void> setOnboarded(bool v) => _prefs.setBool(_kOnboarded, v);

  bool get isPremium => _prefs.getBool(_kPremium) ?? false;
  Future<void> setPremium(bool v) => _prefs.setBool(_kPremium, v);

  bool get remindersEnabled => _prefs.getBool(_kRemindersEnabled) ?? true;
  Future<void> setRemindersEnabled(bool v) => _prefs.setBool(_kRemindersEnabled, v);

  String get userName => _prefs.getString(_kUserName) ?? '';
  Future<void> setUserName(String v) => _prefs.setString(_kUserName, v);

  String? get lastActiveDate => _prefs.getString(_kLastActiveDate);
  Future<void> setLastActiveDate(String v) => _prefs.setString(_kLastActiveDate, v);

  Future<void> wipeAll() async {
    await _prefs.remove(_kRoutines);
    await _prefs.remove(_kHabits);
    await _prefs.remove(_kFocusSessions);
    await _prefs.remove(_kPremium);
    await _prefs.remove(_kOnboarded);
  }
}
