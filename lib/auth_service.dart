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
    return null;
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
    return null;
  }

  ///signOutUser
  Future<void> signOutUser() async {
    final User? firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser != null) await _firebaseAuth.signOut();
  }

  Future<void> recoverPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
  }

  Future<UserModel?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      return UserModel(
        id: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? '',
      );
    }
    return null;
  }
}
