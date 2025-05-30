// lib/screens/community/community_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Remove dummy data import if no longer needed for direct use here
// import '../../data/dummy_data.dart';
import '../../models/discussion_topic.dart';
import '../../models/users.dart';
import '../../models/auth_notifier.dart';
import '../../services/community_service.dart'; // Import your service
import 'discussion_detail_screen.dart';
import 'edit_topic_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  // No longer need _discussionTopics list or _loadTopics for dummy data

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
      try {
        // Use the 'copyWith' method from the original topicToEdit,
        // applying changes from updatedTopicFromForm which only contains title and content.
        // Or ensure EditTopicScreen returns a full DiscussionTopic object with all fields.
        // For simplicity, assuming EditTopicScreen's returned object is what we want to save.
        await communityService.updateTopic(updatedTopicFromForm);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '"${updatedTopicFromForm.title}" updated successfully.',
            ),
            backgroundColor: Colors.green,
          ),
        );
        // No need to call _loadTopics or setState, StreamBuilder will update.
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating topic: $e'),
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
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text(
            'Are you sure you want to delete "${topic.title}"? This will also delete associated comments if implemented on the backend.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text(
                'Delete',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Close dialog first
                try {
                  await communityService.deleteTopic(topic.id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('"${topic.title}" deleted successfully.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                  // StreamBuilder will handle UI update
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error deleting topic: $e'),
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

    final authNotifier = Provider.of<AuthNotifier>(context);
    final User? currentUser = authNotifier.appUser;
    final communityService = Provider.of<CommunityService>(
      context,
      listen: false,
    ); // Get service instance

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: StreamBuilder<List<DiscussionTopic>>(
              stream:
                  communityService
                      .getTopics(), // Use the stream from the service
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
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
                          'No discussions yet.',
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
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
                    // Assuming authorName is now directly available on DiscussionTopic from Firestore
                    final String authorName = topic.authorName;
                    final String authorInitial =
                        authorName.isNotEmpty
                            ? authorName[0].toUpperCase()
                            : '?';
                    // Comment count should ideally come from the topic model if denormalized,
                    // or you'd fetch comments separately. For now, assuming it's on the model.
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
                          // No need to call _loadTopics here as StreamBuilder handles updates
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
                                      'By $authorName',
                                      style: textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(
                                    Icons.comment_outlined,
                                    size: 14,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4.0),
                                  Text(
                                    '$commentCount ${commentCount == 1 ? "reply" : "replies"}',
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
                                        tooltip: 'Edit Topic',
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
                                        tooltip: 'Delete Topic',
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
    );
  }
}
