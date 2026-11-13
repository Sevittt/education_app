// lib/features/community/presentation/widgets/discussion_topic_card.dart
import 'package:flutter/material.dart';
import 'package:sud_qollanma/core/theme/app_tokens.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import 'package:sud_qollanma/shared/widgets/design_system.dart';
import '../../domain/entities/discussion_topic.dart';

class DiscussionTopicCard extends StatelessWidget {
  final DiscussionTopic topic;
  final bool canModify;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const DiscussionTopicCard({
    super.key,
    required this.topic,
    required this.canModify,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    final String authorInitial = topic.authorName.isNotEmpty
        ? topic.authorName[0].toUpperCase()
        : '?';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(AppSpace.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              topic.title,
              style: textTheme.titleMedium?.copyWith(color: t.textPrimary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpace.s12),
            Row(
              children: [
                CircleAvatar(
                  radius: 13,
                  backgroundColor: t.brandContainer,
                  child: Text(
                    authorInitial,
                    style: textTheme.labelSmall?.copyWith(
                      color: t.brandOnContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpace.s8),
                Expanded(
                  child: Text(
                    topic.authorName,
                    style: textTheme.bodySmall?.copyWith(color: t.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 14,
                  color: t.textSecondary,
                ),
                const SizedBox(width: 4.0),
                Text(
                  '${topic.commentCount} ${topic.commentCount == 1 ? (l10n?.commentSingular ?? 'izoh') : (l10n?.commentPlural ?? 'izoh')}',
                  style: textTheme.bodySmall?.copyWith(color: t.textSecondary),
                ),
                if (canModify) ...[
                  const SizedBox(width: AppSpace.s8),
                  IconButton(
                    icon: Icon(Icons.edit_outlined, size: 18, color: t.brandPrimary),
                    onPressed: onEdit,
                    visualDensity: VisualDensity.compact,
                    tooltip: l10n?.editTopicTooltip ?? 'Tahrirlash',
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline_rounded, size: 18, color: t.dangerSolid),
                    onPressed: onDelete,
                    visualDensity: VisualDensity.compact,
                    tooltip: l10n?.deleteTopicTooltip ?? 'Oʻchirish',
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
