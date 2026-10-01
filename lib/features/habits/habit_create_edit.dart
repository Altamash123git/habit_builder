import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/models/habit.dart';
import '../../core/services/templates.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/date_utils.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/misc_widgets.dart';

const _uuid = Uuid();

/// Create or edit a habit. This is the "real life habit builder": title,
/// visual identity, an optional note on *why* it matters, an optional
/// motivational line used in reminders, an optional day-count goal
/// ("build this in 21 days"), and reminder settings — including a
/// best-effort "you might miss this" evening nudge.



/// Ultra Premium Primary Gradient Definition


class HabitEditorScreen extends StatefulWidget {
  final Habit? existing;
  const HabitEditorScreen({super.key, this.existing});

  @override
  State<HabitEditorScreen> createState() => _HabitEditorScreenState();
}

class _HabitEditorScreenState extends State<HabitEditorScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _notesController;
  late final TextEditingController _motivationController;
  late final TextEditingController _customGoalController;
  late final TextEditingController _targetCountController;
  late final TextEditingController _unitController;

  IconData _icon = kHabitIconChoices.first;
  Color _color = AppColors.categoryAccents.first;
  int? _goalDays; // null = no deadline
  bool _customGoalSelected = false;
  TimeOfDay? _reminderTime;
  bool _missedReminderEnabled = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final h = widget.existing;
    _titleController = TextEditingController(text: h?.title ?? '');
    _notesController = TextEditingController(text: h?.notes ?? '');
    _motivationController = TextEditingController(text: h?.motivation ?? '');
    _targetCountController = TextEditingController(text: '${h?.targetCount ?? 1}');
    _unitController = TextEditingController(text: h?.unit ?? 'times');
    _icon = h?.icon ?? kHabitIconChoices.first;
    _color = h?.color ?? AppColors.categoryAccents.first;
    _goalDays = h?.goalDays;
    _customGoalSelected =
        h != null && h.goalDays != null && !kHabitGoalPresets.any((p) => p.days == h.goalDays);
    _customGoalController =
        TextEditingController(text: _customGoalSelected ? '${h!.goalDays}' : '');
    _reminderTime = AppDate.parseTimeOfDay(h?.reminderTime);
    _missedReminderEnabled = h?.missedReminderEnabled ?? false;

    // Listen to title changes to refresh live preview
    _titleController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _motivationController.dispose();
    _customGoalController.dispose();
    _targetCountController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Give your habit a name.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    int? goalDays = _goalDays;
    if (_customGoalSelected) {
      goalDays = int.tryParse(_customGoalController.text.trim());
      if (goalDays == null || goalDays <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Enter a valid number of days for your custom goal.'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        return;
      }
    }

    final state = context.read<AppState>();    final reminderTimeStr =
    _reminderTime == null ? null : AppDate.formatTimeOfDay(_reminderTime!);

    int targetCount = int.tryParse(_targetCountController.text.trim()) ?? 1;
    if (targetCount < 1) targetCount = 1;
    final unit = _unitController.text.trim().isEmpty ? 'times' : _unitController.text.trim();

    if (_isEditing) {
      final updated = widget.existing!;
      updated.title = title;
      updated.icon = _icon;
      updated.color = _color;
      updated.targetCount = targetCount;
      updated.unit = unit;
      updated.notes = _notesController.text.trim().isEmpty ? null : _notesController.text.trim();
      updated.motivation =
      _motivationController.text.trim().isEmpty ? null : _motivationController.text.trim();
      updated.goalDays = goalDays;
      updated.reminderTime = reminderTimeStr;
      updated.missedReminderEnabled = _missedReminderEnabled;
      await state.updateHabit(updated);
      if (mounted) Navigator.of(context).pop();
    } else {
      await state.addHabit(Habit(
        id: _uuid.v4(),
        title: title,
        icon: _icon,
        color: _color,
        targetCount: targetCount,
        unit: unit,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        motivation:
            _motivationController.text.trim().isEmpty ? null : _motivationController.text.trim(),
        goalDays: goalDays,
        reminderTime: reminderTimeStr,
        missedReminderEnabled: _missedReminderEnabled,
      ));
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleText = _titleController.text.trim();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _isEditing ? 'Edit Habit' : 'New Habit',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        children: [
          // Live Habit Card Preview
          _LiveHabitPreview(
            title: titleText.isEmpty ? 'Drink water' : titleText,
            icon: _icon,
            color: _color,
            goalDays: _customGoalSelected
                ? int.tryParse(_customGoalController.text.trim())
                : _goalDays,
          ),

          const SizedBox(height: 24),

          // Section: Habit Name
          _SectionHeader(
            icon: Icons.edit_note_rounded,
            title: 'Habit Name',
            color: AppColors.primary,
          ),
          const SizedBox(height: 10),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              controller: _titleController,
              autofocus: !_isEditing,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              decoration: const InputDecoration(
                hintText: 'e.g. Drink water, Read 20 mins...',
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Section: Daily Target & Unit (Counter Habit)
          _SectionHeader(
            icon: Icons.numbers_rounded,
            title: 'Daily Target & Unit',
            color: AppColors.primary,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: TextField(
                    controller: _targetCountController,
                    keyboardType: TextInputType.number,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                    decoration: const InputDecoration(
                      labelText: 'Target Count',
                      hintText: 'e.g. 8',
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: TextField(
                    controller: _unitController,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                    decoration: const InputDecoration(
                      labelText: 'Unit Name',
                      hintText: 'e.g. glasses, mins',
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Section: Icon Picker with Selection Preview
          _SectionHeader(
            icon: Icons.grid_view_rounded,
            title: 'Habit Icon',
            color: AppColors.primary,
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final i in kHabitIconChoices)
                  GestureDetector(
                    onTap: () => setState(() => _icon = i),
                    child: AnimatedContainer(
                      duration: AppDuration.fast,
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: _icon == i ? _color.withOpacity(0.18) : context.colors.card,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _icon == i ? _color : context.colors.border,
                          width: _icon == i ? 2.0 : 1.0,
                        ),
                      ),
                      child: Icon(
                        i,
                        size: 22,
                        color: _icon == i ? _color : context.colors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Section: Color Palette Picker
          _SectionHeader(
            icon: Icons.palette_outlined,
            title: 'Accent Color',
            color: AppColors.primary,
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final c in AppColors.categoryAccents)
                  GestureDetector(
                    onTap: () => setState(() => _color = c),
                    child: AnimatedContainer(
                      duration: AppDuration.fast,
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: _color == c
                            ? Border.all(color: context.colors.surface, width: 3)
                            : Border.all(color: Colors.transparent, width: 0),
                      ),
                      child: _color == c
                          ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                          : null,
                    ),
                  ),
              ],
            ),
          ),

              const SizedBox(height: 24),

              // Section: Motivation Statement
              _SectionHeader(
                icon: Icons.format_quote_rounded,
                title: 'Motivation (Optional)',
                color: _color,
              ),
              const SizedBox(height: 10),
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _motivationController,
                      maxLines: 2,
                      maxLength: 120,
                      style: Theme.of(context).textTheme.bodyMedium,
                      decoration: const InputDecoration(
                        hintText: 'e.g. "Future me deserves the energy this gives."',
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        counterStyle: TextStyle(fontSize: 11),
                      ),
                    ),
                    Text(
                      'Shown on the detail screen and in reminder notifications.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.colors.textSecondary,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Section: Notes
              _SectionHeader(
                icon: Icons.notes_rounded,
                title: 'Notes (Optional)',
                color: _color,
              ),
              const SizedBox(height: 10),
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _notesController,
                  maxLines: 3,
                  style: Theme.of(context).textTheme.bodyMedium,
                  decoration: const InputDecoration(
                    hintText: 'How exactly will you do this? Triggers, cues or specific plans.',
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Section: Goal Target Preset Chips
              _SectionHeader(
                icon: Icons.flag_outlined,
                title: 'Goal Target',
                color: _color,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final preset in kHabitGoalPresets)
                    _GoalChip(
                      label: preset.label,
                      selected: preset.days == -1
                          ? _customGoalSelected
                          : (!_customGoalSelected && _goalDays == preset.days),
                      color: _color,
                      onTap: () => setState(() {
                        if (preset.days == -1) {
                          _customGoalSelected = true;
                          _goalDays = null;
                        } else {
                          _customGoalSelected = false;
                          _goalDays = preset.days;
                        }
                      }),
                    ),
                ],
              ),
              if (_customGoalSelected) ...[
                const SizedBox(height: 12),
                AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: TextField(
                    controller: _customGoalController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Number of days',
                      suffixText: 'days',
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Section: Reminders & Evening Nudges
              _SectionHeader(
                icon: Icons.notifications_active_outlined,
                title: 'Daily Reminders',
                color: _color,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _reminderTime ?? const TimeOfDay(hour: 9, minute: 0),
                        );
                        if (picked != null) setState(() => _reminderTime = picked);
                      },
                      child: AppCard(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        child: Row(
                          children: [
                            Icon(
                              Icons.notifications_active_rounded,
                              size: 20,
                              color: _reminderTime != null ? _color : context.colors.textSecondary,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _reminderTime == null
                                  ? 'No daily reminder'
                                  : 'Remind at ${_reminderTime!.format(context)}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: context.colors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_reminderTime != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.close_rounded, color: AppColors.error, size: 20),
                        onPressed: () => setState(() => _reminderTime = null),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    Icon(
                      Icons.local_fire_department_rounded,
                      size: 20,
                      color: _missedReminderEnabled ? _color : context.colors.textSecondary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Remind me if I miss it',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: context.colors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Nudge around 9 PM if day is at risk',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: context.colors.textSecondary,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: _missedReminderEnabled,
                      activeColor: _color,
                      onChanged: (v) => setState(() => _missedReminderEnabled = v),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Action Button with Upgraded Gradient
              GradientButton(
                label: _isEditing ? 'Save Changes' : 'Create Habit',
                onTap: _save,
              ),
            ],
          ),
    );
  }
}

/// Live Card Preview Banner
class _LiveHabitPreview extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final int? goalDays;

  const _LiveHabitPreview({
    required this.title,
    required this.icon,
    required this.color,
    this.goalDays,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color.withOpacity(0.95),
          color,
          HSLColor.fromColor(color).withHue((HSLColor.fromColor(color).hue + 18) % 360).toColor(),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.22),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.35)),
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PREVIEW',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Colors.white.withOpacity(0.8),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                Text(
                  goalDays != null && goalDays! > 0
                      ? '$goalDays-day goal target'
                      : 'Ongoing habit • No deadline',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

class _GoalChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _GoalChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDuration.fast,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.16) : context.colors.card,
          border: Border.all(
            color: selected ? color : context.colors.border,
            width: selected ? 1.6 : 1.0,
          ),
          borderRadius: AppRadius.chip,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: selected ? color : context.colors.textPrimary,
          ),
        ),
      ),
    );
  }
}