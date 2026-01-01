class User {
  final int? id;
  final String email;
  final String passwordHash;
  final String fullName;
  final String? phone;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    this.id,
    required this.email,
    required this.passwordHash,
    required this.fullName,
    this.phone,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> get userMap {
    return {
      'id': id,
      'email': email,
      'password_hash': passwordHash,
      'full_name': fullName,
      'phone': phone,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Factory constructor to create User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'] ?? '',
      passwordHash: json['password_hash'] ?? json['passwordHash'] ?? '',
      fullName: json['full_name'] ?? json['fullName'] ?? json['name'] ?? '',
      phone: json['phone'],
      isActive: json['is_active'] != 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }
}
