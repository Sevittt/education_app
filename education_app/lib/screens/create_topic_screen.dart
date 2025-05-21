// lib/screens/create_topic_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import '../models/discussion_topic.dart';
import '../data/dummy_data.dart'; // Still used to add to the dummy list for now
import '../models/auth_notifier.dart'; // Import AuthNotifier
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

class CreateTopicScreen extends StatefulWidget {
  const CreateTopicScreen({super.key});

  @override
  State<CreateTopicScreen> createState() => _CreateTopicScreenState();
}

class _CreateTopicScreenState extends State<CreateTopicScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _createTopic() {
    if (!_formKey.currentState!.validate()) {
      // If form is not valid, show a SnackBar and return
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please correct the errors in the form.')),
      );
      return;
    }

    // Get AuthNotifier to access the current user
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    final currentUser = authNotifier.currentUser;

    if (currentUser == null) {
      // This should ideally not happen if the screen is only accessible when logged in.
      // Handle case where user is somehow null (e.g., show error, prevent topic creation)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Error: No authenticated user found. Please log in again.',
          ),
        ),
      );
      return;
    }

    final newTitle = _titleController.text.trim();
    final newContent = _contentController.text.trim();

    // Use the UID of the currently logged-in Firebase user
    final authorId = currentUser.uid;

    final newTopicId = uuid.v4();

    final newTopic = DiscussionTopic(
      id: newTopicId,
      title: newTitle,
      content: newContent,
      authorId: authorId, // Using actual Firebase User ID
      createdAt: DateTime.now(),
      commentIds: [],
    );

    // Add to the dummy data list (for session persistence with dummy data)
    // In a real app with Firestore, you would add this to your Firestore collection:
    // E.g., await FirebaseFirestore.instance.collection('discussionTopics').doc(newTopicId).set(newTopic.toMap());
    dummyDiscussionTopics.add(newTopic);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Topic "${newTopic.title}" created by user ${authorId.substring(0, 6)}... !',
          ),
        ),
      );
      Navigator.pop(context, true); // Signal refresh
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Start New Discussion'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.send_outlined),
            onPressed: _createTopic,
            tooltip: 'Create Topic',
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
                  fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                ),
                style: theme.textTheme.bodyLarge,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title cannot be empty.';
                  }
                  if (value.trim().length < 5) {
                    return 'Title must be at least 5 characters long.';
                  }
                  return null;
                },
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
                  fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                ),
                maxLines: 8,
                keyboardType: TextInputType.multiline,
                style: theme.textTheme.bodyLarge,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Content cannot be empty.';
                  }
                  if (value.trim().length < 10) {
                    return 'Content must be at least 10 characters long.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),
              ElevatedButton.icon(
                icon: const Icon(Icons.post_add_outlined),
                label: const Text('Create Discussion Topic'),
                onPressed: _createTopic,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  textStyle: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
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
