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
            if (imageUrl != null && imageUrl!.isNotEmpty)
              SizedBox(
                height: 180,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CustomNetworkImage(
                      imageUrl: imageUrl!,
                      fit: BoxFit.cover,
                    ),
                    // Badge overlay (e.g., duration or category)
                    if (badgeText != null)
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (badgeIcon != null)
                                Icon(
                                  badgeIcon,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              if (badgeIcon != null)
                                const SizedBox(width: 4),
                              Text(
                                badgeText!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
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
