// lib/screens/resource/create_resource_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/resource.dart';
import '../../models/auth_notifier.dart';
import '../../services/resource_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CreateResourceScreen extends StatefulWidget {
  const CreateResourceScreen({super.key});

  @override
  State<CreateResourceScreen> createState() => _CreateResourceScreenState();
}

class _CreateResourceScreenState extends State<CreateResourceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _urlController = TextEditingController();
  String _authorName = ''; // This will be pre-filled

  ResourceType _selectedResourceType = ResourceType.article; // Default type

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // It's important that AuthNotifier has had a chance to load the user profile
    // by the time this screen is used.
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    _authorName = authNotifier.appUser?.name ?? 'Unknown Teacher';
    // If authNotifier.appUser is null, _authorName will be 'Unknown Teacher'.
    // We'll check this before saving.
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _saveResource() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final l10n = AppLocalizations.of(context);
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);

    // --- ADDED CHECKS FOR VALID USER DATA ---
    final String? currentUserId = authNotifier.currentUser?.uid;
    final String? currentUserNameFromAppUser = authNotifier.appUser?.name;

    if (currentUserId == null || currentUserId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.mustBeLoggedInToCreateResource ??
                  'You must be logged in to create a resource.',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      return; // Stop execution
    }

    if (currentUserNameFromAppUser == null ||
        currentUserNameFromAppUser.isEmpty ||
        currentUserNameFromAppUser ==
            'Unknown Teacher' || // Check against default/placeholder
        _authorName == 'Unknown Teacher') {
      // Also check the initialized _authorName
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.profileIncompleteToCreateResource ??
                  'Your profile information is incomplete. Please update your name in your profile.',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      return; // Stop execution
    }
    // --- END OF ADDED CHECKS ---

    setState(() {
      _isLoading = true;
    });

    final resourceService = Provider.of<ResourceService>(
      context,
      listen: false,
    );

    try {
      final newResource = Resource(
        id: '', // Firestore will generate an ID
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        author: currentUserNameFromAppUser, // Use the verified name
        authorId: currentUserId, // Use the verified ID
        type: _selectedResourceType,
        url:
            _urlController.text.trim().isEmpty
                ? null
                : _urlController.text.trim(),
        createdAt: DateTime.now(),
      );

      await resourceService.addResource(newResource);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.resourceAddedSuccess ?? 'Resource added successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(newResource);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.resourceAddedError(e.toString()) ??
                  'Error adding resource: $e',
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
    // Re-fetch authorName from AuthNotifier in build in case it has updated
    // This ensures the read-only field reflects the latest profile name if possible
    final authNotifier = Provider.of<AuthNotifier>(context);
    _authorName = authNotifier.appUser?.name ?? 'Unknown Teacher';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.createResourceScreenTitle ?? 'Create New Resource'),
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
              onPressed: _saveResource,
              tooltip: l10n?.saveButtonText ?? 'Save',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: l10n?.createResourceTitleLabel ?? 'Title',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.title),
                ),
                validator: (value) {
                  final trimmedValue = value?.trim();
                  if (trimmedValue == null || trimmedValue.isEmpty) {
                    return l10n?.createResourceValidationEmpty(
                          l10n.createResourceTitleLabel,
                        ) ??
                        'Please enter a title';
                  }
                  if (trimmedValue.length < 5) {
                    return l10n?.createResourceValidationMinLength(
                          l10n.createResourceTitleLabel,
                          5,
                        ) ??
                        'Title must be at least 5 characters long';
                  }
                  if (trimmedValue.length > 100) {
                    return l10n?.createResourceValidationMaxLength(
                          l10n.createResourceTitleLabel,
                          100,
                        ) ??
                        'Title cannot exceed 100 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText:
                      l10n?.createResourceDescriptionLabel ?? 'Description',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.description),
                ),
                maxLines: 3,
                validator: (value) {
                  final trimmedValue = value?.trim();
                  if (trimmedValue == null || trimmedValue.isEmpty) {
                    return l10n?.createResourceValidationEmpty(
                          l10n.createResourceDescriptionLabel,
                        ) ??
                        'Please enter a description';
                  }
                  if (trimmedValue.length < 10) {
                    return l10n?.createResourceValidationMinLength(
                          l10n.createResourceDescriptionLabel,
                          10,
                        ) ??
                        'Description must be at least 10 characters long';
                  }
                  if (trimmedValue.length > 500) {
                    return l10n?.createResourceValidationMaxLength(
                          l10n.createResourceDescriptionLabel,
                          500,
                        ) ??
                        'Description cannot exceed 500 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Author Field (Read-only, pre-filled)
              TextFormField(
                // Use a Key to ensure the initialValue updates if _authorName changes
                key: ValueKey(_authorName),
                initialValue: _authorName,
                decoration: InputDecoration(
                  labelText: l10n?.createResourceAuthorLabel ?? 'Author',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                readOnly: true,
              ),
              const SizedBox(height: 16.0),

              // Resource Type Dropdown
              DropdownButtonFormField<ResourceType>(
                value: _selectedResourceType,
                decoration: InputDecoration(
                  labelText: l10n?.createResourceTypeLabel ?? 'Resource Type',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.category_outlined),
                ),
                items:
                    ResourceType.values.map((ResourceType type) {
                      return DropdownMenuItem<ResourceType>(
                        value: type,
                        child: Text(
                          type.name[0].toUpperCase() + type.name.substring(1),
                        ),
                      );
                    }).toList(),
                onChanged: (ResourceType? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedResourceType = newValue;
                    });
                  }
                },
                validator: (value) {
                  if (value == null) {
                    return l10n?.createResourceValidationSelect(
                          l10n.createResourceTypeLabel,
                        ) ??
                        'Please select a type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // URL Field (Optional)
              TextFormField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: l10n?.createResourceUrlLabel ?? 'URL (Optional)',
                  hintText: 'https://example.com/resource',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.link),
                ),
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final trimmedValue = value.trim();
                    final uri = Uri.tryParse(trimmedValue);
                    if (uri == null ||
                        (!uri.isScheme('HTTPS') && !uri.isScheme('HTTP'))) {
                      return l10n?.createResourceValidationInvalidUrl ??
                          'Please enter a valid URL (starting with http or https)';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),
            ],
          ),
        ),
      ),
    );
  }
}

// You'll need to add these new localization keys to your .arb files
// and your AppLocalizations extension:
// Example for your AppLocalizations extension (if you have one):
// extension AppLocalizationsCreateResourceMessages on AppLocalizations? {
//   String get mustBeLoggedInToCreateResource =>
//       this?.mustBeLoggedInToCreateResource ?? 'You must be logged in to create a resource.';
//   String get profileIncompleteToCreateResource =>
//       this?.profileIncompleteToCreateResource ?? 'Your profile information is incomplete. Please update your name in your profile.';
// }
// And in your intl_en.arb (and other language files):
// "mustBeLoggedInToCreateResource": "You must be logged in to create a resource.",
// "profileIncompleteToCreateResource": "Your profile information is incomplete. Please update your name in your profile."
