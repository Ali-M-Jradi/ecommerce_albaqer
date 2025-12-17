import 'package:albaqer_gemstone_flutter/database/database.dart';     
import 'package:albaqer_gemstone_flutter/models/user.dart'; 


// Insert a user
void insertUser(User user) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  db.insert('users', user.userMap);
}

// Get user by email (for login)
Future<User?> getUserByEmail(String email) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  final result = await db.query(
    'users',
    where: 'email = ?',
    whereArgs: [email],
  );
  if (result.isEmpty) {
    return null;
  }
  final row = result.first;
  return User(
    id: row['id'] as int,
    email: row['email'] as String,
    passwordHash: row['password_hash'] as String,
    fullName: row['full_name'] as String,
    phone: row['phone'] as String?,
    isActive: (row['is_active'] as int) == 1,
    createdAt: row['created_at'] != null
        ? DateTime.parse(row['created_at'] as String)
        : null,
    updatedAt: row['updated_at'] != null
        ? DateTime.parse(row['updated_at'] as String)
        : null,
  );
}

// Update user
void updateUser(User user) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  db.update('users', user.userMap, where: 'id = ?', whereArgs: [user.id]);
}
