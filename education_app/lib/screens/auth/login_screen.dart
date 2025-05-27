// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/auth_notifier.dart';
import 'registration_screen.dart'; // We'll create this next
// Import AppLocalizations to use translated strings
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return; // If form is not valid, do not proceed
    }
    // If form is valid, call the signIn method from AuthNotifier
    // context.read<AuthNotifier>() is used to call methods on the provider
    // without listening to changes (which is fine for one-off actions like this).
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    final success = await authNotifier.signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success) {
      // Navigation to HomePage will be handled by the AuthWrapper/AuthState listener
      // So, we don't need to explicitly navigate here if sign-in is successful.
      // The AuthNotifier will update its state, and the wrapper will react.
      if (mounted) {
        // Optionally, show a success message or clear fields if needed,
        // but usually, successful login leads to immediate navigation.
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text('Login Successful! Redirecting...')),
        // );
      }
    } else {
      // If sign-in fails, AuthNotifier's errorMessage will be set.
      // We can show it in a SnackBar or directly in the UI.
      // The Consumer/Selector below will handle displaying the error message.
      // For immediate feedback, a SnackBar can also be used here.
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
    // final AppLocalizations? l10n = AppLocalizations.of(context); // For localization

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // App Logo or Title
                Image.asset(
                  'assets/images/Shared_Knowledge.png', // Your app logo
                  height: 100,
                  // width: 100, // Adjust as needed
                ),
                const SizedBox(height: 12),
                Text(
                  'Welcome Back!', // Replace with l10n?.welcomeMessage ?? 'Welcome Back!'
                  textAlign: TextAlign.center,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                Text(
                  'Sign in to continue', // Replace with localized string
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
                    labelText:
                        'Email', // Replace with l10n?.emailLabel ?? 'Email'
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
                      r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
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
                    labelText:
                        'Password', // Replace with l10n?.passwordLabel ?? 'Password'
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
                      return 'Please enter your password'; // Localize
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters'; // Localize
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),

                // Login Button - listens to AuthNotifier for loading state
                Consumer<AuthNotifier>(
                  builder: (context, authNotifier, child) {
                    return authNotifier.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton.icon(
                          icon: const Icon(Icons.login_rounded),
                          label: const Text('Login'), // Localize
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

                // Option to navigate to Registration Screen
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?", // Localize
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    TextButton(
                      child: Text(
                        'Sign Up', // Localize
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => RegistrationScreen(
                                  onSwitchToLogin: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => const LoginScreen(),
                                      ),
                                    );
                                  },
                                ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                // Display error message from AuthNotifier if any
                Consumer<AuthNotifier>(
                  builder: (context, authNotifier, child) {
                    if (authNotifier.errorMessage != null &&
                        !authNotifier.isLoading) {
                      // We show errors via SnackBar in _submitForm,
                      // but this is another place to show persistent errors if needed.
                      // For now, SnackBar is primary.
                      // return Padding(
                      //   padding: const EdgeInsets.only(top: 8.0),
                      //   child: Text(
                      //     authNotifier.errorMessage!,
                      //     style: TextStyle(color: colorScheme.error),
                      //     textAlign: TextAlign.center,
                      //   ),
                      // );
                    }
                    return const SizedBox.shrink(); // No error or loading, show nothing
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
