class UserModel {
  UserModel({
    required this.name,
    required this.email,
    this.isPremium = false,
    this.usageCount = 0,
  });

  final String name;
  final String email;
  final bool isPremium;
  final int usageCount;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      isPremium: json['isPremium'] ?? false,
      usageCount: json['usageCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'isPremium': isPremium,
      'usageCount': usageCount,
    };
  }
}
