// lib/screens/profile/profile_edit_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:education_app/l10n/app_localizations.dart';

import '../../models/users.dart'; // Your custom User model
import '../../models/auth_notifier.dart'; // To get user data and update

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _photoUrlController;

  // This flag ensures we only initialize the controllers once
  bool _isInitialized = false;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // We use didChangeDependencies because it's called after initState
    // and we can safely access the Provider context.
    if (!_isInitialized) {
      final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
      final appUser = authNotifier.appUser;

      _nameController = TextEditingController(text: appUser?.name ?? '');
      _bioController = TextEditingController(text: appUser?.bio ?? '');
      _photoUrlController = TextEditingController(
        text: appUser?.profilePictureUrl ?? '',
      );

      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isLoading = true);

    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);

    // It's safe to assume appUser is not null because this screen
    // should only be accessible to logged-in users.
    final currentAppUser = authNotifier.appUser!;

    try {
      // Create a new User object with the updated details using copyWith
      final userToSave = currentAppUser.copyWith(
        name: _nameController.text.trim(),
        bio:
            _bioController.text.trim().isNotEmpty
                ? _bioController.text.trim()
                : null,
        profilePictureUrl:
            _photoUrlController.text.trim().isNotEmpty
                ? _photoUrlController.text.trim()
                : null,
      );

      final success = await authNotifier.updateUserProfileData(userToSave);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.resourceUpdatedSuccess),
            ), // You can create a more specific message
          );
          Navigator.of(context).pop(); // Go back to the profile screen
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                authNotifier.errorMessage ?? 'Failed to update profile.',
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: ${error.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator until the controllers are initialized
    if (!_isInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.editProfileButtonText),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editProfileButtonText),
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
              icon: const Icon(Icons.save),
              onPressed: _saveProfile,
              tooltip: l10n.saveButtonText,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText:
                      l10n.createResourceAuthorLabel, // Re-using 'Author' as 'Name'
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.createResourceValidationEmpty(
                      l10n.createResourceAuthorLabel,
                    );
                  }
                  if (value.trim().length < 3) {
                    return l10n.createResourceValidationMinLength(
                      l10n.createResourceAuthorLabel,
                      3,
                    );
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(
                  labelText: 'Bio (Optional)',
                  hintText: 'Tell us a little about yourself',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.info_outline),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _photoUrlController,
                decoration: const InputDecoration(
                  labelText: 'Profile Picture URL (Optional)',
                  hintText: 'https://example.com/image.png',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link),
                ),
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final uri = Uri.tryParse(value.trim());
                    if (uri == null ||
                        !uri.isScheme('http') && !uri.isScheme('https')) {
                      return l10n.createResourceValidationInvalidUrl;
                    }
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
