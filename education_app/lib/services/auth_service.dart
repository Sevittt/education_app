// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode

class AuthService {
  // Get the FirebaseAuth instance
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // --- Get Current User ---
  // Provides direct access to the current Firebase User object.
  // This can be null if no user is signed in.
  User? get currentUser => _firebaseAuth.currentUser;

  // --- Auth State Changes Stream ---
  // Provides a stream that emits the User object when the auth state changes
  // (e.g., user signs in or signs out). This is useful for listening to auth
  // changes in real-time throughout the app.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // --- Sign Up with Email and Password ---
  // Attempts to create a new user account with the given email and password.
  // Returns the User object if successful, or null if an error occurs.
  // Handles potential FirebaseAuthException errors.
  Future<User?> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      // Attempt to create a new user with Firebase Authentication
      final UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(
            email: email.trim(), // Trim whitespace from email
            password: password, // Password is used as is
          );
      // If user creation is successful, return the User object
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Authentication errors
      if (kDebugMode) {
        // Print errors only in debug mode
        print(
          'Firebase Auth Exception during sign up: ${e.code} - ${e.message}',
        );
      }
      // You might want to throw a custom exception or return a specific error code/message
      // to be handled by the UI. For now, we return null on error.
      return null;
    } catch (e) {
      // Handle any other unexpected errors
      if (kDebugMode) {
        print('An unexpected error occurred during sign up: $e');
      }
      return null;
    }
  }

  // --- Sign In with Email and Password ---
  // Attempts to sign in an existing user with the given email and password.
  // Returns the User object if successful, or null if an error occurs.
  // Handles potential FirebaseAuthException errors.
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      // Attempt to sign in the user with Firebase Authentication
      final UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(
            email: email.trim(), // Trim whitespace from email
            password: password, // Password is used as is
          );
      // If sign-in is successful, return the User object
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Authentication errors
      if (kDebugMode) {
        // Print errors only in debug mode
        print(
          'Firebase Auth Exception during sign in: ${e.code} - ${e.message}',
        );
      }
      // For example, common errors include 'user-not-found', 'wrong-password', 'invalid-email'.
      // You can check e.code to provide more specific feedback to the user.
      return null;
    } catch (e) {
      // Handle any other unexpected errors
      if (kDebugMode) {
        print('An unexpected error occurred during sign in: $e');
      }
      return null;
    }
  }

  // --- Sign Out ---
  // Signs out the current user.
  // Handles potential errors during the sign-out process.
  Future<void> signOut() async {
    try {
      // Attempt to sign out the current user
      await _firebaseAuth.signOut();
    } catch (e) {
      // Handle any errors that might occur during sign out
      if (kDebugMode) {
        // Print errors only in debug mode
        print('Error signing out: $e');
      }
      // Depending on your app's needs, you might want to re-throw the error
      // or handle it in a specific way.
    }
  }

  // --- TODO: Add other authentication methods as needed ---
  // For example:
  // - Sign in with Google
  // - Sign in with Apple
  // - Sign in with Phone Number (as in F006145.pdf)
  // - Password reset
  // - Email verification
}
