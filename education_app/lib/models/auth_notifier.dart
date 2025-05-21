// lib/models/auth_notifier.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart'; // Import your AuthService

class AuthNotifier with ChangeNotifier {
  final AuthService _authService;

  // Private variables to hold the state
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // StreamSubscription to listen to auth state changes
  StreamSubscription<User?>? _authStateSubscription;

  // Public getters for the state
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  AuthNotifier(this._authService) {
    // Listen to authentication state changes as soon as the notifier is created
    _authStateSubscription = _authService.authStateChanges.listen(
      _onAuthStateChanged,
    );
    // You might also want to check the initial user state immediately
    _currentUser = _authService.currentUser;
    // No need to notifyListeners() here as the stream will emit if there's a change,
    // or the initial state is set. If you want to ensure UI updates on init based on
    // _authService.currentUser, you could call notifyListeners() after a short delay
    // or when the first screen that depends on this is built.
  }

  // Callback for when the authentication state changes
  void _onAuthStateChanged(User? user) {
    _currentUser = user;
    // Clear loading and error states when auth state changes
    _isLoading = false;
    _errorMessage = null;
    notifyListeners(); // Notify listeners about the change in user state
  }

  // Method to sign up a new user
  Future<bool> signUp(String email, String password) async {
    _setLoading(true);
    _clearError();
    try {
      final User? user = await _authService.signUpWithEmailAndPassword(
        email,
        password,
      );
      _setLoading(false);
      if (user != null) {
        // _currentUser will be updated by the _authStateSubscription listener
        return true; // Sign up successful
      } else {
        // Error message might be set by _authService or you can set a generic one here
        _setErrorMessage('Sign up failed. Please try again.');
        return false; // Sign up failed
      }
    } catch (e) {
      _setLoading(false);
      _setErrorMessage(e.toString());
      return false;
    }
  }

  // Method to sign in an existing user
  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _clearError();
    try {
      final User? user = await _authService.signInWithEmailAndPassword(
        email,
        password,
      );
      _setLoading(false);
      if (user != null) {
        // _currentUser will be updated by the _authStateSubscription listener
        return true; // Sign in successful
      } else {
        _setErrorMessage('Sign in failed. Please check your credentials.');
        return false; // Sign in failed
      }
    } catch (e) {
      _setLoading(false);
      _setErrorMessage(e.toString());
      return false;
    }
  }

  // Method to sign out the current user
  Future<void> signOut() async {
    _setLoading(true); // Optional: show loading during sign out
    await _authService.signOut();
    // _currentUser will be updated to null by the _authStateSubscription listener
    _setLoading(false); // Optional: hide loading
  }

  // Helper method to update loading state and notify listeners
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Helper method to set error message and notify listeners
  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // Helper method to clear error message
  void _clearError() {
    _errorMessage = null;
    // No need to notifyListeners() here usually, as it's often called before setLoading
  }

  // Dispose the stream subscription when the notifier is disposed
  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}
