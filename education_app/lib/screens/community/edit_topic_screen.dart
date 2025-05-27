// lib/screens/edit_topic_screen.dart

import 'package:flutter/material.dart';
import '../../models/discussion_topic.dart'; // Import DiscussionTopic model

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

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the existing topic's data
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

  void _saveTopicChanges() {
    if (_formKey.currentState!.validate()) {
      // Create an updated topic object using copyWith
      final updatedTopic = widget.topicToEdit.copyWith(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        // authorId, createdAt, and id remain the same from widget.topicToEdit
      );

      // Pop the screen and return the updated topic
      Navigator.pop(context, updatedTopic);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Discussion Topic'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            onPressed: _saveTopicChanges,
            tooltip: 'Save Changes',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Topic Title',
                  hintText: 'Enter a clear and concise title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest
                      .withOpacity(0.5),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title cannot be empty.';
                  }
                  if (value.trim().length < 5) {
                    return 'Title must be at least 5 characters long.';
                  }
                  return null;
                },
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: 'Discussion Content',
                  hintText: 'Share your thoughts or questions in detail...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest
                      .withOpacity(0.5),
                ),
                maxLines: 8,
                keyboardType: TextInputType.multiline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Content cannot be empty.';
                  }
                  if (value.trim().length < 10) {
                    return 'Content must be at least 10 characters long.';
                  }
                  return null;
                },
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 24.0),
              ElevatedButton.icon(
                icon: const Icon(Icons.save_alt_outlined),
                label: const Text('Save Changes'),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
