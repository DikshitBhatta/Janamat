import 'package:firebase_auth/firebase_auth.dart';

// FirebaseUser class is already available from Firebase Authentication
class FirebaseUserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoURL;

  FirebaseUserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
  });

  // Factory method to create a model from Firebase User object
  factory FirebaseUserModel.fromFirebaseUser(User user) {
    return FirebaseUserModel(
      uid: user.uid,
      email: user.email!,
      displayName: user.displayName,
      photoURL: user.photoURL,
    );
  }

  // Method to convert to a map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
    };
  }
}
