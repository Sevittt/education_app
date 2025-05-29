// lib/screens/edit_resource_screen.dart

import 'package:flutter/material.dart';
import '../../models/resource.dart';
import '../../services/resource_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditResourceScreen extends StatefulWidget {
  final Resource resourceToEdit; // The resource to be edited

  const EditResourceScreen({
    super.key,
    required this.resourceToEdit,
    required Resource resource,
  });

  @override
  State<EditResourceScreen> createState() => _EditResourceScreenState();
}

class _EditResourceScreenState extends State<EditResourceScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _urlController;
  late String _authorName; // Author might be editable by admin, or fixed
  late ResourceType _selectedResourceType;

  bool _isLoading = false;
  final ResourceService _resourceService = ResourceService();

  @override
  void initState() {
    super.initState();

    // Pre-fill the form fields with the existing resource data
    _titleController = TextEditingController(text: widget.resourceToEdit.title);
    _descriptionController = TextEditingController(
      text: widget.resourceToEdit.description,
    );
    _urlController = TextEditingController(
      text: widget.resourceToEdit.url ?? '',
    );
    _selectedResourceType = widget.resourceToEdit.type;
    _authorName =
        widget
            .resourceToEdit
            .author; // Or fetch current user if author can change

    // Example: If you want the author to be the current editor if they are a teacher
    // final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    // if (authNotifier.appUser?.role == UserRole.teacher || authNotifier.appUser?.role == UserRole.admin) {
    //   _authorName = authNotifier.appUser?.name ?? widget.resourceToEdit.author;
    // }
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

    try {
      // Create an updated Resource object
      // Important: Keep the original ID and createdAt timestamp
      final updatedResource = Resource(
        id: widget.resourceToEdit.id, // Keep original ID
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        author: _authorName, // Decide if author should be updatable
        type: _selectedResourceType,
        url:
            _urlController.text.trim().isEmpty
                ? null
                : _urlController.text.trim(),
        createdAt:
            widget.resourceToEdit.createdAt, // Keep original creation date
      );

      await _resourceService.updateResource(updatedResource);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.resourceUpdatedSuccess ?? 'Resource updated successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(
          context,
        ).pop(updatedResource); // Pop and return the updated resource
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

              TextFormField(
                // For simplicity, author is not directly editable here,
                // but you could make it so, or update it based on the current editor.
                initialValue: _authorName,
                decoration: InputDecoration(
                  labelText: l10n?.createResourceAuthorLabel ?? 'Author',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                readOnly: true, // Or make it editable if needed
              ),
              const SizedBox(height: 16.0),

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
            ],
          ),
        ),
      ),
    );
  }
}
