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
  // Use Provider for ResourceService if consistently used, or instantiate as needed
  // final ResourceService _resourceService = ResourceService(); // Or Provider.of

  @override
  void initState() {
    super.initState();
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    // Use appUser's name if available, otherwise fallback to a default or previously set _authorName
    _authorName = authNotifier.appUser?.name ?? 'Unknown Teacher';
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

    setState(() {
      _isLoading = true;
    });

    final l10n = AppLocalizations.of(context);
    final resourceService = Provider.of<ResourceService>(
      context,
      listen: false,
    ); // Get service via Provider
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    final String currentUserId =
        authNotifier.currentUser?.uid ?? 'unknown_user_id';
    final String currentUserName =
        _authorName; // Already set in initState from appUser

    try {
      final newResource = Resource(
        id: '', // Firestore will generate an ID
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        author: currentUserName,
        authorId: currentUserId, // Make sure authorId is populated
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
              // Title Field - Enhanced Validation
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

              // Description Field - Enhanced Validation
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
                    // Example max length
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
                        (!uri.isScheme('https') && !uri.isScheme('HTTP'))) {
                      return l10n?.createResourceValidationInvalidUrl ??
                          'Please enter a valid URL (starting with http or https)';
                    }
                    // Optional: More robust URL validation if needed using a regex or a package
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

// Add new localization keys to your AppLocalizations extension/ARB files
// Example (add to your existing extension or create one)
extension AppLocalizationsValidationMessages on AppLocalizations? {
  String createResourceValidationMinLength(String fieldName, int length) =>
      this?.createResourceValidationMinLength(fieldName, length) ??
      '$fieldName must be at least $length characters long';
  String createResourceValidationMaxLength(String fieldName, int length) =>
      this?.createResourceValidationMaxLength(fieldName, length) ??
      '$fieldName cannot exceed $length characters';
  // Ensure createResourceValidationEmpty, createResourceValidationSelect, createResourceValidationInvalidUrl
  // are also defined in your .arb files and the extension if you use them.
}
