import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import 'package:sud_qollanma/features/auth/presentation/providers/auth_notifier.dart';
import 'package:sud_qollanma/models/users.dart'; // Fixed path
import 'login_screen.dart'; // To switch back

class RegistrationScreen extends StatefulWidget {
  final VoidCallback onSwitchToLogin;
  const RegistrationScreen({super.key, required this.onSwitchToLogin});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // --- NEW: State variable for the selected role ---
  UserRole? _selectedRole;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    // --- NEW: Check if a role is selected ---
    if (_selectedRole == null) {
      // This should ideally not happen due to the validator, but as a safeguard:
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.registrationRoleError),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);

    // --- MODIFIED: Call the new 'register' method ---
    final success = await authNotifier.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      name: _nameController.text.trim(),
      role: _selectedRole!,
    );

    if (!mounted) return;
    if (success) {
      // On success, the AuthWrapper will handle navigation to HomePage
      // No need to call Navigator.of(context).pushReplacement here
    } else if (authNotifier.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authNotifier.errorMessage!),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  // --- NEW: Google Sign In Method ---
  Future<void> _googleSignIn() async {
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    final success = await authNotifier.signInWithGoogle();
    if (!success && mounted && authNotifier.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authNotifier.errorMessage!),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
    // Successful login is handled by the wrapper, which will navigate away
  }
  // --- END NEW ---

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final authNotifier = Provider.of<AuthNotifier>(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.registrationTitle,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.registrationSubtitle,
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // --- MODIFIED: Consistent styling for all fields ---
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: l10n.registrationFullNameLabel,
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      filled: true,
                      fillColor: colorScheme.surface,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.registrationFullNameError;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: l10n.emailLabel,
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      filled: true,
                      fillColor: colorScheme.surface,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty ||
                          !RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                          ).hasMatch(value)) {
                        return l10n.registrationEmailError;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),

                  DropdownButtonFormField<UserRole>(
                    initialValue: _selectedRole,
                    decoration: InputDecoration(
                      labelText: l10n.registrationRoleLabel,
                      prefixIcon: const Icon(Icons.work_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      filled: true,
                      fillColor: colorScheme.surface,
                    ),
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

                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: l10n.registrationPasswordLabel,
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      filled: true,
                      fillColor: colorScheme.surface,
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

                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: l10n.registrationConfirmPasswordLabel,
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      filled: true,
                      fillColor: colorScheme.surface,
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

                  ElevatedButton(
                    onPressed: authNotifier.isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child:
                        authNotifier.isLoading
                            ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                            : Text(l10n.registrationSignUpButton),
                  ),
                  const SizedBox(height: 16),

                  // --- NEW: Divider and Google Button ---
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 1,
                          color: colorScheme.outlineVariant,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          l10n.orDivider,
                          style: textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 1,
                          color: colorScheme.outlineVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton.icon(
                    icon: Image.asset(
                      'assets/images/google_logo.png',
                      height: 22.0,
                    ),
                    label: Text(l10n.signInWithGoogle),
                    onPressed: _googleSignIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.surfaceContainer,
                      foregroundColor: colorScheme.onSurface,
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        side: BorderSide(color: colorScheme.outline),
                      ),
                    ),
                  ),

                  TextButton(
                    onPressed: widget.onSwitchToLogin,
                    child: Text(l10n.registrationSwitchToLogin),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
