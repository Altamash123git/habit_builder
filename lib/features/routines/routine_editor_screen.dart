import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/models/routine.dart';
import '../../core/services/templates.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/date_utils.dart';
import '../../shared/widgets/misc_widgets.dart';

const _uuid = Uuid();
const _weekdayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

class RoutineEditorScreen extends StatefulWidget {
  final Routine? existing;
  const RoutineEditorScreen({super.key, this.existing});

  @override
  State<RoutineEditorScreen> createState() => _RoutineEditorScreenState();
}

class _RoutineEditorScreenState extends State<RoutineEditorScreen> {
  late final TextEditingController _titleController;
  late RoutineCategory _category;
  late List<RoutineTask> _tasks;
  late List<int> _activeDays;
  TimeOfDay? _reminderTime;
  final _newTaskController = TextEditingController();

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existing?.title ?? '');
    _category = widget.existing?.category ?? RoutineCategory.morning;
    _tasks = widget.existing?.tasks.map((t) => RoutineTask(id: t.id, title: t.title, time: t.time)).toList() ?? [];
    _activeDays = List.of(widget.existing?.activeDays ?? const [1, 2, 3, 4, 5, 6, 7]);
    _reminderTime = AppDate.parseTimeOfDay(widget.existing?.reminderTime);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _newTaskController.dispose();
    super.dispose();
  }

  void _applyTemplate(RoutineTemplate t) {
    setState(() {
      _titleController.text = t.title;
      _category = t.category;
      _tasks = t.tasks.map((title) => RoutineTask(id: _uuid.v4(), title: title)).toList();
    });
  }

  void _addTask() {
    final text = _newTaskController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _tasks.add(RoutineTask(id: _uuid.v4(), title: text));
      _newTaskController.clear();
    });
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty || _tasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add a title and at least one task.')));
      return;
    }
    final state = context.read<AppState>();
    if (_isEditing) {
      final updated = widget.existing!;
      updated.title = title;
      updated.category = _category;
      updated.tasks = _tasks;
      updated.activeDays = _activeDays;
      updated.reminderTime = _reminderTime == null ? null : AppDate.formatTimeOfDay(_reminderTime!);
      await state.updateRoutine(updated);
    } else {
      await state.addRoutine(Routine(
        id: _uuid.v4(),
        title: title,
        category: _category,
        tasks: _tasks,
        activeDays: _activeDays,
        reminderTime: _reminderTime == null ? null : AppDate.formatTimeOfDay(_reminderTime!),
      ));
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_isEditing ? 'Edit Routine' : 'New Routine'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        children: [
          if (!_isEditing) ...[
            Text('Start from a template', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: kRoutineTemplates.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final t = kRoutineTemplates[i];
                  return GestureDetector(
                    onTap: () => _applyTemplate(t),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: t.category.color.withOpacity(0.12),
                        borderRadius: AppRadius.chip,
                        border: Border.all(color: t.category.color.withOpacity(0.3)),
                      ),
                      child: Text(
                        t.title,
                        style: TextStyle(color: t.category.color, fontWeight: FontWeight.w700, fontSize: 12.5),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 22),
          ],
          Text('Title', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _titleController,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            decoration: const InputDecoration(hintText: 'e.g. Morning Boost'),
          ),
          const SizedBox(height: 22),
          Text('Category', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final c in RoutineCategory.values)
                GestureDetector(
                  onTap: () => setState(() => _category = c),
                  child: AnimatedContainer(
                    duration: AppDuration.fast,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(
                      color: _category == c ? c.color.withOpacity(0.16) : context.colors.card,
                      border: Border.all(color: _category == c ? c.color : context.colors.border),
                      borderRadius: AppRadius.chip,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(c.icon, size: 15, color: c.color),
                        const SizedBox(width: 6),
                        Text(c.label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: _category == c ? c.color : context.colors.textPrimary)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 22),
          Text('Active days', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            children: List.generate(7, (i) {
              final day = i + 1;
              final active = _activeDays.contains(day);
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => active ? _activeDays.remove(day) : _activeDays.add(day)),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary : context.colors.card,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: active ? AppColors.primary : context.colors.border),
                    ),
                    child: Text(
                      _weekdayLabels[i],
                      style: TextStyle(color: active ? Colors.white : context.colors.textSecondary, fontWeight: FontWeight.w800, fontSize: 12),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 22),
          Text('Reminder', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final picked = await showTimePicker(context: context, initialTime: _reminderTime ?? const TimeOfDay(hour: 7, minute: 0));
                    if (picked != null) setState(() => _reminderTime = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                    decoration: BoxDecoration(
                      color: context.colors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.colors.border),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.notifications_active_rounded, size: 18, color: _reminderTime != null ? AppColors.primary : context.colors.textSecondary),
                        const SizedBox(width: 10),
                        Text(
                          _reminderTime == null ? 'No reminder' : 'Remind me at ${_reminderTime!.format(context)}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.colors.textPrimary, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_reminderTime != null)
                IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => setState(() => _reminderTime = null)),
            ],
          ),
          const SizedBox(height: 22),
          Text('Tasks', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          for (final t in _tasks)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: context.colors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.colors.border),
                ),
                child: Row(
                  children: [
                    Expanded(child: Text(t.title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.colors.textPrimary, fontWeight: FontWeight.w500))),
                    IconButton(icon: const Icon(Icons.close_rounded, size: 18), onPressed: () => setState(() => _tasks.remove(t))),
                  ],
                ),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newTaskController,
                  decoration: const InputDecoration(hintText: 'Add a task'),
                  onSubmitted: (_) => _addTask(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(onPressed: _addTask, icon: const Icon(Icons.add_rounded,color: Colors.white,)),
            ],
          ),
          const SizedBox(height: 30),
          GradientButton(label: _isEditing ? 'Save Changes' : 'Create Routine', onTap: _save),
        ],
      ),
    );
  }
}
