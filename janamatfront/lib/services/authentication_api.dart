import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthenticationAPI {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Sign up user
  Future<UserCredential> signUp(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Send UID and username to the backend
      await _sendUserDataToBackend(userCredential.user);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('The account already exists for that email.');
      } else {
        throw Exception('An unknown error occurred.');
      }
    }
  }

  Future<void> _sendUserDataToBackend(User? user) async {
    if (user != null) {
      final url = Uri.parse('http://192.168.1.74:8000/registeruser/');
      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'uid': user.uid,
            'email': user.email,
            'username': user.displayName ?? user.email?.split('@')[0], // Use email prefix as username if displayName is null
          }),
        );

        if (response.statusCode != 200) {
          throw Exception('Failed to send user data to backend: ${response.body}');
        }
      } catch (e) {
        print('Error sending user data to backend: $e');
      }
    }
  }

  // Sign in user
  Future<UserCredential> signIn(String email, String password) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign out user
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // Stream user authentication state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
}
