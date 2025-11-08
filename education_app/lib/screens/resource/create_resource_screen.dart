// lib/screens/resource/create_resource_screen.dart

//import 'package:education_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import '../../models/resource.dart';
import '../../models/auth_notifier.dart';
import '../../services/resource_service.dart';

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

  ResourceType _selectedResourceType = ResourceType.eSud; // Default type

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
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

  Future<void> _saveResource() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final l10n = AppLocalizations.of(context);
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);

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
      return;
    }

    if (currentUserNameFromAppUser == null ||
        currentUserNameFromAppUser.isEmpty ||
        currentUserNameFromAppUser == 'Unknown Teacher' ||
        _authorName == 'Unknown Teacher') {
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
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final resourceService = Provider.of<ResourceService>(
      context,
      listen: false,
    );

    try {
      final newResource = Resource(
        id: '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        author: currentUserNameFromAppUser,
        authorId: currentUserId,
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
    final l10n = AppLocalizations.of(context)!;
    final authNotifier = Provider.of<AuthNotifier>(context);
    _authorName = authNotifier.appUser?.name ?? 'Unknown Teacher';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createResourceScreenTitle),
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

              // Author Field (Read-only, pre-filled)
              TextFormField(
                key: ValueKey(_authorName),
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
