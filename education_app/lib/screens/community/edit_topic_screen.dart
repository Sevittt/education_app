// lib/screens/community/edit_topic_screen.dart

import 'package:education_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import '../../models/discussion_topic.dart';
import '../../services/community_service.dart'; // Import CommunityService

class EditTopicScreen extends StatefulWidget {
  final DiscussionTopic topicToEdit;

  const EditTopicScreen({super.key, required this.topicToEdit});

  @override
  State<EditTopicScreen> createState() => _EditTopicScreenState();
}

class _EditTopicScreenState extends State<EditTopicScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false; // Added for loading state

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.topicToEdit.title);
    _contentController = TextEditingController(
      text: widget.topicToEdit.content,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveTopicChanges() async {
    // Made async
    if (!_formKey.currentState!.validate()) {
      return; // If form is not valid, do nothing
    }
    setState(() {
      _isLoading = true;
    });

    final l10n = AppLocalizations.of(context);
    final communityService = Provider.of<CommunityService>(
      context,
      listen: false,
    );

    // Create an updated topic object using copyWith
    // Ensure all necessary fields are preserved or updated correctly.
    final updatedTopic = widget.topicToEdit.copyWith(
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      // authorId, authorName, createdAt, commentIds, commentCount are preserved from widget.topicToEdit by copyWith
    );

    try {
      await communityService.updateTopic(updatedTopic);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.topicUpdatedSuccess ?? 'Topic updated successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, updatedTopic); // Return the updated topic
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.failedToUpdateTopic(e.toString(), '') ??
                  'Failed to update topic: $e',
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
    final ThemeData theme = Theme.of(context);
    final l10n = AppLocalizations.of(context); // For labels and validators

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.editTopicScreenTitle ?? 'Edit Discussion Topic'),
        centerTitle: true,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save_outlined),
              onPressed: _saveTopicChanges,
              tooltip: l10n?.saveButtonText ?? 'Save Changes',
            ),
        ],
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
                  labelText:
                      l10n?.createTopicTitleLabel ??
                      'Topic Title', // Reusing create screen labels
                  hintText: 'Enter a clear and concise title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest
                      .withOpacity(0.5),
                  prefixIcon: const Icon(Icons.title_rounded),
                ),
                validator: (value) {
                  final trimmedValue = value?.trim();
                  // Reusing localization keys from CreateTopicScreen for consistency
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
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 20.0),

              // Discussion Content Field - Enhanced Validation
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText:
                      l10n?.createTopicContentLabel ??
                      'Discussion Content', // Reusing
                  hintText: 'Share your thoughts or questions in detail...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest
                      .withOpacity(0.5),
                  prefixIcon: const Icon(Icons.article_outlined),
                ),
                maxLines: 8,
                keyboardType: TextInputType.multiline,
                validator: (value) {
                  final trimmedValue = value?.trim();
                  // Reusing localization keys from CreateTopicScreen
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
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 24.0),
              // Save button moved to AppBar, but you can keep an additional button here if desired.
              // If keeping, ensure it also uses the _isLoading flag.
              if (!_isLoading) // Only show if not loading
                ElevatedButton.icon(
                  icon: const Icon(Icons.save_alt_outlined),
                  label: Text(l10n?.saveButtonText ?? 'Save Changes'),
                  onPressed: _saveTopicChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    textStyle: theme.textTheme.titleMedium,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                )
              else // Show a loading indicator in place of the button
                const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}

// Add new localization keys to your AppLocalizations extension/ARB files if needed
// (many might be reusable from CreateTopicScreen or other edit screens)
extension AppLocalizationsEditTopicMessages on AppLocalizations? {
  String get editTopicScreenTitle =>
      this?.editTopicScreenTitle ?? 'Edit Discussion Topic';
  String get topicUpdatedSuccess =>
      this?.topicUpdatedSuccess ?? 'Topic updated successfully!';
  String failedToUpdateTopic(String error, String details) =>
      this?.failedToUpdateTopic(error, details) ??
      'Failed to update topic: $error';
  // Ensure saveButtonText and other common validation keys are available/reused from other extensions.
}
