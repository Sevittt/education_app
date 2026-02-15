// lib/features/community/presentation/screens/create_topic_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sud_qollanma/features/auth/presentation/providers/auth_notifier.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import 'package:sud_qollanma/features/community/presentation/providers/community_provider.dart';
import '../../domain/entities/discussion_topic.dart';

class CreateTopicScreen extends StatefulWidget {
  final DiscussionTopic? topic;

  const CreateTopicScreen({super.key, this.topic});

  @override
  State<CreateTopicScreen> createState() => _CreateTopicScreenState();
}

class _CreateTopicScreenState extends State<CreateTopicScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.topic != null) {
      _titleController.text = widget.topic!.title;
      _contentController.text = widget.topic!.content;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context);
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    final user = authNotifier.appUser;
    final firebaseUser = authNotifier.currentUser;

    if (firebaseUser == null || user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n?.mustBeLoggedInToCreateTopic ?? 'Login required')),
      );
      return;
    }

    setState(() { _isLoading = true; });

    try {
      final provider = Provider.of<CommunityProvider>(context, listen: false);
      
      if (widget.topic != null) {
        // Update existing
        await provider.updateTopic(
          topicId: widget.topic!.id,
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
        );
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Topic updated successfully')),
          );
        }
      } else {
        // Create new
        await provider.createTopic(
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          userId: firebaseUser.id,
          userName: user.name,
        );
         if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n?.topicCreatedSuccess ?? 'Topic created!')),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isEditing = widget.topic != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Topic' : (l10n?.createTopicScreenTitle ?? 'Start Discussion'))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: l10n?.createTopicTitleLabel ?? 'Title',
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: l10n?.createTopicContentLabel ?? 'Content',
                  border: const OutlineInputBorder(),
                ),
                maxLines: 8,
                validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _handleSubmit,
                      child: Text(isEditing ? 'Update' : (l10n?.createTopicButtonText ?? 'Create')),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
