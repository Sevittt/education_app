// lib/screens/community/create_topic_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/discussion_topic.dart';
import '../../services/community_service.dart';
import '../../models/auth_notifier.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import AppLocalizations

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
      return; // If form is not valid, do nothing
    }
    setState(() {
      _isLoading = true;
    });

    final l10n = AppLocalizations.of(context); // For SnackBar messages
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    final appUser = authNotifier.currentUser; // Firebase User

    if (appUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.mustBeLoggedInToCreateTopic ??
                  'You must be logged in to create a topic.',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Assuming your DiscussionTopic model takes authorName and authorId
    final newTopic = DiscussionTopic(
      id: '', // Firestore will generate
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      authorName:
          authNotifier.appUser?.name ??
          appUser.displayName ??
          'Anonymous', // Use appUser's name if available
      authorId: appUser.uid,
      createdAt: DateTime.now(),
      commentIds: [], // Initialize with empty list
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
    final l10n = AppLocalizations.of(context); // For labels and validators

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
              // Topic Title Field - Enhanced Validation
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

              // Discussion Content Field - Enhanced Validation
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
                    // Example max length
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
                    // Wrap button with SizedBox
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
// This is just for placeholder error messages if l10n is null or keys are missing.
// You should define these properly in your .arb files.
extension AppLocalizationsTopicValidationMessages on AppLocalizations? {
  String get createTopicScreenTitle =>
      this?.createTopicScreenTitle ?? 'Start New Discussion';
  String get createTopicTitleLabel =>
      this?.createTopicTitleLabel ?? 'Topic Title';
  String get createTopicContentLabel =>
      this?.createTopicContentLabel ?? 'Discussion Content';
  String get createTopicButtonText =>
      this?.createTopicButtonText ?? 'Create Discussion Topic';
  String get mustBeLoggedInToCreateTopic =>
      this?.mustBeLoggedInToCreateTopic ??
      'You must be logged in to create a topic.';
  String get topicCreatedSuccess =>
      this?.topicCreatedSuccess ?? 'Topic created successfully!';
  String failedToCreateTopic(String title, String error) =>
      this?.failedToCreateTopic(title, error) ??
      'Failed to create topic: $title: $error';

  String createTopicValidationEmpty(String fieldName) =>
      this?.createTopicValidationEmpty(fieldName) ??
      '$fieldName cannot be empty.';
  String createTopicValidationMinLength(String fieldName, int length) =>
      this?.createTopicValidationMinLength(fieldName, length) ??
      '$fieldName must be at least $length characters long.';
  String createTopicValidationMaxLength(String fieldName, int length) =>
      this?.createTopicValidationMaxLength(fieldName, length) ??
      '$fieldName cannot exceed $length characters.';
}
