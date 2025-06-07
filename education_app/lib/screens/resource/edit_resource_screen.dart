// lib/screens/resource/edit_resource_screen.dart

import 'package:education_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider
import '../../models/resource.dart';
import '../../services/resource_service.dart';
// Import AuthNotifier if needed for author details, though typically author doesn't change on edit
// import '../../models/auth_notifier.dart';

class EditResourceScreen extends StatefulWidget {
  final Resource resourceToEdit;

  const EditResourceScreen({
    super.key,
    required this.resourceToEdit,
    // The 'resource' parameter was redundant as resourceToEdit serves the purpose.
    // If it was intended for something else, clarify. For now, assuming it's not needed.
  });

  @override
  State<EditResourceScreen> createState() => _EditResourceScreenState();
}

class _EditResourceScreenState extends State<EditResourceScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _urlController;
  late String
  _authorName; // Author is usually not changed during edit by the editor
  late String _authorId; // Author ID also typically doesn't change
  late ResourceType _selectedResourceType;
  late DateTime _createdAt; // Preserve original creation date

  bool _isLoading = false;
  // final ResourceService _resourceService = ResourceService(); // Use Provider

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.resourceToEdit.title);
    _descriptionController = TextEditingController(
      text: widget.resourceToEdit.description,
    );
    _urlController = TextEditingController(
      text: widget.resourceToEdit.url ?? '',
    );
    _selectedResourceType = widget.resourceToEdit.type;
    _authorName = widget.resourceToEdit.author;
    _authorId =
        widget
            .resourceToEdit
            .authorId; // Ensure authorId is part of Resource model
    _createdAt =
        widget.resourceToEdit.createdAt; // Preserve original creation date
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
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

    try {
      final updatedResource = Resource(
        id: widget.resourceToEdit.id, // Keep original ID
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        author:
            _authorName, // Author name usually doesn't change on edit by others
        authorId: _authorId, // Author ID MUST remain the same for ownership
        type: _selectedResourceType,
        url:
            _urlController.text.trim().isEmpty
                ? null
                : _urlController.text.trim(),
        createdAt: _createdAt, // Keep original creation date
      );

      await resourceService.updateResource(updatedResource);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.resourceUpdatedSuccess ?? 'Resource updated successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(updatedResource);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.resourceUpdatedError(e.toString()) ??
                  'Error updating resource: $e',
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
        title: Text(l10n?.editResourceScreenTitle ?? 'Edit Resource'),
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
              onPressed: _saveChanges,
              tooltip: l10n?.saveButtonText ?? 'Save Changes',
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
                  labelText:
                      l10n?.createResourceTitleLabel ??
                      'Title', // Reusing create screen labels
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
                      l10n?.createResourceDescriptionLabel ??
                      'Description', // Reusing
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

              // Author Field (Read-only, pre-filled from original resource)
              TextFormField(
                initialValue: _authorName,
                decoration: InputDecoration(
                  labelText:
                      l10n?.createResourceAuthorLabel ?? 'Author', // Reusing
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
                  labelText:
                      l10n?.createResourceTypeLabel ??
                      'Resource Type', // Reusing
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
                  // Still important to validate, even if pre-filled
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

              // URL Field (Optional) - Enhanced Validation
              TextFormField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText:
                      l10n?.createResourceUrlLabel ??
                      'URL (Optional)', // Reusing
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

// Ensure your AppLocalizations extension (or however you manage them) has these keys
// from CreateResourceScreen, as we are reusing them.
// Example (add to your existing extension or create one if these are not globally available through l10n directly)
// extension AppLocalizationsEditResourceMessages on AppLocalizations? {
//   String get editResourceScreenTitle => this?.editResourceScreenTitle ?? 'Edit Resource';
//   String get resourceUpdatedSuccess => this?.resourceUpdatedSuccess ?? 'Resource updated successfully!';
//   String resourceUpdatedError(String error) => this?.resourceUpdatedError(error) ?? 'Error updating resource: $error';
//   // Add other keys like saveButtonText if they are specific or not covered by CreateResourceScreen's l10n keys.
// }
