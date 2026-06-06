import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      notifyListeners();
      return credential;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Firebase Auth Error: ${e.code} - ${e.message}');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('Error during sign in: $e');
      }
      rethrow;
    }
  }

  // Register with email and password
  Future<UserCredential?> registerWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      notifyListeners();
      return credential;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Firebase Auth Error: ${e.code} - ${e.message}');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('Error during registration: $e');
      }
      rethrow;
    }
  }

  // Update email
  Future<void> updateEmail(String newEmail) async {
    try {
      await _auth.currentUser?.verifyBeforeUpdateEmail(newEmail);
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Firebase Auth Error: ${e.code} - ${e.message}');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('Error during email update: $e');
      }
      rethrow;
    }
  }

  // Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Firebase Auth Error: ${e.code} - ${e.message}');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('Error during password update: $e');
      }
      rethrow;
    }
  }

  // Update display name (Auth profile)
  Future<void> updateDisplayName(String newName) async {
    try {
      await _auth.currentUser?.updateDisplayName(newName);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error during display name update: $e');
      }
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }
}
