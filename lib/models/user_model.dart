import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  UserModel({
    required this.name,
    required this.email,
    this.isPremium = false,
    this.usageCount = 0,
    this.lastUsageReset,
  });

  final String name;
  final String email;
  final bool isPremium;
  final int usageCount;
  final DateTime? lastUsageReset;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      isPremium: json['isPremium'] ?? false,
      usageCount: json['usageCount'] ?? 0,
      lastUsageReset: json['lastUsageReset'] != null
          ? (json['lastUsageReset'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'isPremium': isPremium,
      'usageCount': usageCount,
      'lastUsageReset': lastUsageReset != null
          ? Timestamp.fromDate(lastUsageReset!)
          : null,
    };
  }
}
