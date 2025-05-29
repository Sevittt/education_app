// lib/screens/community_screen.dart

import 'package:flutter/material.dart';
import '../../data/dummy_data.dart'; // Import dummy data and helpers
import '../../models/discussion_topic.dart'; // Import DiscussionTopic
import '../../models/users.dart'; // Import User model for author details
import 'discussion_detail_screen.dart'; // Import the detail screen
import 'edit_topic_screen.dart'; // Import the new EditTopicScreen

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  List<DiscussionTopic> _discussionTopics = [];

  @override
  void initState() {
    super.initState();
    _loadTopics();
  }

  void _loadTopics() {
    setState(() {
      _discussionTopics = List.from(
        dummyDiscussionTopics,
      ); // Create a mutable copy
    });
  }

  Future<void> _navigateToEditTopicScreen(DiscussionTopic topicToEdit) async {
    final updatedTopic = await Navigator.push<DiscussionTopic?>(
      // Expect DiscussionTopic?
      context,
      MaterialPageRoute(
        builder: (context) => EditTopicScreen(topicToEdit: topicToEdit),
      ),
    );

    if (updatedTopic != null && mounted) {
      setState(() {
        // Update the topic in the global dummyDiscussionTopics list
        final indexInGlobalList = dummyDiscussionTopics.indexWhere(
          (t) => t.id == updatedTopic.id,
        );
        if (indexInGlobalList != -1) {
          dummyDiscussionTopics[indexInGlobalList] = updatedTopic;
        }
        // Refresh the local list for the UI
        _loadTopics();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${updatedTopic.title}" updated successfully.'),
        ),
      );
    }
  }

  void _deleteTopic(BuildContext context, DiscussionTopic topic) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to delete "${topic.title}"?'),
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
              onPressed: () {
                setState(() {
                  dummyDiscussionTopics.removeWhere((t) => t.id == topic.id);
                  _discussionTopics.removeWhere((t) => t.id == topic.id);
                });
                Navigator.of(dialogContext).pop();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('"${topic.title}" deleted successfully.'),
                    ),
                  );
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

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child:
                _discussionTopics.isEmpty
                    ? Center(/* ... empty state code ... */)
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 8.0,
                      ),
                      itemCount: _discussionTopics.length,
                      itemBuilder: (context, index) {
                        final topic = _discussionTopics[index];
                        final User? author = findUserById(topic.authorId);
                        final String authorName =
                            author?.name ?? 'Unknown User';
                        final String authorInitial =
                            authorName.isNotEmpty
                                ? authorName[0].toUpperCase()
                                : '?';
                        final int commentCount = topic.commentIds.length;

                        return Card(
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
                              ).then((_) => _loadTopics());
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
                                            color:
                                                colorScheme.onPrimaryContainer,
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
                                            // Navigate to EditTopicScreen
                                            _navigateToEditTopicScreen(topic);
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
                                            _deleteTopic(context, topic);
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
                    ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _navigateToCreateTopicScreen,
      //   tooltip: 'Start a New Discussion',
      //   backgroundColor: colorScheme.primary,
      //   foregroundColor: colorScheme.onPrimary,
      //   child: const Icon(Icons.add_comment_outlined),
      // ),
    );
  }
}
