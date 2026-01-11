// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart'; // For kDebugMode and kIsWeb
import 'package:google_sign_in/google_sign_in.dart';
// --- NEW IMPORTS ---
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../models/users.dart' as app_user_model;
import '../../../../services/profile_service.dart';
import '../../../../services/gamification_service.dart';
// --- END NEW IMPORTS ---

class AuthService {
  // Get the FirebaseAuth instance
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;
  final CollectionReference<Map<String, dynamic>> _usersCollection =
      FirebaseFirestore.instance.collection('users');
  // --- NEW: AuthService now depends on ProfileService ---
  final ProfileService _profileService;

  // --- NEW: Constructor to inject ProfileService ---
  AuthService(this._profileService);

  // --- Get Current User ---
  // Provides direct access to the current Firebase User object.
  // This can be null if no user is signed in.
  firebase_auth.User? get currentUser => _firebaseAuth.currentUser;

  // --- Auth State Changes Stream ---
  // Provides a stream that emits the User object when the auth state changes
  // (e.g., user signs in or signs out). This is useful for listening to auth
  // changes in real-time throughout the app.
  Stream<firebase_auth.User?> get authStateChanges {
    // --- MODIFIED: Return the raw Firebase user stream ---
    return _firebaseAuth.authStateChanges();
  }

  // --- Sign Up with Email and Password ---
  // Attempts to create a new user account with the given email and password.
  // Returns the User object if successful, or null if an error occurs.
  // --- MODIFIED: Method signature and implementation ---
  Future<app_user_model.AppUser?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required app_user_model.UserRole role,
  }) async {
    try {
      // --- REMOVED Username uniqueness check ---

      // Attempt to create a new user with Firebase Authentication
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // Update Firebase Auth profile with name
        await firebaseUser.updateDisplayName(name);

        // Create a new app_user_model.AppUser object
        final newUser = app_user_model.AppUser(
          id: firebaseUser.uid,
          name: name,
          email: email,
          role: role,
          registrationDate: DateTime.now(),
          lastLogin: DateTime.now(),
        );

        // Save the user's complete profile to Firestore
        await _usersCollection.doc(firebaseUser.uid).set(newUser.toMap());

        // --- NEW: Trigger streak check ---
        await GamificationService().checkAndUpdateStreak(firebaseUser.uid);

        return newUser;
      }
      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      // Catches exceptions like 'email-already-in-use', 'weak-password', etc.
      if (kDebugMode) {
        print("FirebaseAuthException during registration: ${e.message}");
      }
      rethrow; // Rethrow the exception to be handled by the caller (e.g., AuthNotifier)
    }
  }

  // --- Sign In with Email and Password ---
  // Attempts to sign in an existing user with the given email and password.
  // Returns the User object if successful, or null if an error occurs.
  // Handles potential FirebaseAuthException errors.
  Future<app_user_model.AppUser?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Attempt to sign in the user with Firebase Authentication
      final firebase_auth.UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(
            email: email.trim(), // Trim whitespace from email
            password: password, // Password is used as is
          );
      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // --- NEW: After successful sign-in, fetch the full app user profile ---
        final appUser = await _profileService.getUserProfile(firebaseUser.uid);
        
        // --- NEW: Trigger streak check ---
        await GamificationService().checkAndUpdateStreak(firebaseUser.uid);
        
        return appUser;
      }
      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      // Handle specific Firebase Authentication errors
      if (kDebugMode) {
        // Print errors only in debug mode
        print(
          'Firebase Auth Exception during sign in: ${e.code} - ${e.message}',
        );
      }
      rethrow; // --- MODIFIED: Rethrow exception instead of returning null
    } catch (e) {
      // Handle any other unexpected errors
      if (kDebugMode) {
        print('Unexpected error during sign in: $e');
      }
      rethrow; // --- MODIFIED: Rethrow exception
    }
  }

  // --- NEW: Sign in with Google ---
  /// Signs in the user with Google.
  /// If the user is new, creates a profile in Firestore.
  Future<app_user_model.AppUser?> signInWithGoogle() async {
    try {
      firebase_auth.UserCredential userCredential;

      if (kIsWeb) {
        // Web platformasi uchun signInWithPopup ishlatamiz
        final firebase_auth.GoogleAuthProvider googleProvider =
            firebase_auth.GoogleAuthProvider();
        
        // Popup orqali sign in
        userCredential = await _firebaseAuth.signInWithPopup(googleProvider);
      } else {
        // Mobile va desktop uchun GoogleSignIn package ishlatamiz
        // 1. Trigger the Google Sign-In flow
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) {
          // User cancelled the flow
          return null;
        }

        // 2. Obtain auth details from the request
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        // 3. Create a new Firebase credential
        final firebase_auth.AuthCredential credential =
            firebase_auth.GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // 4. Sign in to Firebase with the credential
        userCredential = await _firebaseAuth.signInWithCredential(credential);
      }

      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw Exception('Sign in with Google failed.');
      }

      // 5. Check if this is a new or existing user
      final docSnapshot = await _usersCollection.doc(firebaseUser.uid).get();

      if (docSnapshot.exists) {
        // 6a. Existing user: Just update last login and return profile
        await _usersCollection.doc(firebaseUser.uid).update({
          'lastLogin': DateTime.now().toIso8601String(),
        });
        final appUser = await _profileService.getUserProfile(firebaseUser.uid);
        return appUser;
      } else {
        // 6b. New user: Create a new profile in Firestore
        final newUser = app_user_model.AppUser(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? 'New User',
          email: firebaseUser.email,
          role: app_user_model.UserRole.xodim, // Default role
          profilePictureUrl: firebaseUser.photoURL,
          registrationDate: DateTime.now(),
          lastLogin: DateTime.now(),
        );

        await _usersCollection.doc(firebaseUser.uid).set(newUser.toMap());
        
        // --- NEW: Trigger streak check ---
        await GamificationService().checkAndUpdateStreak(firebaseUser.uid);
        
        return newUser;
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print("FirebaseAuthException during Google sign in: ${e.message}");
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print("Unexpected error during Google sign in: $e");
      }
      rethrow;
    }
  }
  // --- END NEW ---

  // --- Sign Out ---
  // Signs out the current user.
  // Handles potential errors during the sign-out process.
  Future<void> signOut() async {
    try {
      // Attempt to sign out the current user
      await _firebaseAuth.signOut();
      if (!kIsWeb) {
        await GoogleSignIn().signOut(); // Also sign out from Google (mobile/desktop)
      }
    } catch (e) {
      // Handle any errors that might occur during sign out
      if (kDebugMode) {
        // Print errors only in debug mode
        print('Error signing out: $e');
      }
      // Depending on your app's needs, you might want to re-throw the error
      // or handle it in a specific way. We don't rethrow here.
    }
  }

  // --- Change Password ---
  // Re-authenticates the user and then updates their password.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('No user signed in');
    }

    if (user.email == null) {
      throw Exception('User email not found');
    }

    try {
      // 1. Create credential with current password
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      // 2. Re-authenticate
      await user.reauthenticateWithCredential(credential);

      // 3. Update password
      await user.updatePassword(newPassword);
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Error changing password: ${e.code} - ${e.message}');
      }
      rethrow;
    }
  }
}
