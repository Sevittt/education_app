// lib/screens/admin/admin_resource_management_screen.dart
//import 'package:education_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:sud_qollanma/l10n/app_localizations.dart';

import '../../models/resource.dart';
import '../../services/resource_service.dart';
import '../resource/edit_resource_screen.dart'; // Re-use existing edit screen
import '../resource/resource_detail_screen.dart'; // For viewing details

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
    ResourceService resourceService,
    Resource resource,
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
        await resourceService.deleteResource(resource.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.resourceDeletedSuccess(resource.title),
            ), // "'{resourceTitle}' deleted successfully."
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.failedToDeleteResource(
                resource.title,
                e.toString(),
                '',
              ), // Provide the third argument as needed
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
    final resourceService = Provider.of<ResourceService>(
      context,
      listen: false,
    );
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.manageResourcesTitle), // "Manage Resources"
        centerTitle: true,
        // Admins can create resources via the main app's SpeedDial if they are also teachers.
        // If a dedicated "Add Resource" button is needed here for admins specifically, it can be added.
      ),
      body: StreamBuilder<List<Resource>>(
        stream: resourceService.getResources(), // Fetches all resources
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                l10n.errorLoadingResources(snapshot.error.toString()),
              ),
            ); // "Error loading resources: {error}"
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(l10n.noResourcesFoundManager),
            ); // "No resources found in the system."
          }

          final resources = snapshot.data!;

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
                        tooltip: l10n.editResourceTooltip, // "Edit Resource"
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
                        tooltip:
                            l10n.deleteResourceTooltip, // "Delete Resource"
                        onPressed:
                            () => _deleteResource(
                              context,
                              resourceService,
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
