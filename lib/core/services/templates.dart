

import 'package:uuid/uuid.dart';
import '../models/routine.dart';
import '../models/habit.dart';
import '../theme/app_colors.dart';
import 'package:flutter/material.dart';

const _uuid = Uuid();

/// Routine templates offered during onboarding and from "+ New routine".
class RoutineTemplate {
  final String title;
  final RoutineCategory category;
  final List<String> tasks;
  const RoutineTemplate(this.title, this.category, this.tasks);
}

const List<RoutineTemplate> kRoutineTemplates = [
  RoutineTemplate('Morning Boost', RoutineCategory.morning, [
    'Drink a glass of water',
    'Stretch for 5 minutes',
    'Make the bed',
    'Plan top 3 priorities',
  ]),
  RoutineTemplate('Deep Work Block', RoutineCategory.work, [
    'Clear desk & close tabs',
    'Write session goal',
    '25-min focus sprint',
    'Log progress',
  ]),
  RoutineTemplate('Study Session', RoutineCategory.study, [
    'Review yesterday\'s notes',
    'Read / watch new material',
    'Active recall quiz',
    'Summarize in own words',
  ]),
  RoutineTemplate('Fitness Kickoff', RoutineCategory.fitness, [
    'Warm up 5 minutes',
    'Main workout',
    'Cool down & stretch',
    'Log workout',
  ]),
  RoutineTemplate('Evening Wind-down', RoutineCategory.evening, [
    'Tidy up living space',
    'Prep for tomorrow',
    'Screens off 30 min before bed',
    'Journal 3 lines',
  ]),
  RoutineTemplate('Self-Care Reset', RoutineCategory.selfCare, [
    'Skincare routine',
    '5-min breathing / meditation',
    'Gratitude note',
    'Herbal tea / hydrate',
  ]),
];

Routine buildRoutineFromTemplate(RoutineTemplate t) => Routine(
  id: _uuid.v4(),
  title: t.title,
  category: t.category,
  tasks: t.tasks.map((title) => RoutineTask(id: _uuid.v4(), title: title)).toList(),
);

List<Habit> defaultStarterHabits() => [
  Habit(
    id: _uuid.v4(),
    title: 'Drink water',
    icon: Icons.water_drop_rounded,
    color: AppColors.waterBlue,
    targetCount: 8,
    unit: 'glasses',
    motivation: 'Log each glass of water as you drink throughout the day.',
    goalDays: 21,
  ),
  Habit(
    id: _uuid.v4(),
    title: 'Read 10 minutes',
    icon: Icons.menu_book_rounded,
    color: const Color(0xFF10B981),
    targetCount: 10,
    unit: 'mins',
    motivation: '10 minutes a day compounds into dozens of books a year.',
    goalDays: 30,
  ),
  Habit(
    id: _uuid.v4(),
    title: 'Move / exercise',
    icon: Icons.directions_run_rounded,
    color: const Color(0xFFF59E0B),
    targetCount: 1,
    unit: 'times',
    motivation: 'You never regret a workout — future you says thanks.',
    goalDays: 21,
  ),
];

/// Icon choices offered in the habit editor.
const List<IconData> kHabitIconChoices = [
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
];

/// Preset "build this habit in N days" options for the goal picker.
/// A null [days] represents the custom / no-deadline choice, handled by the UI.
class HabitGoalPreset {
  final String label;
  final int? days;
  const HabitGoalPreset(this.label, this.days);
}

const List<HabitGoalPreset> kHabitGoalPresets = [
  HabitGoalPreset('7 days', 7),
  HabitGoalPreset('21 days', 21),
  HabitGoalPreset('30 days', 30),
  HabitGoalPreset('66 days', 66),
  HabitGoalPreset('Custom', -1), // sentinel: UI swaps this for a number field
  HabitGoalPreset('No deadline', null),
];

