import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../shared/widgets/misc_widgets.dart';

const _perks = [
  'Unlimited routines & habits',
  'All premium routine templates',
  'Advanced habit insights & analytics',
  'Focus session reports',
  'Advanced calendar views',
  'PDF / CSV export',
  'Premium themes',
  'No ads, ever',
];

Future<void> showPremiumSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _PremiumSheet(),
  );
}

class _PremiumSheet extends StatefulWidget {
  const _PremiumSheet();

  @override
  State<_PremiumSheet> createState() => _PremiumSheetState();
}

class _PremiumSheetState extends State<_PremiumSheet> {
  int _plan = 1; // 0 monthly, 1 yearly, 2 lifetime

  static const _plans = [
    (title: 'Monthly', price: '\$1.99', sub: 'per month'),
    (title: 'Yearly', price: '\$11.99', sub: 'per year · best value'),
    (title: 'Lifetime', price: '\$29.99', sub: 'one-time'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
      decoration: BoxDecoration(color: context.colors.surface, borderRadius: AppRadius.sheetBorder),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(gradient: AppGradients.premium, shape: BoxShape.circle),
              child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 26),
            ),
            const SizedBox(height: 16),
            Text('Habit Tracker Premium', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('One purchase removes ads and unlocks everything.', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 18),
            for (final p in _perks)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 18),
                    const SizedBox(width: 10),
                    Text(p, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.colors.textPrimary)),
                  ],
                ),
              ),
            const SizedBox(height: 14),
            Row(
              children: List.generate(_plans.length, (i) {
                final p = _plans[i];
                final selected = _plan == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _plan = i),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary.withOpacity(0.12) : context.colors.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: selected ? AppColors.primary : context.colors.border, width: selected ? 1.6 : 1),
                      ),
                      child: Column(
                        children: [
                          Text(p.title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, color: selected ? AppColors.primary : context.colors.textPrimary)),
                          const SizedBox(height: 4),
                          Text(p.price, style: Theme.of(context).textTheme.titleMedium),
                          Text(p.sub, textAlign: TextAlign.center, style: TextStyle(fontSize: 9.5, color: context.colors.textSecondary)),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            GradientButton(
              label: 'Continue',
              gradient: AppGradients.premium,
              onTap: () async {
                // TODO: wire to `in_app_purchase` — see README §Monetization.
                await context.read<AppState>().setPremium(true);
                if (context.mounted) Navigator.pop(context);
              },
            ),
            const SizedBox(height: 10),
            Center(
              child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Not now')),
            ),
          ],
        ),
      ),
    );
  }
}
