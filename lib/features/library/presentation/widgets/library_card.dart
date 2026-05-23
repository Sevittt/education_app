import 'package:flutter/material.dart';
import 'package:sud_qollanma/shared/widgets/custom_network_image.dart';

/// Reusable Library Card Widget.
/// 
/// Can display either a Video or an Article in a consistent style.
/// Uses CustomNetworkImage for optimized image loading.
class LibraryCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final String? badgeText;
  final IconData? badgeIcon;
  final VoidCallback? onTap;
  final Widget? trailing;

  const LibraryCard({
    super.key,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.badgeText,
    this.badgeIcon,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            SizedBox(
              height: 120,
              width: double.infinity,
              child: Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: Icon(
                  badgeIcon ?? Icons.article_rounded,
                  color: theme.colorScheme.primary.withValues(alpha: 0.5),
                  size: 48,
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (trailing != null)
                    trailing!,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
