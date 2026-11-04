import 'package:flutter/material.dart';
import 'package:sud_qollanma/shared/widgets/glass_card.dart';
import '../screens/ict_report_form_screen.dart';
import '../screens/my_ict_reports_screen.dart';

/// Bosh sahifada AKT xodimi uchun: muammo/yechim yuborish va holatini ko'rish.
class IctReportsDashboardCard extends StatelessWidget {
  const IctReportsDashboardCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      borderRadius: 14,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.build_circle_rounded, color: theme.colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Muammo va yechimlar',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Ishda duch kelgan muammo va yechimingizni adminga yuboring. '
            'Tasdiqlangani FAQ bo\'limida hamma uchun chiqadi.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const IctReportFormScreen()),
                  ),
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: const Text('Yuborish'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyIctReportsScreen()),
                  ),
                  child: const Text('Yuborganlarim'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
