// lib/screens/community/discussion_detail_screen.dart
// import 'package:education_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp
import 'package:sud_qollanma/l10n/app_localizations.dart';

import '../../models/discussion_topic.dart';
import '../../models/comment.dart';
import 'package:sud_qollanma/features/auth/presentation/providers/auth_notifier.dart'; // For current user details
import '../../services/community_service.dart'; // To interact with Firebase

// Removed uuid import as Firestore generates IDs for new documents

class DiscussionDetailScreen extends StatefulWidget {
  final DiscussionTopic topic;

  const DiscussionDetailScreen({super.key, required this.topic});

  @override
  State<DiscussionDetailScreen> createState() => _DiscussionDetailScreenState();
}

class _DiscussionDetailScreenState extends State<DiscussionDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool _isPostingComment = false;

  // _topicComments list and _loadComments are no longer needed
  // as StreamBuilder will manage the data.

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _addComment() async {
    final l10n = AppLocalizations.of(context)!;
    final newCommentContent = _commentController.text.trim();
    if (newCommentContent.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.commentCannotBeEmpty)));
      return;
    }

    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    final currentUser = authNotifier.appUser; // Your custom User model
    final firebaseUser = authNotifier.currentUser; // Firebase Auth User

    if (currentUser == null || firebaseUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.mustBeLoggedInToComment)));
      return;
    }

    setState(() {
      _isPostingComment = true;
    });

    final newComment = Comment(
      id: '', // Firestore will generate this
      topicId: widget.topic.id,
      authorId: firebaseUser.uid, // Use Firebase UID
      authorName: currentUser.name, // Use name from your appUser model
      authorProfilePicUrl:
          currentUser.profilePictureUrl, // Use pic from appUser
      content: newCommentContent,
      createdAt: Timestamp.now(), // Use Firestore Timestamp for server time
    );

    try {
      final communityService = Provider.of<CommunityService>(
        context,
        listen: false,
      );
      await communityService.addComment(widget.topic.id, newComment);
      _commentController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.commentAddedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.failedToAddComment(e.toString(), '')),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPostingComment = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;
    final communityService = Provider.of<CommunityService>(
      context,
      listen: false,
    );

    // Topic author name is already part of widget.topic.authorName


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
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
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
                  Divider(color: colorScheme.outline.withValues(alpha: 0.5)),
                  const SizedBox(height: 10),

                  // --- Replies Section (Using StreamBuilder) ---
                  Text(
                    l10n.repliesTitle, // Using l10n
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  StreamBuilder<List<Comment>>(
                    stream: communityService.getCommentsForTopic(
                      widget.topic.id,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            l10n.errorLoadingComments(
                              snapshot.error.toString(),
                            ),
                            style: TextStyle(color: colorScheme.error),
                          ),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Center(
                            child: Text(
                              l10n.noRepliesYet,
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        );
                      }

                      final comments = snapshot.data!;
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          // Author name and pic URL are now in the comment object
                          final String commentAuthorName = comment.authorName;
                          final String? commentAuthorPic =
                              comment.authorProfilePicUrl;
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
                                  backgroundColor:
                                      colorScheme.secondaryContainer,
                                  backgroundImage:
                                      commentAuthorPic != null &&
                                              commentAuthorPic.isNotEmpty
                                          ? (commentAuthorPic.startsWith('http')
                                              ? NetworkImage(commentAuthorPic)
                                              : AssetImage(commentAuthorPic)
                                                  as ImageProvider)
                                          : null,
                                  child:
                                      (commentAuthorPic == null ||
                                              commentAuthorPic.isEmpty)
                                          ? Text(
                                            authorInitial,
                                            style: textTheme.labelMedium
                                                ?.copyWith(
                                                  color:
                                                      colorScheme
                                                          .onSecondaryContainer,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          )
                                          : null,
                                ),
                                const SizedBox(width: 12.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            commentAuthorName,
                                            style: textTheme.titleSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '• ${MaterialLocalizations.of(context).formatShortDate(comment.createdAt.toDate())}', // Format date
                                            style: textTheme.bodySmall
                                                ?.copyWith(
                                                  color:
                                                      colorScheme
                                                          .onSurfaceVariant,
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
                              color: colorScheme.outline.withValues(alpha: 0.3),
                              height: 16,
                            ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // --- Add Comment Input Area ---
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: theme.cardColor, // Or theme.colorScheme.surface
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
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
                      hintText: l10n.writeAReplyHint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.0),
                        borderSide: BorderSide(
                          color: colorScheme.outline.withValues(alpha: 0.5),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.0),
                        borderSide: BorderSide(
                          color: colorScheme.outline.withValues(alpha: 0.5),
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
                          .withValues(alpha: 0.5),
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
                _isPostingComment
                    ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(),
                      ),
                    )
                    : IconButton(
                      icon: Icon(
                        Icons.send_rounded,
                        color: colorScheme.primary,
                      ),
                      onPressed: _addComment,
                      tooltip: l10n.sendCommentTooltip,
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Add new localization keys to your .arb files and AppLocalizations extension:
// "commentCannotBeEmpty": "Comment cannot be empty.",
// "mustBeLoggedInToComment": "You must be logged in to comment.",
// "commentAddedSuccessfully": "Comment added successfully!",
// "failedToAddComment": "Failed to add comment: {error}",
// "postedBy": "Posted by {authorName}",
// "onDate": "on {date}",
// "repliesTitle": "Replies",
// "errorLoadingComments": "Error loading comments: {error}",
// "noRepliesYet": "No replies yet. Be the first to comment!",
// "writeAReplyHint": "Write a reply...",
// "sendCommentTooltip": "Send Comment"
