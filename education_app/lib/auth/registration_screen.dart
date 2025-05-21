// lib/screens/auth/registration_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/auth_notifier.dart';
import 'login_screen.dart'; // For navigating back to login
// Import AppLocalizations to use translated strings
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return; // If form is not valid, do not proceed
    }
    // If form is valid, call the signUp method from AuthNotifier
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    final success = await authNotifier.signUp(
      _emailController.text.trim(),
      _passwordController.text, // Passwords should match, already validated
    );

    if (success) {
      // Navigation to HomePage will be handled by the AuthWrapper/AuthState listener
      // after successful sign-up and automatic sign-in by Firebase.
      if (mounted) {
        // Optionally show a success message or clear fields
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text('Registration Successful! Redirecting...')),
        // );
      }
    } else {
      // If sign-up fails, AuthNotifier's errorMessage will be set.
      if (mounted && authNotifier.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authNotifier.errorMessage!),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    // final AppLocalizations? l10n = AppLocalizations.of(context);

    return Scaffold(
      // appBar: AppBar( // Optional: Add an AppBar if you want a back button by default
      //   title: Text('Create Account'), // Localize
      //   centerTitle: true,
      // ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Image.asset(
                  'assets/images/Shared_Knowledge.png', // Your app logo
                  height: 80, // Slightly smaller for registration
                ),
                const SizedBox(height: 12),
                Text(
                  'Create Your Account', // Localize
                  textAlign: TextAlign.center,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                Text(
                  'Join our learning community!', // Localize
                  textAlign: TextAlign.center,
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32.0),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email', // Localize
                    hintText: 'you@example.com',
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: colorScheme.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email'; // Localize
                    }
                    if (!RegExp(
                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                    ).hasMatch(value.trim())) {
                      return 'Please enter a valid email'; // Localize
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password', // Localize
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: colorScheme.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: !_isPasswordVisible,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password'; // Localize
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters'; // Localize
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // Confirm Password Field
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password', // Localize
                    prefixIcon: Icon(
                      Icons.lock_reset_outlined,
                      color: colorScheme.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: !_isConfirmPasswordVisible,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password'; // Localize
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match'; // Localize
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),

                // Sign Up Button
                Consumer<AuthNotifier>(
                  builder: (context, authNotifier, child) {
                    return authNotifier.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton.icon(
                          icon: const Icon(Icons.person_add_alt_1_rounded),
                          label: const Text('Sign Up'), // Localize
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 14.0),
                            textStyle: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                        );
                  },
                ),
                const SizedBox(height: 16.0),

                // Option to navigate to Login Screen
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?", // Localize
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    TextButton(
                      child: Text(
                        'Sign In', // Localize
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          // Or use push
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                // Error display (similar to LoginScreen, primarily handled by SnackBar)
                Consumer<AuthNotifier>(
                  builder: (context, authNotifier, child) {
                    if (authNotifier.errorMessage != null &&
                        !authNotifier.isLoading) {
                      // SnackBar is preferred for transient errors from _submitForm
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
