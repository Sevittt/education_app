// lib/features/community/presentation/screens/topic_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sud_qollanma/features/auth/presentation/providers/auth_notifier.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import '../../domain/entities/discussion_topic.dart';
import '../../domain/entities/comment.dart';
import '../providers/community_provider.dart';

class TopicDetailScreen extends StatefulWidget {
  final DiscussionTopic topic;

  const TopicDetailScreen({super.key, required this.topic});

  @override
  State<TopicDetailScreen> createState() => _TopicDetailScreenState();
}

class _TopicDetailScreenState extends State<TopicDetailScreen> {
  final _commentController = TextEditingController();
  bool _isPosting = false;

  Future<void> _addComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    final user = authNotifier.appUser;
    final userId = user?.id;
    final firebaseUser = authNotifier.currentUser;

    if (firebaseUser == null || userId == null) return;

    setState(() {
      _isPosting = true;
    });

    try {
      await Provider.of<CommunityProvider>(context, listen: false).addComment(
        topicId: widget.topic.id,
        content: content,
        userId: user!.id,
        userName: user.name,
        userProfilePic: user.profilePictureUrl,
      );
      _commentController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment added!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPosting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<CommunityProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text(widget.topic.title)),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(widget.topic.title, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(widget.topic.content, style: theme.textTheme.bodyMedium),
                const Divider(height: 32),
                Text('Replies', style: theme.textTheme.titleMedium),
                StreamBuilder<List<Comment>>(
                  stream: provider.getCommentsForTopic(widget.topic.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: Text('No replies yet.')),
                      );
                    }
                    final comments = snapshot.data!;
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: comments.length,
                      separatorBuilder: (c, i) => const Divider(),
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        return ListTile(
                          title: Text(comment.authorName),
                          subtitle: Text(comment.content),
                          leading:
                              CircleAvatar(child: Text(comment.authorName[0])),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration:
                        const InputDecoration(hintText: 'Write a reply...'),
                  ),
                ),
                IconButton(
                  icon: _isPosting
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.send),
                  onPressed: _isPosting ? null : _addComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
