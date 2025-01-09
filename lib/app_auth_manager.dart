import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

class AppAuthManager extends ChangeNotifier {
  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;

  // Add loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  AppAuthManager() {
    _loadAuthState();
  }

  // Check initial auth state and state changes
  Future<void> _loadAuthState() async {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      final currentUser = _auth.currentUser;
      _loggedIn = currentUser != null;
      notifyListeners();

      _auth.userChanges().listen((user) {
        _loggedIn = user != null;
        notifyListeners();
      });
    } catch (e) {
      // Handle error (for example, log or show a message)
      print("Firebase initialization failed: $e");
    }
  }

  // Sign in with email and password
  Future<String?> signInWithEmailPassword(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return _handleAuthError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign up with email and password
  Future<String?> signUpWithEmailPassword(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return _handleAuthError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();
      await _auth.signOut();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper method to handle Firebase Auth errors
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please provide a valid email address.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  // Get current user
  User? get currentUser => _auth.currentUser;
}
