import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Save user data to Firestore
  Future<void> saveUserData(String uid, UserModel user) async {
    try {
      await _db.collection('users').doc(uid).set({
        'name': user.name,
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving user data: $e');
      rethrow;
    }
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return UserModel(
          name: data['name'] ?? '',
          email: data['email'] ?? '',
        );
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      rethrow;
    }
  }
}
