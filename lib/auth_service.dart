import 'package:firebase_auth/firebase_auth.dart';

import 'data/user.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// create user
  Future<UserModel?> signUpUser(
    String email,
    String password,
  ) async {
    final UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    final User? firebaseUser = userCredential.user;
    if (firebaseUser != null) {
      return UserModel(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName ?? '',
      );
    }
  }

  Future<UserModel?> signInUser(
    String email,
    String password,
  ) async {
    final UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    final User? firebaseUser = userCredential.user;
    if (firebaseUser != null) {
      return UserModel(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName ?? '',
      );
    }
  }

  ///signOutUser
  Future<void> signOutUser() async {
    final User? firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      await FirebaseAuth.instance.signOut();
    }
  }

  Future<void> recoverPassword(String email) async {
    final instance = FirebaseAuth.instance;
    instance.sendPasswordResetEmail(email: email);
  }
     
}
