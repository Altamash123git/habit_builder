import 'package:flutter/material.dart';

enum RoutineCategory { morning, evening, work, study, fitness, selfCare, custom }

extension RoutineCategoryX on RoutineCategory {
  String get label => switch (this) {
        RoutineCategory.morning => 'Morning',
        RoutineCategory.evening => 'Evening',
        RoutineCategory.work => 'Work',
        RoutineCategory.study => 'Study',
        RoutineCategory.fitness => 'Fitness',
        RoutineCategory.selfCare => 'Self-care',
        RoutineCategory.custom => 'Custom',
      };

  IconData get icon => switch (this) {
        RoutineCategory.morning => Icons.wb_sunny_rounded,
        RoutineCategory.evening => Icons.nights_stay_rounded,
        RoutineCategory.work => Icons.work_rounded,
        RoutineCategory.study => Icons.menu_book_rounded,
        RoutineCategory.fitness => Icons.fitness_center_rounded,
        RoutineCategory.selfCare => Icons.spa_rounded,
        RoutineCategory.custom => Icons.auto_awesome_rounded,
      };

  Color get color => switch (this) {
        RoutineCategory.morning => const Color(0xFFF5A623),
        RoutineCategory.evening => const Color(0xFF6C63FF),
        RoutineCategory.work => const Color(0xFF3B82F6),
        RoutineCategory.study => const Color(0xFF14B8A6),
        RoutineCategory.fitness => const Color(0xFFFF7A59),
        RoutineCategory.selfCare => const Color(0xFFEC4899),
        RoutineCategory.custom => const Color(0xFF9C63FF),
      };
}

class RoutineTask {
  final String id;
  String title;
  String? time; // e.g. "07:00"
  bool completedToday;

  RoutineTask({required this.id, required this.title, this.time, this.completedToday = false});

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'time': time, 'completedToday': completedToday};

  factory RoutineTask.fromJson(Map<String, dynamic> j) => RoutineTask(
        id: j['id'] as String,
        title: j['title'] as String,
        time: j['time'] as String?,
        completedToday: j['completedToday'] as bool? ?? false,
      );
}

class Routine {
  final String id;
  String title;
  RoutineCategory category;
  List<RoutineTask> tasks;
  List<int> activeDays; // 1=Mon .. 7=Sun
  bool archived;
  DateTime? lastCompletedDate; // date-only
  String? reminderTime; // 'HH:mm', 24h, local time — null means no reminder

  Routine({
    required this.id,
    required this.title,
    required this.category,
    required this.tasks,
    List<int>? activeDays,
    this.archived = false,
    this.lastCompletedDate,
    this.reminderTime,
  }) : activeDays = activeDays ?? const [1, 2, 3, 4, 5, 6, 7];

  int get completedCount => tasks.where((t) => t.completedToday).length;
  double get progress => tasks.isEmpty ? 0 : completedCount / tasks.length;
  bool get isDoneToday => tasks.isNotEmpty && completedCount == tasks.length;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category.name,
        'tasks': tasks.map((t) => t.toJson()).toList(),
        'activeDays': activeDays,
        'archived': archived,
        'lastCompletedDate': lastCompletedDate?.toIso8601String(),
        'reminderTime': reminderTime,
      };

  factory Routine.fromJson(Map<String, dynamic> j) => Routine(
        id: j['id'] as String,
        title: j['title'] as String,
        category: RoutineCategory.values.firstWhere((c) => c.name == j['category'], orElse: () => RoutineCategory.custom),
        tasks: (j['tasks'] as List).map((t) => RoutineTask.fromJson(t as Map<String, dynamic>)).toList(),
        activeDays: (j['activeDays'] as List?)?.map((e) => e as int).toList() ?? const [1, 2, 3, 4, 5, 6, 7],
        archived: j['archived'] as bool? ?? false,
        lastCompletedDate: j['lastCompletedDate'] != null ? DateTime.parse(j['lastCompletedDate'] as String) : null,
        reminderTime: j['reminderTime'] as String?,
      );
}
