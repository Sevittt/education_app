// lib/screens/community/create_topic_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/discussion_topic.dart';
import '../../services/community_service.dart';
import '../../models/auth_notifier.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CreateTopicScreen extends StatefulWidget {
  const CreateTopicScreen({super.key});

  @override
  State<CreateTopicScreen> createState() => _CreateTopicScreenState();
}

class _CreateTopicScreenState extends State<CreateTopicScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _createTopic() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final l10n = AppLocalizations.of(context);
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);

    // --- ADDED/ENHANCED CHECKS FOR VALID USER DATA ---
    final String? currentUserId =
        authNotifier.currentUser?.uid; // FirebaseUser UID
    final String? authorDisplayName =
        authNotifier.appUser?.name; // Name from your custom User model

    if (currentUserId == null || currentUserId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.mustBeLoggedInToCreateTopic ?? // Reusing existing localization
                  'You must be logged in to create a topic.',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      // Ensure isLoading is reset if we return early
      if (_isLoading) {
        // Only set if it was true
        setState(() {
          _isLoading = false;
        });
      }
      return; // Stop execution
    }

    if (authorDisplayName == null ||
        authorDisplayName.isEmpty ||
        authorDisplayName == 'Anonymous' || // Avoid placeholder names
        authorDisplayName == 'New User') {
      // Another common placeholder
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.profileIncompleteToCreateTopic ?? // New localization key needed
                  'Your profile name is not set. Please update your profile.',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      if (_isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
      return; // Stop execution
    }
    // --- END OF ADDED/ENHANCED CHECKS ---

    setState(() {
      _isLoading = true;
    });

    final newTopic = DiscussionTopic(
      id: '', // Firestore will generate
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      authorName: authorDisplayName, // Use the verified name
      authorId: currentUserId, // Use the verified ID
      createdAt: DateTime.now(),
      commentIds: const [], // Initialize with empty list
      commentCount: 0, // Initialize comment count
    );

    try {
      final communityService = Provider.of<CommunityService>(
        context,
        listen: false,
      );
      await communityService.createTopic(newTopic);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.topicCreatedSuccess ?? 'Topic created successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.failedToCreateTopic('Error', e.toString()) ??
                  'Failed to create topic: $e',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.createTopicScreenTitle ?? 'Start New Discussion'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Topic Title Field
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: l10n?.createTopicTitleLabel ?? 'Topic Title',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.title_rounded),
                ),
                validator: (value) {
                  final trimmedValue = value?.trim();
                  if (trimmedValue == null || trimmedValue.isEmpty) {
                    return l10n?.createTopicValidationEmpty(
                          l10n.createTopicTitleLabel,
                        ) ??
                        'Title cannot be empty.';
                  }
                  if (trimmedValue.length < 10) {
                    return l10n?.createTopicValidationMinLength(
                          l10n.createTopicTitleLabel,
                          10,
                        ) ??
                        'Title must be at least 10 characters long.';
                  }
                  if (trimmedValue.length > 150) {
                    return l10n?.createTopicValidationMaxLength(
                          l10n.createTopicTitleLabel,
                          150,
                        ) ??
                        'Title cannot exceed 150 characters.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Discussion Content Field
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText:
                      l10n?.createTopicContentLabel ?? 'Discussion Content',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.article_outlined),
                ),
                maxLines: 8,
                keyboardType: TextInputType.multiline,
                validator: (value) {
                  final trimmedValue = value?.trim();
                  if (trimmedValue == null || trimmedValue.isEmpty) {
                    return l10n?.createTopicValidationEmpty(
                          l10n.createTopicContentLabel,
                        ) ??
                        'Content cannot be empty.';
                  }
                  if (trimmedValue.length < 20) {
                    return l10n?.createTopicValidationMinLength(
                          l10n.createTopicContentLabel,
                          20,
                        ) ??
                        'Content must be at least 20 characters long.';
                  }
                  if (trimmedValue.length > 2000) {
                    return l10n?.createTopicValidationMaxLength(
                          l10n.createTopicContentLabel,
                          2000,
                        ) ??
                        'Content cannot exceed 2000 characters.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.post_add),
                      label: Text(
                        l10n?.createTopicButtonText ??
                            'Create Discussion Topic',
                      ),
                      onPressed: _createTopic,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

// Add new localization keys to your AppLocalizations extension/ARB files
// (Some might be reusable from CreateResourceScreen)
extension AppLocalizationsCreateTopicMessages on AppLocalizations? {
  // String get createTopicScreenTitle => this?.createTopicScreenTitle ?? 'Start New Discussion'; // Already in your previous extension
  // String get createTopicTitleLabel => this?.createTopicTitleLabel ?? 'Topic Title'; // Already in your previous extension
  // String get createTopicContentLabel => this?.createTopicContentLabel ?? 'Discussion Content'; // Already in your previous extension
  // String get createTopicButtonText => this?.createTopicButtonText ?? 'Create Discussion Topic'; // Already in your previous extension
  // String get mustBeLoggedInToCreateTopic => this?.mustBeLoggedInToCreateTopic ?? 'You must be logged in to create a topic.'; // Already in your previous extension
  // String get topicCreatedSuccess => this?.topicCreatedSuccess ?? 'Topic created successfully!'; // Already in your previous extension
  // String failedToCreateTopic(String title, String error) => this?.failedToCreateTopic(title, error) ?? 'Failed to create topic: $title: $error'; // Already in your previous extension

  // String createTopicValidationEmpty(String fieldName) => this?.createTopicValidationEmpty(fieldName) ?? '$fieldName cannot be empty.'; // Already in your previous extension
  // String createTopicValidationMinLength(String fieldName, int length) => this?.createTopicValidationMinLength(fieldName, length) ?? '$fieldName must be at least $length characters long.'; // Already in your previous extension
  // String createTopicValidationMaxLength(String fieldName, int length) => this?.createTopicValidationMaxLength(fieldName, length) ?? '$fieldName cannot exceed $length characters.'; // Already in your previous extension

  // NEW KEY:
  String get profileIncompleteToCreateTopic =>
      this?.profileIncompleteToCreateTopic ??
      'Your profile name is not set. Please update your profile.';
}
