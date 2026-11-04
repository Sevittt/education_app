import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/ict_report.dart';

/// Yozuvning qisqa ko'rinishi: muammo, tizim, sana va holat.
class IctReportCard extends StatelessWidget {
  final IctReport report;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showAuthor;

  const IctReportCard({
    super.key,
    required this.report,
    this.onTap,
    this.trailing,
    this.showAuthor = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final meta = [
      if (showAuthor) report.authorName,
      if (showAuthor && report.courtName != null) report.courtName!,
      if (report.systemName != null) report.systemName!,
      if (report.createdAt != null)
        DateFormat('dd.MM.yyyy').format(report.createdAt!),
    ].join(' · ');

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      report.problem,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
              if (meta.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(meta, style: theme.textTheme.bodySmall),
              ],
              const SizedBox(height: 10),
              IctStatusChip(status: report.status),
              if (report.status == IctReportStatus.rejected &&
                  (report.adminComment?.isNotEmpty ?? false)) ...[
                const SizedBox(height: 8),
                Text(
                  'Admin izohi: ${report.adminComment}',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class IctStatusChip extends StatelessWidget {
  final IctReportStatus status;

  const IctStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (Color color, IconData icon) = switch (status) {
      IctReportStatus.pending => (scheme.tertiary, Icons.hourglass_top_rounded),
      IctReportStatus.approved => (Colors.green.shade600, Icons.check_circle_rounded),
      IctReportStatus.rejected => (scheme.error, Icons.cancel_rounded),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
