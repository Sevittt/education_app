// File: lib/screens/profile_edit_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Ensure User and UserRole are imported from your reverted models file
import '../models/users.dart';
// Assuming your reverted AuthService is also in models/users.dart or a separate services file
import '../services/auth_service.dart'; // Or '../models/users.dart' if AuthService is there
import '../models/auth_notifier.dart'; // To update the user in the notifier

class ProfileEditScreen extends StatefulWidget {
  final User currentUser; // Expecting the "old" User model

  const ProfileEditScreen({Key? key, required this.currentUser})
    : super(key: key);

  static const routeName = '/profile-edit';

  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _photoUrlController;
  late UserRole _selectedRole; // Using the UserRole enum directly
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.currentUser.name,
    ); // Use 'name'
    _bioController = TextEditingController(text: widget.currentUser.bio ?? '');
    _photoUrlController = TextEditingController(
      text: widget.currentUser.profilePictureUrl ?? '',
    ); // Use 'profilePictureUrl'
    _selectedRole = widget.currentUser.role; // Role is already UserRole enum
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

    try {
      // Create an updated User object using the "old" model structure
      final updatedUser = User(
        id: widget.currentUser.id, // Keep the original ID
        email: widget.currentUser.email,
        name: _nameController.text.trim(), // Use 'name'
        bio:
            _bioController.text.trim().isNotEmpty
                ? _bioController.text.trim()
                : null,
        profilePictureUrl:
            _photoUrlController.text.trim().isNotEmpty
                ? _photoUrlController.text.trim()
                : null, // Use 'profilePictureUrl'
        role: _selectedRole, // Role is UserRole enum
        registrationDate: widget.currentUser.registrationDate,
        lastLogin: widget.currentUser.lastLogin,
      );

      // Instead of Firestore, update the user via AuthNotifier or pass back
      // For simplicity, let's assume AuthNotifier can update the current user
      final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
      authNotifier.updateUserLocally(
        updatedUser,
      ); // You'd need to implement this in AuthNotifier

      // Or, if not using a global notifier for this, just pop with the updated user
      // final authService = Provider.of<AuthService>(context, listen: false);
      // await authService.updateUserProfile(updatedUser); // This would update it in AuthService's state

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile updated locally!')));
      Navigator.of(context).pop(updatedUser); // Pass back the updated user
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: ${error.toString()}'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    labelText: 'Name', // Changed from Display Name
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
                    // Basic validation, can be more robust
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
                          child: Text(role.toString().split('.').last),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension on AuthNotifier {
  void updateUserLocally(User updatedUser) {}
}
