// lib/screens/resource/edit_resource_screen.dart

// import 'package:education_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider
import 'package:sud_qollanma/l10n/app_localizations.dart';
import '../../models/resource.dart';
import '../../services/resource_service.dart';

class EditResourceScreen extends StatefulWidget {
  final Resource resourceToEdit;

  const EditResourceScreen({super.key, required this.resourceToEdit});

  @override
  State<EditResourceScreen> createState() => _EditResourceScreenState();
}

class _EditResourceScreenState extends State<EditResourceScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _urlController;
  late String _authorName;
  late String _authorId;
  late ResourceType _selectedResourceType;
  late DateTime _createdAt;

  bool _isLoading = false;

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
    _authorId = widget.resourceToEdit.authorId;
    _createdAt = widget.resourceToEdit.createdAt;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  // O'ZGARISH: Enum'ni matnga o'girish funksiyasi
  String _getResourceTypeText(ResourceType type, AppLocalizations l10n) {
    switch (type) {
      case ResourceType.eSud:
        return 'E-SUD';
      case ResourceType.adolat:
        return 'Adolat AT';
      case ResourceType.jibSud:
        return 'JIB.SUD.UZ';
      case ResourceType.edoSud:
        return 'EDO.SUD.UZ';
      case ResourceType.other:
        return 'Boshqalar';
      default:
        return 'Noma\'lum';
    }
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
    );

    try {
      final updatedResource = Resource(
        id: widget.resourceToEdit.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        author: _authorName,
        authorId: _authorId,
        type: _selectedResourceType,
        url:
            _urlController.text.trim().isEmpty
                ? null
                : _urlController.text.trim(),
        createdAt: _createdAt,
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editResourceScreenTitle),
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
              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: l10n.createResourceTitleLabel,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.title),
                ),
                validator: (value) {
                  final trimmedValue = value?.trim();
                  if (trimmedValue == null || trimmedValue.isEmpty) {
                    return l10n.createResourceValidationEmpty(
                      l10n.createResourceTitleLabel,
                    );
                  }
                  if (trimmedValue.length < 5) {
                    return l10n.createResourceValidationMinLength(
                      l10n.createResourceTitleLabel,
                      5,
                    );
                  }
                  if (trimmedValue.length > 100) {
                    return l10n.createResourceValidationMaxLength(
                      l10n.createResourceTitleLabel,
                      100,
                    );
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: l10n.createResourceDescriptionLabel,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.description),
                ),
                maxLines: 3,
                validator: (value) {
                  final trimmedValue = value?.trim();
                  if (trimmedValue == null || trimmedValue.isEmpty) {
                    return l10n.createResourceValidationEmpty(
                      l10n.createResourceDescriptionLabel,
                    );
                  }
                  if (trimmedValue.length < 10) {
                    return l10n.createResourceValidationMinLength(
                      l10n.createResourceDescriptionLabel,
                      10,
                    );
                  }
                  if (trimmedValue.length > 500) {
                    return l10n.createResourceValidationMaxLength(
                      l10n.createResourceDescriptionLabel,
                      500,
                    );
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Author Field (Read-only, pre-filled from original resource)
              TextFormField(
                initialValue: _authorName,
                decoration: InputDecoration(
                  labelText: l10n.createResourceAuthorLabel,
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
                  labelText: l10n.createResourceTypeLabel,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.category_outlined),
                ),
                // O'ZGARISH: Yangi enum qiymatlari bilan list hosil qilish
                items:
                    ResourceType.values.map((ResourceType type) {
                      return DropdownMenuItem<ResourceType>(
                        value: type,
                        child: Text(_getResourceTypeText(type, l10n)),
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
                    return l10n.createResourceValidationSelect(
                      l10n.createResourceTypeLabel,
                    );
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // URL Field (Optional)
              TextFormField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: l10n.createResourceUrlLabel,
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
                      return l10n.createResourceValidationInvalidUrl;
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
