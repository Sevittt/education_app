// lib/screens/profile_edit_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth; // Aliased

// Ensure User and UserRole are imported from your models file
import '../../models/users.dart'; // Your custom User model
import '../../models/auth_notifier.dart'; // To get user data and update

class ProfileEditScreen extends StatefulWidget {
  // No longer taking currentUser in constructor
  const ProfileEditScreen({super.key});

  static const routeName = '/profile-edit';

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _photoUrlController;
  late UserRole _selectedRole;
  bool _isInitialized =
      false; // To ensure initState logic runs once with context

  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
      final fb_auth.User? firebaseUser = authNotifier.currentUser;
      final User? appUser = authNotifier.appUser;

      _nameController = TextEditingController(
        text: appUser?.name ?? firebaseUser?.displayName ?? '',
      );
      _bioController = TextEditingController(text: appUser?.bio ?? '');
      _photoUrlController = TextEditingController(
        text: appUser?.profilePictureUrl ?? firebaseUser?.photoURL ?? '',
      );
      _selectedRole =
          appUser?.role ?? UserRole.student; // Default if no appUser

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
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    final fb_auth.User? firebaseUser = authNotifier.currentUser;
    final User? currentAppUser = authNotifier.appUser;

    if (firebaseUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No authenticated user found.')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // Create an updated User object (your custom model)
      final userToSave = User(
        id: firebaseUser.uid, // Crucial: Use Firebase UID as the ID
        email: firebaseUser.email, // Get email from firebaseUser
        name: _nameController.text.trim(),
        bio:
            _bioController.text.trim().isNotEmpty
                ? _bioController.text.trim()
                : null,
        profilePictureUrl:
            _photoUrlController.text.trim().isNotEmpty
                ? _photoUrlController.text.trim()
                : null,
        role: _selectedRole,
        // Preserve existing registrationDate, or set if it's a new profile
        registrationDate:
            currentAppUser?.registrationDate ??
            firebaseUser.metadata.creationTime ??
            DateTime.now(),
        lastLogin:
            currentAppUser
                ?.lastLogin, // This would typically be updated on login
      );

      final success = await authNotifier.updateUserProfileData(userToSave);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        if (mounted) {
          Navigator.of(context).pop(userToSave); // Pass back the updated user
        }
      } else {
        // Error message would be set in authNotifier if updateUserProfileData returns false due to an error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authNotifier.errorMessage ?? 'Failed to update profile.',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: ${error.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
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
    // If not initialized yet (e.g. first build after didChangeDependencies might not have run),
    // show a loading indicator or an empty container.
    if (!_isInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(color: Colors.white),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveProfile,
              tooltip: 'Save Profile',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    if (value.trim().length < 3) {
                      return 'Name must be at least 3 characters long';
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
                    hintText: 'assets/images/your_pic.jpg or https://...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.link),
                  ),
                  keyboardType: TextInputType.url,
                  validator: (value) {
                    if (value != null &&
                        value.isNotEmpty &&
                        !value.startsWith('assets/') &&
                        !value.startsWith('http')) {
                      return 'Please enter a valid asset path or URL';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                DropdownButtonFormField<UserRole>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.work_outline),
                  ),
                  items:
                      UserRole.values.map((UserRole role) {
                        return DropdownMenuItem<UserRole>(
                          value: role,
                          child: Text(
                            role.toString().split('.').last[0].toUpperCase() +
                                role.toString().split('.').last.substring(1),
                          ), // Capitalize first letter
                        );
                      }).toList(),
                  onChanged: (UserRole? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedRole = newValue;
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a role';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),
                // Removed the direct call to _saveProfile via ElevatedButton here
                // The save button is in the AppBar
              ],
            ),
          ),
        ),
      ),
    );
  }
}
