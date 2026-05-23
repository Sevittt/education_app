// lib/screens/resource/create_resource_screen.dart

//import 'package:education_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import 'package:sud_qollanma/features/library/domain/entities/resource_entity.dart';
import 'package:sud_qollanma/features/library/presentation/providers/library_provider.dart';
import 'package:sud_qollanma/features/auth/presentation/providers/auth_notifier.dart';

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class CreateResourceScreen extends StatefulWidget {
  const CreateResourceScreen({super.key});

  @override
  State<CreateResourceScreen> createState() => _CreateResourceScreenState();
}

class _CreateResourceScreenState extends State<CreateResourceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _authorName = ''; // This will be pre-filled

  ResourceType _selectedResourceType = ResourceType.eSud; // Default type

  bool _isLoading = false;
  
  File? _selectedFile;
  String? _selectedFileName;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

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
        return l10n.resourceTypeOther;
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _selectedFileName = result.files.single.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fayl tanlashda xatolik: $e')),
        );
      }
    }
  }

  Future<void> _saveResource() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final l10n = AppLocalizations.of(context);
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);

    final userId = context.read<AuthNotifier>().appUser?.id;
    final String? currentUserNameFromAppUser = authNotifier.appUser?.name;

    if (userId == null || userId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.mustBeLoggedInToCreateResource ??
                  'Resurs yaratish uchun tizimga kirgan bo\'lishingiz kerak.',
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
                  'Profilingiz ma\'lumotlari to\'liq emas.',
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

    // Clean Architecture: Use LibraryProvider
    final libraryProvider = Provider.of<LibraryProvider>(
      context,
      listen: false,
    );

    try {
      String? downloadUrl;
      
      // Handle file upload if a file was selected
      if (_selectedFile != null) {
        setState(() {
          _isUploading = true;
        });
        
        final extension = path.extension(_selectedFile!.path);
        final fileName = '${const Uuid().v4()}$extension';
        final storageRef = FirebaseStorage.instance.ref().child('resources_pdfs/$fileName');
        
        final uploadTask = storageRef.putFile(_selectedFile!);
        
        uploadTask.snapshotEvents.listen((event) {
          if (mounted) {
            setState(() {
              _uploadProgress = event.bytesTransferred / event.totalBytes;
            });
          }
        });
        
        final snapshot = await uploadTask;
        downloadUrl = await snapshot.ref.getDownloadURL();
      }

      final newResource = ResourceEntity(
        id: '', // ID will be assigned by backend/firebase
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        author: currentUserNameFromAppUser,
        authorId: userId,
        type: _selectedResourceType,
        url: downloadUrl,
        createdAt: DateTime.now(),
      );

      await libraryProvider.createResource(newResource);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.resourceAddedSuccess ?? 'Resurs muvaffaqiyatli qo\'shildi!',
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
                  'Xatolik: $e',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isUploading = false;
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
                initialValue: _selectedResourceType,
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

              // File Upload Section
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.outline),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Qo'llanma fayli (ixtiyoriy)",
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _pickFile,
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Fayl tanlash'),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: Text(
                            _selectedFileName ?? 'Fayl tanlanmagan',
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_selectedFile != null)
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () {
                              setState(() {
                                _selectedFile = null;
                                _selectedFileName = null;
                              });
                            },
                          ),
                      ],
                    ),
                    if (_isUploading) ...[
                      const SizedBox(height: 12.0),
                      LinearProgressIndicator(value: _uploadProgress),
                      const SizedBox(height: 4.0),
                      Text(
                        'Yuklanmoqda: ${(_uploadProgress * 100).toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24.0),
            ],
          ),
        ),
      ),
    );
  }
}
