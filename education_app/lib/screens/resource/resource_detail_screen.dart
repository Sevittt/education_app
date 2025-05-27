// lib/screens/resource_detail_screen.dart

import 'package:education_app/screens/resource/edit_resource_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/resource.dart';
import '../../models/auth_notifier.dart';
import '../../models/users.dart';
import '../../services/resource_service.dart'; // Import ResourceService
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ResourceDetailScreen extends StatelessWidget {
  final Resource resource;

  const ResourceDetailScreen({super.key, required this.resource});

  // --- NEW: Method to show confirmation dialog and handle deletion ---
  Future<void> _confirmDelete(
    BuildContext context,
    ResourceService resourceService,
    AppLocalizations? l10n,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n?.deleteResourceConfirmTitle ?? 'Confirm Deletion'),
          content: Text(
            l10n?.deleteResourceConfirmMessage ??
                'Are you sure you want to delete this resource? This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              child: Text(l10n?.cancelButtonText ?? 'Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(false); // User did not confirm
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(dialogContext).colorScheme.error,
              ),
              child: Text(l10n?.deleteButtonText ?? 'Delete'),
              onPressed: () {
                Navigator.of(dialogContext).pop(true); // User confirmed
              },
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await resourceService.deleteResource(resource.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n?.resourceDeletedSuccess ??
                    'Resource deleted successfully!',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(); // Go back to the previous screen
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n?.resourceDeletedError != null
                    ? l10n!.resourceDeletedError(e.toString())
                    : 'Error deleting resource: ${e.toString()}',
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    final UserRole? userRole = authNotifier.appUser?.role;
    final ResourceService resourceService =
        ResourceService(); // Instance of service

    return Scaffold(
      appBar: AppBar(
        title: Text(resource.title),
        actions: [
          // Edit Button (from previous step)
          if (userRole == UserRole.teacher || userRole == UserRole.admin)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: l10n?.editButtonTooltip ?? 'Edit Resource',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (context) => EditResourceScreen(
                          resource: resource,
                          resourceToEdit: resource,
                        ),
                  ),
                );
              },
            ),
          // --- NEW: Conditional Delete Button ---
          if (userRole == UserRole.teacher || userRole == UserRole.admin)
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              tooltip: l10n?.deleteButtonTooltip ?? 'Delete Resource',
              onPressed: () {
                _confirmDelete(context, resourceService, l10n);
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              resource.title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                Icon(
                  _getIconForResourceType(resource.type),
                  color: Theme.of(context).colorScheme.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  '${l10n?.resourceTypeLabel ?? 'Type'}: ${resource.type.name[0].toUpperCase() + resource.type.name.substring(1)}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(
              '${l10n?.authorLabel ?? 'Author'}: ${resource.author}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8.0),
            Text(
              '${l10n?.dateAddedLabel ?? 'Added'}: ${MaterialLocalizations.of(context).formatMediumDate(resource.createdAt)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (resource.url != null && resource.url!.isNotEmpty) ...[
              const SizedBox(height: 16.0),
              InkWell(
                onTap: () {
                  // TODO: Implement launching URL (e.g., using url_launcher package)
                  print('Attempting to launch URL: ${resource.url}');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${l10n?.launchingUrlMessage ?? 'Launching URL'}: ${resource.url}',
                      ),
                    ),
                  );
                },
                child: Text(
                  resource.url!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16.0),
            const Divider(),
            const SizedBox(height: 16.0),
            Text(
              l10n?.descriptionLabel ?? 'Description',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(
              resource.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForResourceType(ResourceType type) {
    switch (type) {
      case ResourceType.article:
        return Icons.article_outlined;
      case ResourceType.video:
        return Icons.play_circle_outline;
      case ResourceType.code:
        return Icons.code;
      case ResourceType.lessonPlan:
        return Icons.assignment_outlined;
      case ResourceType.tutorial:
        return Icons.school_outlined;
      case ResourceType.other:
        return Icons.topic_outlined;
    }
  }
}
