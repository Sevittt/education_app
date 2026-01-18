// lib/screens/admin/admin_resource_management_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';

import 'package:sud_qollanma/features/library/domain/entities/resource_entity.dart';
import 'package:sud_qollanma/features/library/presentation/providers/library_provider.dart';
import 'package:sud_qollanma/features/library/presentation/screens/edit_resource_screen.dart';
import 'package:sud_qollanma/features/library/presentation/screens/resource_detail_screen.dart';

class AdminResourceManagementScreen extends StatefulWidget {
  const AdminResourceManagementScreen({super.key});

  @override
  State<AdminResourceManagementScreen> createState() =>
      _AdminResourceManagementScreenState();
}

class _AdminResourceManagementScreenState
    extends State<AdminResourceManagementScreen> {
  Future<void> _deleteResource(
    BuildContext context,
    ResourceEntity resource,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.confirmDeleteTitle),
          content: Text(
            l10n.confirmDeleteResourceMessage(resource.title),
          ), // "Are you sure you want to delete resource '{resourceTitle}'?"
          actions: <Widget>[
            TextButton(
              child: Text(l10n.cancelButtonText),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(dialogContext).colorScheme.error,
              ),
              child: Text(l10n.deleteButtonText),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      try {
        await context.read<LibraryProvider>().deleteResource(resource.id);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.resourceDeletedSuccess(resource.title),
            ), // "'{resourceTitle}' deleted successfully."
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.failedToDeleteResource(resource.title, e.toString()),
            ), // "Failed to delete '{resourceTitle}': {error}"
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  IconData _getIconForResourceType(ResourceType type) {
    switch (type) {
      case ResourceType.eSud:
        return Icons.computer_outlined;
      case ResourceType.adolat:
        return Icons.gavel_outlined;
      case ResourceType.jibSud:
        return Icons.folder_copy_outlined;
      case ResourceType.edoSud:
        return Icons.cloud_upload_outlined;
      case ResourceType.other:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    // Load resources if empty
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<LibraryProvider>().resources.isEmpty) {
        context.read<LibraryProvider>().watchResources();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.manageResourcesTitle),
        centerTitle: true,
      ),
      body: Consumer<LibraryProvider>(
        builder: (context, libraryProvider, child) {
          final resources = libraryProvider.resources;
          final isLoading = libraryProvider.isLoading;
          final error = libraryProvider.error;

          if (isLoading && resources.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (error != null) {
            return Center(
              child: Text(
                l10n.errorLoadingResources(error),
              ),
            );
          }
          if (resources.isEmpty) {
            return Center(
              child: Text(l10n.noResourcesFoundManager),
            );
          }

          // Return ListView directly (no StreamBuilder needed)
          return ListView.separated(
            padding: const EdgeInsets.all(8.0),
            itemCount: resources.length,
            itemBuilder: (context, index) {
              final resource = resources[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: Icon(
                    _getIconForResourceType(resource.type),
                    size: 30,
                    color: colorScheme.primary,
                  ),
                  title: Text(
                    resource.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${l10n.authorLabel}: ${resource.author}',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '${l10n.dateAddedLabel}: ${DateFormat.yMMMd(l10n.localeName).format(resource.createdAt)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.edit_outlined,
                          color: colorScheme.primary,
                        ),
                        tooltip: l10n.editResourceTooltip,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => EditResourceScreen(
                                    resourceToEdit: resource,
                                  ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: colorScheme.error,
                        ),
                        tooltip: l10n.deleteResourceTooltip,
                        onPressed:
                            () => _deleteResource(
                              context,
                              resource,
                            ),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  onTap: () {
                    // Allow admin to view details too
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                ResourceDetailScreen(resource: resource),
                      ),
                    );
                  },
                ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 4),
          );
        },
      ),
    );
  }
}


// Add these localization keys to your .arb files:
// "confirmDeleteResourceMessage": "Are you sure you want to delete resource \"{resourceTitle}\"?",
// "resourceDeletedSuccess": "Resource \"{resourceTitle}\" deleted successfully.",
// "failedToDeleteResource": "Failed to delete resource \"{resourceTitle}\": {error}",
// "errorLoadingResources": "Error loading resources: {error}",
// "noResourcesFoundManager": "No resources found in the system.",
// "editResourceTooltip": "Edit Resource",
// "deleteResourceTooltip": "Delete Resource"
// (You might already have "manageResourcesTitle", "authorLabel", "dateAddedLabel" etc.)
