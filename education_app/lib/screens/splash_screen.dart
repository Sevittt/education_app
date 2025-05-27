// lib/splash_screen.dart
import 'dart:async'; // Required for Timer
import 'package:flutter/material.dart';
// import 'home_page.dart'; // No longer navigating directly to HomePage
import '../../widgets/auth_wrapper.dart'; // Import the AuthWrapper

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();

    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        // Check if the widget is still in the tree
        // Navigate to AuthWrapper, which will decide the next screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AuthWrapper()),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use Theme.of(context) to get appropriate background color
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor:
          theme.colorScheme.primaryContainer, // Example: Use a theme color
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Image.asset(
            'assets/images/Shared_Knowledge.png', // Your logo
            width: 400, // Adjust size as needed
            height: 400,
            // Consider adding a semantic label for accessibility
            // semanticLabel: 'Teach & Learn App Logo',
          ),
        ),
      ),
    );
  }
}
