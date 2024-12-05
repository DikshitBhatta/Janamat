import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationAPI {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Sign up user
  Future<UserCredential> signUp(String email, String password) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
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
