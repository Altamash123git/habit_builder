import 'package:cadence/core/models/routine.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/templates.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/misc_widgets.dart';
import '../shell/root_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;
  final _nameController = TextEditingController();
  RoutineTemplate? _selectedTemplate;

  static const _slides = [
    (
      icon: Icons.self_improvement_rounded,
      title: 'Build a rhythm that sticks',
      subtitle: 'Plan morning, evening, work, study, fitness & self-care routines in one calm place.',
      gradient: AppGradients.primary,
    ),
    (
      icon: Icons.local_fire_department_rounded,
      title: 'Habits that grow with you',
      subtitle: 'Check off habits daily, watch streaks build, and celebrate real progress — no shame, ever.',
      gradient: AppGradients.streak,
    ),
    (
      icon: Icons.timer_rounded,
      title: 'Focus, distraction-free',
      subtitle: 'Run Pomodoro focus sessions with a quiet, ad-free timer built for deep work.',
      gradient: AppGradients.focus,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _slides.length) {
      _controller.nextPage(duration: AppDuration.slow, curve: AppDuration.curve);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = _slides.length + 1; // + setup page
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            _Dots(count: totalPages, index: _page),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  for (final s in _slides) _Slide(icon: s.icon, title: s.title, subtitle: s.subtitle, gradient: s.gradient),
                  _SetupSlide(
                    nameController: _nameController,
                    selectedTemplate: _selectedTemplate,
                    onTemplateSelected: (t) => setState(() => _selectedTemplate = t),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: GradientButton(
                label: _page == totalPages - 1 ? 'Start my rhythm' : 'Continue',
                onTap: () async {
                  if (_page == totalPages - 1) {
                    final state = context.read<AppState>();
                    final name = _nameController.text.trim().isEmpty ? 'there' : _nameController.text.trim();
                    await state.completeOnboarding(name: name, starterTemplate: _selectedTemplate);
                    if (context.mounted) {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const RootShell()));
                    }
                  } else {
                    _next();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  final int count;
  final int index;
  const _Dots({required this.count, required this.index});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: AppDuration.base,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 22 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : context.colors.border,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _Slide extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient gradient;
  const _Slide({required this.icon, required this.title, required this.subtitle, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1),
            duration: AppDuration.slow,
            curve: AppDuration.bounce,
            builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(gradient: gradient, shape: BoxShape.circle, boxShadow: AppShadows.card(context)),
              child: Icon(icon, color: Colors.white, size: 60),
            ),
          ),
          const SizedBox(height: 40),
          Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: 14),
          Text(subtitle, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _SetupSlide extends StatelessWidget {
  final TextEditingController nameController;
  final RoutineTemplate? selectedTemplate;
  final ValueChanged<RoutineTemplate?> onTemplateSelected;

  const _SetupSlide({required this.nameController, required this.selectedTemplate, required this.onTemplateSelected});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('A couple of quick things', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 6),
          Text('No account needed — this just personalizes your dashboard.', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          Text('What should we call you?', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          TextField(controller: nameController, decoration: const InputDecoration(hintText: 'Your name')),
          const SizedBox(height: 26),
          Text('Pick a starter routine (optional)', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final t in kRoutineTemplates)
                _TemplateChip(
                  template: t,
                  selected: selectedTemplate?.title == t.title,
                  onTap: () => onTemplateSelected(selectedTemplate?.title == t.title ? null : t),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TemplateChip extends StatelessWidget {
  final RoutineTemplate template;
  final bool selected;
  final VoidCallback onTap;
  const _TemplateChip({required this.template, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDuration.fast,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? template.category.color.withOpacity(0.14) : context.colors.card,
          border: Border.all(color: selected ? template.category.color : context.colors.border, width: selected ? 1.6 : 1),
          borderRadius: AppRadius.chip,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(template.category.icon, size: 16, color: template.category.color),
            const SizedBox(width: 6),
            Text(template.title, style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
      ),
    );
  }
}
