// lib/features/community/presentation/screens/create_topic_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sud_qollanma/features/auth/presentation/providers/auth_notifier.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import '../providers/community_provider.dart';

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
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context);
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    final user = authNotifier.appUser;
    final userId = user?.id;
    final firebaseUser = authNotifier.currentUser;

    if (firebaseUser == null || userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(l10n?.mustBeLoggedInToCreateTopic ?? 'Login required')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<CommunityProvider>(context, listen: false).createTopic(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        userId: firebaseUser.id,
        userName: user!.name,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(l10n?.topicCreatedSuccess ?? 'Topic created!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted)
        setState(() {
          _isLoading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
          title: Text(l10n?.createTopicScreenTitle ?? 'Start Discussion')),
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
                      onPressed: _createTopic,
                      child: Text(l10n?.createTopicButtonText ?? 'Create'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
