import 'package:flutter/material.dart';
import 'package:sud_qollanma/shared/widgets/custom_network_image.dart';

class UserAvatar extends StatelessWidget {
  final String? profilePictureUrl;
  final double radius;
  final bool isEditMode;
  final VoidCallback? onEditTap;
  final Color? backgroundColor;

  /// Shows the user's avatar intelligently depending on whether the image is 
  /// a network URL or a predefined local asset avatar.
  const UserAvatar({
    super.key,
    required this.profilePictureUrl,
    this.radius = 24.0,
    this.isEditMode = false,
    this.onEditTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget avatarContent;

    if (profilePictureUrl?.isNotEmpty == true) {
      if (profilePictureUrl!.startsWith('assets/')) {
        // Render from presets 🧩
        avatarContent = CircleAvatar(
          radius: radius,
          backgroundColor: backgroundColor ?? Colors.white24,
          backgroundImage: AssetImage(profilePictureUrl!),
        );
      } else {
        // Render from Network using reliable CustomNetworkImage 🌐
      avatarContent = CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? theme.colorScheme.surfaceContainerHighest,
        child: Icon(Icons.person, size: radius * 1.2, color: theme.colorScheme.onSurfaceVariant),
      );
      }
    } else {
      // Missing photo fallback 🫥
      avatarContent = CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? theme.colorScheme.surfaceContainerHighest,
        child: Icon(Icons.person, size: radius * 1.2, color: theme.colorScheme.onSurfaceVariant),
      );
    }

    if (isEditMode) {
      return Stack(
        alignment: Alignment.bottomRight,
        children: [
          avatarContent,
          if (onEditTap != null)
            GestureDetector(
              onTap: onEditTap,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.colorScheme.surface, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
        ],
      );
    }

    return avatarContent;
  }
}
