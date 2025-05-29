// lib/screens/create_resource_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // If you need it for user ID for author
import '../../models/resource.dart'; // Your Resource model
import '../../models/auth_notifier.dart'; // To get current user for author field
import '../../services/resource_service.dart'; // Your ResourceService
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
  // Author will be pre-filled from the logged-in teacher
  String _authorName = '';

  ResourceType _selectedResourceType = ResourceType.article; // Default type

  bool _isLoading = false;
  final ResourceService _resourceService = ResourceService();

  @override
  void initState() {
    super.initState();
    // Get the current user's name to pre-fill the author field
    // Ensure AuthNotifier is listened to if you want this to update dynamically,
    // but for initState, listen: false is fine if it's already populated.
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
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
      return; // If form is not valid, do nothing
    }

    setState(() {
      _isLoading = true;
    });

    final l10n = AppLocalizations.of(context);

    try {
      final newResource = Resource(
        id: '', // Firestore will generate an ID when using .add()
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        author: _authorName, // Use the logged-in teacher's name
        type: _selectedResourceType,
        url:
            _urlController.text.trim().isEmpty
                ? null
                : _urlController.text.trim(),
        createdAt: DateTime.now(),
      );

      // Use the addResource method from your service
      await _resourceService.addResource(newResource);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.resourceAddedSuccess ?? 'Resource added successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(
          context,
        ).pop(newResource); // Pop and return the new resource
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
            // Use ListView for scrollability if form gets long
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
                  if (value == null || value.trim().isEmpty) {
                    return l10n?.createResourceValidationEmpty(
                          l10n.createResourceTitleLabel,
                        ) ??
                        'Please enter a title';
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
                  if (value == null || value.trim().isEmpty) {
                    return l10n?.createResourceValidationEmpty(
                          l10n.createResourceDescriptionLabel,
                        ) ??
                        'Please enter a description';
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
                          // Capitalize first letter
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
                    final uri = Uri.tryParse(value);
                    if (uri == null ||
                        (!uri.isScheme('HTTPS') && !uri.isScheme('HTTP'))) {
                      return l10n?.createResourceValidationInvalidUrl ??
                          'Please enter a valid URL';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),
              // Save button is now in AppBar
            ],
          ),
        ),
      ),
    );
  }
}
