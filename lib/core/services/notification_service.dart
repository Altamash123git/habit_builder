

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Wraps flutter_local_notifications for the whole app. Handles:
///  - one-off "session complete" notifications (focus timer)
///  - recurring daily reminders (habits, and a default evening nudge)
///  - recurring weekly reminders on specific weekdays (routines, since a
///    routine can be active on a subset of days)
///  - a best-effort "you haven't checked this off yet" evening nudge per habit
///
/// ID scheme — every category gets its own numeric block so ids derived
/// from different string ids (habit vs routine) can never collide:
///   - habit reminder:        1,000,000 + (habitId.hashCode.abs() % 100000)
///   - habit missed reminder: 2,000,000 + (habitId.hashCode.abs() % 100000)
///   - routine reminder/day:  3,000,000 + (routineId.hashCode.abs() % 100000) * 10 + weekday(1..7)
///   - evening nudge:         9,999,999 (fixed)
///   - focus complete:        9,999,998 (fixed, one-off, not scheduled)
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const int eveningNudgeId = 9999999;
  static const int focusCompleteId = 9999998;

  static const int _habitBlock = 1000000;
  static const int _habitMissedBlock = 2000000;
  static const int _routineBlock = 3000000;

  Future<void> init() async {
    if (_ready) return;
    tz_data.initializeTimeZones();
    try {
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
    } catch (_) {
      // Falls back to UTC if the platform timezone lookup fails — reminders
      // will still fire, just anchored to UTC until this succeeds.
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false, // we ask explicitly via requestPermissions()
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );
    _ready = true;
  }

  /// Call after onboarding (or from a settings toggle) — asks for the
  /// runtime notification permission on Android 13+ and iOS.
  Future<bool> requestPermissions() async {
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final iosImpl = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

    final androidGranted = await androidImpl?.requestNotificationsPermission();
    final iosGranted = await iosImpl?.requestPermissions(alert: true, badge: true, sound: true);

    return (androidGranted ?? true) && (iosGranted ?? true);
  }

  NotificationDetails get _defaultDetails => const NotificationDetails(
    android: AndroidNotificationDetails(
      'cadence_reminders',
      'Habit Tracker Reminders',
      channelDescription: 'Routine, habit, and focus reminders from Habit Tracker',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
  );

  int _habitId(String habitId) => _habitBlock + (habitId.hashCode.abs() % 100000);
  int _habitMissedId(String habitId) => _habitMissedBlock + (habitId.hashCode.abs() % 100000);
  int _routineBaseId(String routineId) => _routineBlock + (routineId.hashCode.abs() % 100000) * 10;

  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute);
    if (scheduled.isBefore(now)) scheduled = scheduled.add(const Duration(days: 1));
    return scheduled;
  }

  tz.TZDateTime _nextInstanceOfWeekdayTime(int weekday, TimeOfDay time) {
    var scheduled = _nextInstanceOfTime(time);
    while (scheduled.weekday != weekday) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  /// Schedules (or reschedules) a daily-repeating reminder for a habit.
  Future<void> scheduleHabitReminder({
    required String habitId,
    required String habitTitle,
    required TimeOfDay time,
    String? motivation,
  }) async {
    if (!_ready) await init();
    final id = _habitId(habitId);
    final body = (motivation != null && motivation.trim().isNotEmpty) ? motivation.trim() : 'Time for "$habitTitle" — keep the streak alive 🔥';
    final targetTime = _nextInstanceOfTime(time);

    try {
      await _plugin.zonedSchedule(
        id,
        habitTitle,
        body,
        targetTime,
        _defaultDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {
      await _plugin.zonedSchedule(
        id,
        habitTitle,
        body,
        targetTime,
        _defaultDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  Future<void> cancelHabitReminder(String habitId) => (_ready ? Future.value() : init()).then((_) => _plugin.cancel(_habitId(habitId)));

  /// Best-effort evening nudge for a single habit.
  Future<void> scheduleHabitMissedReminder({
    required String habitId,
    required String habitTitle,
    TimeOfDay time = const TimeOfDay(hour: 21, minute: 0),
  }) async {
    if (!_ready) await init();
    final targetTime = _nextInstanceOfTime(time);
    const title = 'Don\'t break the streak';
    final body = 'Still time to check off "$habitTitle" before the day ends.';
    final id = _habitMissedId(habitId);

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        targetTime,
        _defaultDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        targetTime,
        _defaultDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  Future<void> cancelHabitMissedReminder(String habitId) =>
      (_ready ? Future.value() : init()).then((_) => _plugin.cancel(_habitMissedId(habitId)));

  /// Schedules one weekly-repeating reminder per active weekday for a routine.
  Future<void> scheduleRoutineReminder({
    required String routineId,
    required String routineTitle,
    required TimeOfDay time,
    required List<int> activeDays,
  }) async {
    if (!_ready) await init();
    final base = _routineBaseId(routineId);
    for (var weekday = 1; weekday <= 7; weekday++) {
      await _plugin.cancel(base + weekday);
    }
    for (final weekday in activeDays) {
      final targetTime = _nextInstanceOfWeekdayTime(weekday, time);
      try {
        await _plugin.zonedSchedule(
          base + weekday,
          'Routine reminder',
          'It\'s time for "$routineTitle"',
          targetTime,
          _defaultDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      } catch (_) {
        await _plugin.zonedSchedule(
          base + weekday,
          'Routine reminder',
          'It\'s time for "$routineTitle"',
          targetTime,
          _defaultDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
    }
  }

  Future<void> cancelRoutineReminder(String routineId) async {
    if (!_ready) await init();
    final base = _routineBaseId(routineId);
    for (var weekday = 1; weekday <= 7; weekday++) {
      await _plugin.cancel(base + weekday);
    }
  }

  /// A single default end-of-day nudge, on by default after onboarding,
  /// toggleable from Settings. Reminds the person to close out open items.
  Future<void> scheduleEveningNudge({TimeOfDay time = const TimeOfDay(hour: 20, minute: 0)}) async {
    if (!_ready) await init();
    await _plugin.zonedSchedule(
      eveningNudgeId,
      'How did today go?',
      'Take a minute to check off anything left on your routines and habits.',
      _nextInstanceOfTime(time),
      _defaultDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelEveningNudge() => (_ready ? Future.value() : init()).then((_) => _plugin.cancel(eveningNudgeId));

  /// One-off immediate notification, used when a focus session finishes.
  Future<void> showFocusSessionComplete({required String modeLabel, required int minutes}) async {
    if (!_ready) await init();
    await _plugin.show(
      focusCompleteId,
      '$modeLabel complete',
      minutes > 0 ? 'Nice work — you focused for $minutes minutes.' : 'Break\'s over. Ready for another round?',
      _defaultDetails,
    );
  }

  /// Instant test notification for Settings verification.
  Future<bool> sendTestNotification() async {
    if (!_ready) await init();
    final granted = await requestPermissions();
    if (!granted) return false;
    await _plugin.show(
      8888888,
      '🔔 Notifications Active',
      'Cadence reminders & focus session alerts are configured successfully!',
      _defaultDetails,
    );
    return true;
  }

  Future<void> cancelAll() async {
    if (!_ready) await init();
    await _plugin.cancelAll();
  }
}

