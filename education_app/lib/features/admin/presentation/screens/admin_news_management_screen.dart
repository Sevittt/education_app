// lib/screens/admin/admin_news_management_screen.dart
//import 'package:education_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:sud_qollanma/l10n/app_localizations.dart';
import 'package:sud_qollanma/shared/widgets/custom_network_image.dart'; // Added

import 'package:sud_qollanma/features/news/domain/entities/news_entity.dart';
import 'package:sud_qollanma/features/news/presentation/providers/news_notifier.dart';
import 'admin_add_edit_news_screen.dart'; // We'll create this next

class AdminNewsManagementScreen extends StatefulWidget {
  const AdminNewsManagementScreen({super.key});

  @override
  State<AdminNewsManagementScreen> createState() =>
      _AdminNewsManagementScreenState();
}

class _AdminNewsManagementScreenState extends State<AdminNewsManagementScreen> {
  Future<void> _deleteNewsItem(
    BuildContext context,

    NewsNotifier newsNotifier,
    NewsEntity newsItem,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.confirmDeleteTitle), // "Confirm Deletion"
          content: Text(
            l10n.confirmDeleteNewsMessage(newsItem.title),
          ), // "Are you sure you want to delete '{newsTitle}'?"
          actions: <Widget>[
            TextButton(
              child: Text(l10n.cancelButtonText), // "Cancel"
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(dialogContext).colorScheme.error,
              ),
              child: Text(l10n.deleteButtonText), // "Delete"
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      try {
        await newsNotifier.deleteNews(newsItem.id);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.newsDeletedSuccess(newsItem.title),
            ), // "'{newsTitle}' deleted successfully."
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.failedToDeleteNews(
                newsItem.title,
                e.toString(),
              ), // Provide the third argument as needed
            ), // "Failed to delete '{newsTitle}': {error}"
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final newsNotifier = Provider.of<NewsNotifier>(context, listen: false);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.manageNewsTitle), // "Manage News"
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: l10n.addNewsTooltip, // "Add New News Article"
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          const AdminAddEditNewsScreen(), // Pass null for creating
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<NewsEntity>>(
        stream: newsNotifier.newsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(l10n.errorLoadingNews(snapshot.error.toString())),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(l10n.noNewsAvailableManager),
            ); // "No news articles found. Add one!"
          }

          final newsList = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(8.0),
            itemCount: newsList.length,
            itemBuilder: (context, index) {
              final newsItem = newsList[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading:
                      newsItem.imageUrl != null && newsItem.imageUrl!.isNotEmpty
                          ? SizedBox(
                            width: 50,
                            height: 50,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(
                                newsItem.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (ctx, err, st) => const Icon(
                                      Icons.image_not_supported_outlined,
                                    ),
                              ),
                            ),
                          )
                          : const Icon(Icons.article_outlined, size: 30),
                  title: Text(
                    newsItem.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        newsItem.source,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (newsItem.publicationDate != null)
                        Text(
                          DateFormat.yMMMd(
                            l10n.localeName,
                          ).add_jm().format(newsItem.publicationDate!),
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
                        tooltip: l10n.editNewsTooltip, // "Edit News"
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => AdminAddEditNewsScreen(
                                    newsItemToEdit: newsItem,
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
                        tooltip: l10n.deleteNewsTooltip, // "Delete News"
                        onPressed:
                            () =>
                                _deleteNewsItem(context, newsNotifier, newsItem),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 4),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: Text(l10n.addNewsButton), // "Add News"
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      const AdminAddEditNewsScreen(), // Pass null for creating
            ),
          );
        },
      ),
    );
  }
}

// Add these localization keys to your .arb files:
// "confirmDeleteTitle": "Confirm Deletion",
// "confirmDeleteNewsMessage": "Are you sure you want to delete \"{newsTitle}\"?",
// "newsDeletedSuccess": "\"{newsTitle}\" deleted successfully.",
// "failedToDeleteNews": "Failed to delete \"{newsTitle}\": {error}",
// "addNewsTooltip": "Add New News Article",
// "editNewsTooltip": "Edit News",
// "deleteNewsTooltip": "Delete News",
// "addNewsButton": "Add News",
// "noNewsAvailableManager": "No news articles found. Add one!"
// (You might already have "manageNewsTitle", "errorLoadingNews", "cancelButtonText", "deleteButtonText")
