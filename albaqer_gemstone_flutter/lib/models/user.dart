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
}
