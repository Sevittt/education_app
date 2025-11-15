// lib/auth/registration_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import '../../models/auth_notifier.dart';
import '../../models/users.dart';

class RegistrationScreen extends StatefulWidget {
  final VoidCallback onSwitchToLogin;

  const RegistrationScreen({super.key, required this.onSwitchToLogin});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController =
      TextEditingController(); // Controller for the user's name

  // --- NEW: State variable for the selected role ---
  UserRole? _selectedRole;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);

    // --- UPDATED: Pass name and role to the signUp method ---
    final success = await authNotifier.signUp(
      _emailController.text.trim(),
      _passwordController.text,
      _nameController.text.trim(),
      _selectedRole!, // Pass the selected role
    );

    if (!mounted) return;

    if (success) {
      // On success, the AuthWrapper will handle navigation to HomePage
      // No need to call Navigator.of(context).pushReplacement here
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authNotifier.errorMessage ??
                'Registration failed. Please try again.',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final _ = Theme.of(context);
    final authNotifier = Provider.of<AuthNotifier>(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.registrationTitle, // FIXED
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.registrationSubtitle, // FIXED
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Name TextFormField
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.registrationFullNameLabel, // FIXED
                    prefixIcon: const Icon(Icons.person),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.registrationFullNameError; // FIXED
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email TextFormField
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: l10n.emailLabel,
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || !value.contains('@')) {
                      return 'Please enter a valid email'; // Use localization key when added
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Role Selection Dropdown
                DropdownButtonFormField<UserRole>(
                  initialValue: _selectedRole,
                  decoration: InputDecoration(
                    labelText: l10n.registrationRoleLabel,
                    prefixIcon: const Icon(Icons.work_outline),
                    border: const OutlineInputBorder(),
                  ),
                  hint: Text('Select a role'), // No localization key exists
                  items: [
                    DropdownMenuItem(
                      value: UserRole.xodim,
                      child: Text(l10n.registrationRoleXodim),
                    ),
                    DropdownMenuItem(
                      value: UserRole.ekspert,
                      child: Text(l10n.registrationRoleEkspert),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return l10n.registrationRoleError;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password TextFormField
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: l10n.registrationPasswordLabel,
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return l10n.registrationPasswordError;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Confirm Password TextFormField
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: l10n.registrationConfirmPasswordLabel,
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return l10n.registrationConfirmPasswordError;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Submit Button
                ElevatedButton(
                  onPressed: authNotifier.isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child:
                      authNotifier.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(l10n.registrationSignUpButton),
                ),
                const SizedBox(height: 16),

                // Switch to Login Screen
                TextButton(
                  onPressed: widget.onSwitchToLogin,
                  child: Text(l10n.registrationSwitchToLogin),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
