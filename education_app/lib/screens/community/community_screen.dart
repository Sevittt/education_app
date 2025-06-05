// lib/screens/community/community_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/discussion_topic.dart';
import '../../models/users.dart';
import '../../models/auth_notifier.dart';
import '../../services/community_service.dart';
import 'discussion_detail_screen.dart';
import 'edit_topic_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // For localization

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  // _discussionTopics list and _loadTopics are no longer needed
  // as StreamBuilder will manage the data from the service.

  // The onRefresh callback for RefreshIndicator
  Future<void> _handleRefresh() async {
    // For Firestore streams, the stream is already live.
    // This callback mainly provides visual feedback.
    await Future.delayed(
      const Duration(milliseconds: 500),
    ); // Optional delay for UX

    if (mounted) {
      setState(() {
        // This setState call might not be strictly necessary if the StreamBuilder
        // is the only thing updating from data changes, but it's good practice
        // if you want to ensure any other part of the screen dependent on state refreshes.
      });
    }
  }

  // _navigateToEditTopicScreen and _deleteTopic methods remain largely the same,
  // but ensure they use the communityService passed or obtained from Provider.

  Future<void> _navigateToEditTopicScreen(
    DiscussionTopic topicToEdit,
    CommunityService communityService,
  ) async {
    final updatedTopicFromForm = await Navigator.push<DiscussionTopic?>(
      context,
      MaterialPageRoute(
        builder: (context) => EditTopicScreen(topicToEdit: topicToEdit),
      ),
    );

    if (updatedTopicFromForm != null && mounted) {
      final l10n = AppLocalizations.of(context);
      try {
        await communityService.updateTopic(updatedTopicFromForm);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.topicUpdatedSuccess ??
                  '"${updatedTopicFromForm.title}" updated successfully.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.failedToUpdateTopic(
                    updatedTopicFromForm.title,
                    e.toString(),
                  ) ??
                  'Error updating topic "${updatedTopicFromForm.title}": $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _deleteTopic(
    BuildContext context,
    DiscussionTopic topic,
    CommunityService communityService,
  ) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n?.deleteTopicConfirmTitle ?? 'Confirm Delete'),
          content: Text(
            l10n?.deleteTopicConfirmMessage(topic.title) ??
                'Are you sure you want to delete "${topic.title}"?',
          ),
          actions: <Widget>[
            TextButton(
              child: Text(l10n?.cancelButtonText ?? 'Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text(
                l10n?.deleteButtonText ?? 'Delete',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Close dialog first
                try {
                  await communityService.deleteTopic(topic.id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          l10n?.topicDeletedSuccess(topic.title) ??
                              '"${topic.title}" deleted successfully.',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          l10n?.failedToDeleteTopic(e.toString()) ??
                              'Error deleting topic: $e',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context);

    final authNotifier = Provider.of<AuthNotifier>(context);
    final User? currentUser = authNotifier.appUser;
    final communityService = Provider.of<CommunityService>(
      context,
      listen: false,
    );

    return Scaffold(
      // AppBar is managed by HomePage
      body: RefreshIndicator(
        // Wrap the Column with RefreshIndicator
        onRefresh: _handleRefresh, // Assign the callback
        color: colorScheme.primary,
        backgroundColor: colorScheme.surfaceContainerHighest,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: StreamBuilder<List<DiscussionTopic>>(
                stream: communityService.getTopics(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData &&
                      !snapshot.hasError) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    print(
                      "CommunityScreen StreamBuilder error: ${snapshot.error}",
                    );
                    print(
                      "CommunityScreen error type: ${snapshot.error.runtimeType}",
                    );
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          l10n?.errorLoadingData ??
                              'An error occurred while loading discussions.',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.error,
                          ),
                        ),
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.forum_outlined,
                            size: 60,
                            color: colorScheme.onSurface.withOpacity(0.4),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n?.noDiscussionsYet ?? 'No discussions yet.',
                            style: textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n?.beTheFirstToStartConversation ??
                                'Be the first to start a conversation!',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final topics = snapshot.data!;

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 8.0,
                    ),
                    itemCount: topics.length,
                    itemBuilder: (context, index) {
                      final topic = topics[index];
                      // Assuming authorName and commentCount are populated correctly by DiscussionTopic.fromMap
                      final String authorName = topic.authorName;
                      final String authorInitial =
                          authorName.isNotEmpty
                              ? authorName[0].toUpperCase()
                              : '?';
                      final int commentCount = topic.commentCount;

                      bool canModify = false;
                      if (currentUser != null) {
                        if (currentUser.role == UserRole.admin ||
                            currentUser.id == topic.authorId) {
                          canModify = true;
                        }
                      }

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12.0),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        DiscussionDetailScreen(topic: topic),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  topic.title,
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8.0),
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 12,
                                      backgroundColor:
                                          colorScheme.primaryContainer,
                                      child: Text(
                                        authorInitial,
                                        style: textTheme.labelSmall?.copyWith(
                                          color: colorScheme.onPrimaryContainer,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8.0),
                                    Expanded(
                                      child: Text(
                                        'By $authorName', // Using authorName from topic model
                                        style: textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Spacer(), // Use Spacer to push comment count to the right
                                    Icon(
                                      Icons.comment_outlined,
                                      size: 14,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 4.0),
                                    Text(
                                      '$commentCount ${commentCount == 1 ? (l10n?.commentSingular ?? 'reply') : (l10n?.commentPlural ?? 'replies')}',
                                      style: textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                                if (canModify)
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.edit_outlined,
                                            size: 20,
                                            color: colorScheme.secondary,
                                          ),
                                          onPressed: () {
                                            _navigateToEditTopicScreen(
                                              topic,
                                              communityService,
                                            );
                                          },
                                          tooltip:
                                              l10n?.editTopicTooltip ??
                                              'Edit Topic',
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete_outline,
                                            size: 20,
                                            color: colorScheme.error,
                                          ),
                                          onPressed: () {
                                            _deleteTopic(
                                              context,
                                              topic,
                                              communityService,
                                            );
                                          },
                                          tooltip:
                                              l10n?.deleteTopicTooltip ??
                                              'Delete Topic',
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Add new localization keys to your AppLocalizations extension/ARB files if needed
extension AppLocalizationsCommunityMessages on AppLocalizations? {
  String get deleteTopicConfirmTitle =>
      this?.deleteTopicConfirmTitle ?? 'Confirm Delete';
  String deleteTopicConfirmMessage(String topicTitle) =>
      this?.deleteTopicConfirmMessage(topicTitle) ??
      'Are you sure you want to delete "$topicTitle"?';
  String topicDeletedSuccess(String topicTitle) =>
      this?.topicDeletedSuccess(topicTitle) ??
      '"$topicTitle" deleted successfully.';
  String get topicUpdatedSuccess =>
      this?.topicUpdatedSuccess ??
      'Topic updated successfully!'; // Already in CreateTopicScreen ext
  String failedToUpdateTopic(String topicTitle, String error) =>
      this?.failedToUpdateTopic(topicTitle, error) ??
      'Failed to update topic "$topicTitle": $error'; // Already in CreateTopicScreen ext
  String failedToDeleteTopic(String error) =>
      this?.failedToDeleteTopic(error) ?? 'Error deleting topic: $error';
  String get editTopicTooltip => this?.editTopicTooltip ?? 'Edit Topic';
  String get deleteTopicTooltip => this?.deleteTopicTooltip ?? 'Delete Topic';
  String get commentSingular => this?.commentSingular ?? 'reply';
  String get commentPlural => this?.commentPlural ?? 'replies';
  String get noDiscussionsYet =>
      this?.noDiscussionsYet ?? 'No discussions yet.';
  String get beTheFirstToStartConversation =>
      this?.beTheFirstToStartConversation ??
      'Be the first to start a conversation!';
  // Ensure errorLoadingData is defined in your ARB files
  // String get errorLoadingData => this?.errorLoadingData ?? 'Error loading data.';
}
