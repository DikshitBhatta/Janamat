import 'package:flutter/material.dart';
import 'authentication_api.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationProvider with ChangeNotifier {
  final AuthenticationAPI _authenticationAPI = AuthenticationAPI();
  User? _user;
  User? get user => _user;

  AuthenticationProvider() {
    _authenticationAPI.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  // Get authentication state changes (to track sign in/out)
  Stream<User?> get authStateChanges => _authenticationAPI.authStateChanges;

  // Sign up user
  Future<void> signUp(String email, String password) async {
    try {
      await _authenticationAPI.signUp(email, password);
    } catch (e) {
      throw e;
    }
  }

  // Sign in user
  Future<void> signIn(String email, String password) async {
    try {
      await _authenticationAPI.signIn(email, password);
    } catch (e) {
      throw e;
    }
  }

  // Sign out user
  Future<void> signOut() async {
    await _authenticationAPI.signOut();
    notifyListeners();
  }
}
