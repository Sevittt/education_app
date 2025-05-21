// lib/widgets/auth_wrapper.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/auth_notifier.dart'; // Your AuthNotifier
import '../screens/home_page.dart'; // Your main app screen
import '../auth/login_screen.dart'; // Your login screen

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Use Consumer to listen to changes in AuthNotifier
    return Consumer<AuthNotifier>(
      builder: (context, authNotifier, child) {
        // Optional: Show a loading indicator while AuthNotifier is initializing
        // or if there's an ongoing auth operation that blocks UI.
        // For initial load, often the SplashScreen handles this.
        // if (authNotifier.isLoading && authNotifier.currentUser == null) {
        //   return const Scaffold(
        //     body: Center(child: CircularProgressIndicator()),
        //   );
        // }

        // Check if a user is currently authenticated
        if (authNotifier.isAuthenticated) {
          // If authenticated, show the HomePage
          return const HomePage();
        } else {
          // If not authenticated, show the LoginScreen
          // Users can navigate to RegistrationScreen from LoginScreen
          return const LoginScreen();
        }
      },
    );
  }
}
