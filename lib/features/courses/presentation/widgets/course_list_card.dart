import 'package:flutter/material.dart';
import 'package:sud_qollanma/core/theme/app_tokens.dart';
import 'package:sud_qollanma/features/courses/domain/entities/course_entity.dart';
import 'package:sud_qollanma/features/courses/domain/entities/user_course_progress_entity.dart';
import 'package:sud_qollanma/features/courses/presentation/widgets/course_visuals.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import 'package:sud_qollanma/shared/widgets/design_system.dart';

/// Figma "Kurs kartasi": ikonka, qiyinlik/sertifikat belgilari, sarlavha, meta va
/// holatga qarab pastki qism (Boshlash / progress / Tugallangan).
class CourseListCard extends StatelessWidget {
  final CourseEntity course;
  final UserCourseProgressEntity? progress;
  final VoidCallback? onTap;

  const CourseListCard({super.key, required this.course, this.progress, this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final p = progress;
    final done = p?.isCompleted ?? false;

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconTile(courseIcon(course), size: 48, background: t.brandContainer, foreground: t.brandPrimary),
              const SizedBox(width: AppSpace.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(spacing: 6, runSpacing: 6, children: [
                      StatusBadge(difficultyLabel(l10n, course.difficulty)),
                      if (course.hasCertificate)
                        StatusBadge(l10n.dsCertificate, tone: BadgeTone.gold, icon: Icons.workspace_premium_outlined),
                    ]),
                    const SizedBox(height: 6),
                    Text(course.title, style: text.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.s12),
          Wrap(spacing: AppSpace.s12, runSpacing: 4, children: [
            _Meta(Icons.layers_outlined, l10n.dsModules(course.modules.length)),
            _Meta(Icons.schedule_rounded, formatDuration(l10n, course.estimatedMinutes)),
            _Meta(Icons.play_arrow_rounded, l10n.dsLessons(course.totalLessonsCount)),
          ]),
          const SizedBox(height: AppSpace.s12),
          if (done)
            Row(children: [
              StatusBadge(l10n.dsCompleted, tone: BadgeTone.success, icon: Icons.check_rounded),
              const Spacer(),
              if (course.hasCertificate) ...[
                Icon(Icons.download_rounded, size: 16, color: t.goldInk),
                const SizedBox(width: 4),
                Text(l10n.dsCertificate, style: text.titleSmall?.copyWith(color: t.goldInk)),
              ],
            ])
          else if (p != null)
            Row(children: [
              Expanded(child: ProgressLine(value: p.percentComplete)),
              const SizedBox(width: AppSpace.s12),
              Text('${(p.percentComplete * 100).round()}%', style: text.titleSmall?.copyWith(color: t.brandPrimary)),
            ])
          else
            Row(children: [
              Text(l10n.dsUpToXp(courseXp(course)), style: text.labelMedium?.copyWith(color: t.textTertiary)),
              const Spacer(),
              Text(l10n.dsStart, style: text.titleSmall?.copyWith(color: t.brandPrimary)),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward_rounded, size: 16, color: t.brandPrimary),
            ]),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Meta(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: t.textTertiary),
      const SizedBox(width: 4),
      Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: t.textSecondary)),
    ]);
  }
}
