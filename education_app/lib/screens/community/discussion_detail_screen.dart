// lib/screens/discussion_detail_screen.dart

import 'package:flutter/material.dart';
import '../../data/dummy_data.dart'; // Import dummy data for comments and users
import '../../models/discussion_topic.dart'; // Import DiscussionTopic
import '../../models/comment.dart'; // Import Comment
import '../../models/users.dart'; // Import User model
import 'package:provider/provider.dart'; // If using Provider for current user
import '../../models/auth_notifier.dart'; // Assuming AuthNotifier provides the User object

// Import the uuid package for generating unique IDs
import 'package:uuid/uuid.dart';

// Create an instance of Uuid (can be global to the file or local if preferred)
var uuid = const Uuid();

class DiscussionDetailScreen extends StatefulWidget {
  final DiscussionTopic topic;

  const DiscussionDetailScreen({super.key, required this.topic});

  @override
  State<DiscussionDetailScreen> createState() => _DiscussionDetailScreenState();
}

class _DiscussionDetailScreenState extends State<DiscussionDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  List<Comment> _topicComments = [];

  @override
  void initState() {
    super.initState();
    // Initialize comments for the current topic
    _loadComments();
  }

  void _loadComments() {
    // In a real app, fetch from a service. For now, filter dummy data.
    setState(() {
      _topicComments = findCommentsByTopicId(widget.topic.id).toList();
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _addComment() {
    final newCommentContent = _commentController.text.trim();
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    final currentUser = authNotifier.currentUser;

    if (newCommentContent.isNotEmpty) {
      // Get the actual current user ID
      final authorId =
          currentUser?.uid ??
          dummyUser2.id; // Fallback to dummy if no current user

      // Generate a unique ID for the new comment using the uuid package.
      final newCommentId = uuid.v4(); // Generates a v4 UUID

      final newComment = Comment(
        id: newCommentId,
        topicId: widget.topic.id,
        authorId: authorId,
        content: newCommentContent,
        createdAt: DateTime.now(),
      );

      // --- Add the new comment to the dummy data lists ---
      // In a real app, this would be an API call to your backend.
      dummyComments.add(newComment);

      final topicIndex = dummyDiscussionTopics.indexWhere(
        (t) => t.id == widget.topic.id,
      );
      if (topicIndex != -1) {
        final updatedCommentIds = List<String>.from(
          dummyDiscussionTopics[topicIndex].commentIds,
        );
        updatedCommentIds.add(newCommentId);
        dummyDiscussionTopics[topicIndex] = dummyDiscussionTopics[topicIndex]
            .copyWith(commentIds: updatedCommentIds);
      }

      setState(() {
        _topicComments.add(newComment); // Update local UI list
        _commentController.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Comment added with ID: $newCommentId')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment cannot be empty.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    final User? topicAuthor = findUserById(widget.topic.authorId);
    // Use displayName instead of name, with a fallback
    final String topicAuthorName = topicAuthor?.displayName ?? 'Unknown User';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topic.title, overflow: TextOverflow.ellipsis),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Original Post ---
                  Card(
                    elevation: 1,
                    color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.topic.title,
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Posted by $topicAuthorName on ${widget.topic.createdAt.toLocal().toString().split('.')[0]}',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant.withOpacity(
                                0.8,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12.0),
                          Text(
                            widget.topic.content,
                            style: textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Divider(color: colorScheme.outline.withOpacity(0.5)),
                  const SizedBox(height: 10),

                  // --- Replies Section ---
                  Text(
                    'Replies (${_topicComments.length}):',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  if (_topicComments.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Center(
                        child: Text(
                          'No replies yet. Be the first to comment!',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _topicComments.length,
                      itemBuilder: (context, index) {
                        final comment = _topicComments[index];
                        final User? commentAuthor = findUserById(
                          comment.authorId,
                        );
                        // Use displayName instead of name, with a fallback
                        final String commentAuthorName =
                            commentAuthor?.displayName ?? 'Unknown User';
                        final String authorInitial =
                            commentAuthorName.isNotEmpty
                                ? commentAuthorName[0].toUpperCase()
                                : '?';

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: colorScheme.secondaryContainer,
                                // Use photoURL for CircleAvatar background if available
                                backgroundImage:
                                    commentAuthor?.photoURL != null &&
                                            commentAuthor!.photoURL!.isNotEmpty
                                        ? (commentAuthor.photoURL!.startsWith(
                                              'http',
                                            )
                                            ? NetworkImage(
                                              commentAuthor.photoURL!,
                                            )
                                            : AssetImage(
                                                  commentAuthor.photoURL!,
                                                )
                                                as ImageProvider)
                                        : null, // No background image if no photoURL
                                child:
                                    (commentAuthor?.photoURL == null ||
                                            commentAuthor!.photoURL!.isEmpty)
                                        ? Text(
                                          // Show initial only if no image
                                          authorInitial,
                                          style: textTheme.labelMedium
                                              ?.copyWith(
                                                color:
                                                    colorScheme
                                                        .onSecondaryContainer,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        )
                                        : null, // No text if there's an image
                              ),
                              const SizedBox(width: 12.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          commentAuthorName,
                                          style: textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '• ${comment.createdAt.toLocal().toString().split('.')[0]}',
                                          style: textTheme.bodySmall?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4.0),
                                    Text(
                                      comment.content,
                                      style: textTheme.bodyMedium?.copyWith(
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      separatorBuilder:
                          (context, index) => Divider(
                            color: colorScheme.outline.withOpacity(0.3),
                            height: 16,
                          ),
                    ),
                ],
              ),
            ),
          ),

          // --- Add Comment Input Area ---
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: theme.cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Write a reply...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.0),
                        borderSide: BorderSide(
                          color: colorScheme.outline.withOpacity(0.5),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.0),
                        borderSide: BorderSide(
                          color: colorScheme.outline.withOpacity(0.5),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.0),
                        borderSide: BorderSide(
                          color: colorScheme.primary,
                          width: 1.5,
                        ),
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest
                          .withOpacity(0.5),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 10.0,
                      ),
                    ),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                const SizedBox(width: 8.0),
                IconButton(
                  icon: Icon(Icons.send_rounded, color: colorScheme.primary),
                  onPressed: _addComment,
                  tooltip: 'Send Comment',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
