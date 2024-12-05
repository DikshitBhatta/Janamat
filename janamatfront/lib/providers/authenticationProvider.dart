import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:janamatfront/services/authentication_api.dart'; // Corrected import path

class AuthenticationProvider with ChangeNotifier {
  final AuthenticationAPI _authenticationAPI = AuthenticationAPI();
  User? _user;

  User? get user => _user; // Access current authenticated user

  // Stream to listen to auth state changes (for example, when a user signs in or out)
  Stream<User?> get authStateChanges => _authenticationAPI.authStateChanges;

  AuthenticationProvider() {
    _authenticationAPI.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  // Method to sign up a new user
  Future<void> signUp(String email, String password) async {
    try {
      await _authenticationAPI.signUp(email, password);
    } catch (e) {
      throw e;
    }
  }

  // Method to sign in an existing user
  Future<void> signIn(String email, String password) async {
    try {
      await _authenticationAPI.signIn(email, password);
    } catch (e) {
      throw e;
    }
  }

  // Method to sign out the current user
  Future<void> signOut() async {
    await _authenticationAPI.signOut();
    notifyListeners(); // Notify listeners to update UI
  }

  // Initialize the authentication state (if needed)
  Future<void> initialize() async {
    _authenticationAPI.authStateChanges.listen((user) {
      _user = user;
      notifyListeners(); // Update listeners when auth state changes
    });
  }
}
