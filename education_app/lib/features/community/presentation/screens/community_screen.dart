// lib/features/community/presentation/screens/community_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sud_qollanma/features/auth/presentation/providers/auth_notifier.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import '../../domain/entities/discussion_topic.dart';
import '../../data/models/topic_model.dart';
import '../providers/community_provider.dart';
import '../widgets/discussion_topic_card.dart';
import 'create_topic_screen.dart';
import 'topic_detail_screen.dart';
import 'package:sud_qollanma/features/auth/domain/entities/app_user.dart'; // Keep untill Users are migrated

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  Future<void> _handleRefresh() async {
    // Current implementation relies on Stream, so refresh is just a UX delay
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() {});
  }

  void _navigateToCreateTopic() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateTopicScreen()),
    );
  }

  void _navigateToTopicDetail(DiscussionTopic topic) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TopicDetailScreen(topic: topic),
      ),
    );
  }

  // Note: Edit functionality requires a dedicated Edit screen which we can reuse or refactor later.
  // For now I'm omitting the Edit Logic to focus on Clean Architecture migration of the main list.
  // We can add it back if the Edit Screen is migrated.

  void _deleteTopic(DiscussionTopic topic) {
    final l10n = AppLocalizations.of(context);
    final provider = Provider.of<CommunityProvider>(context, listen: false);

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
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: Text(
                l10n?.deleteButtonText ?? 'Delete',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                try {
                  await provider.deleteTopic(topic.id);
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
    final l10n = AppLocalizations.of(context);
    final authNotifier = Provider.of<AuthNotifier>(context);
    final AppUser? currentAppUser = authNotifier.appUser;
    final communityProvider = Provider.of<CommunityProvider>(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: StreamBuilder<List<DiscussionTopic>>(
          stream: communityProvider.topicsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData &&
                !snapshot.hasError) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(l10n?.noDiscussionsYet ?? 'No discussions yet.'),
              );
            }

            final topics = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: topics.length,
              itemBuilder: (context, index) {
                final topic = topics[index];
                bool canModify = false;
                if (currentAppUser != null) {
                  if (currentAppUser.role == UserRole.admin ||
                      currentAppUser.id == topic.authorId) {
                    canModify = true;
                  }
                }

                return DiscussionTopicCard(
                  topic: topic,
                  canModify: canModify,
                  onTap: () => _navigateToTopicDetail(topic),
                  onDelete: canModify ? () => _deleteTopic(topic) : null,
                  onEdit: null, // Placeholder for Edit
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateTopic,
        child: const Icon(Icons.add),
      ),
    );
  }
}
