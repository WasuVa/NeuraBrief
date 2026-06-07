import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Save user data to Firestore
  Future<void> saveUserData(String uid, UserModel user) async {
    try {
      await _db.collection('users').doc(uid).set({
        ...user.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving user data: $e');
      rethrow;
    }
  }

  // Increment usage count
  Future<void> incrementUsage(String uid) async {
    try {
      await _db.collection('users').doc(uid).update({
        'usageCount': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error incrementing usage: $e');
    }
  }

  // Reset usage count and date
  Future<void> resetUsage(String uid) async {
    try {
      await _db.collection('users').doc(uid).update({
        'usageCount': 0,
        'lastUsageReset': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error resetting usage: $e');
    }
  }

  // Update user name in Firestore
  Future<void> updateUserName(String uid, String newName) async {
    try {
      await _db.collection('users').doc(uid).update({
        'name': newName,
      });
    } catch (e) {
      print('Error updating user name: $e');
      rethrow;
    }
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      rethrow;
    }
  }
}
