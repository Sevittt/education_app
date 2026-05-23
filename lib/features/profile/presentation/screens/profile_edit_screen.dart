// lib/screens/profile/profile_edit_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';

import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sud_qollanma/features/auth/domain/entities/app_user.dart'; // Your custom AppUser model
import 'package:sud_qollanma/features/auth/presentation/providers/auth_notifier.dart'; // To get user data and update
import 'package:sud_qollanma/shared/widgets/user_avatar.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  String? _selectedAvatarUrl;

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
      _selectedAvatarUrl = appUser?.profilePictureUrl;

      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
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
    final currentappUser = authNotifier.appUser!;

    try {
      // Create a new AppUser object with the updated details using copyWith
      final userToSave = currentappUser.copyWith(
        name: _nameController.text.trim(),
        bio:
            _bioController.text.trim().isNotEmpty
                ? _bioController.text.trim()
                : null,
        profilePictureUrl: _selectedAvatarUrl,
      );

      final success = await authNotifier.updateUserProfile(userToSave);

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
            content: Text(l10n.errorGeneric(error.toString())),
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

  void _openAvatarSelection() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Avatarni tanlang', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  for (int i = 1; i <= 4; i++)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                           _selectedAvatarUrl = 'assets/avatars/avatar_$i.png';
                        });
                        Navigator.pop(context);
                      },
                      child: UserAvatar(
                        profilePictureUrl: 'assets/avatars/avatar_$i.png',
                        radius: 35,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.upload),
                  label: const Text('Gallereyadan yuklash'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _pickAndUploadImage();
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery, 
      maxWidth: 512, 
      maxHeight: 512,
      imageQuality: 80,
    );

    if (image == null) return;

    setState(() => _isLoading = true);
    try {
    if (!mounted) return;
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
      final userId = authNotifier.appUser!.id;
      final storageRef = FirebaseStorage.instance.ref().child('profile_images/$userId/avatar.jpg');
      
      final Uint8List data = await image.readAsBytes();
      await storageRef.putData(data, SettableMetadata(contentType: 'image/jpeg'));
      final downloadUrl = await storageRef.getDownloadURL();
      
      setState(() {
        _selectedAvatarUrl = downloadUrl;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xatolik: Yuklash muvaffaqiyatsiz bo\'ldi. ($e)'), backgroundColor: Colors.red));
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
              const SizedBox(height: 16.0),
              Center(
                child: UserAvatar(
                  profilePictureUrl: _selectedAvatarUrl,
                  radius: 50,
                  isEditMode: true,
                  onEditTap: _openAvatarSelection,
                ),
              ),
              const SizedBox(height: 32.0),
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
                decoration: InputDecoration(
                  labelText: l10n.bioOptionalLabel,
                  hintText: 'Tell us a little about yourself', // You might want to localize this too later
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.info_outline),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
