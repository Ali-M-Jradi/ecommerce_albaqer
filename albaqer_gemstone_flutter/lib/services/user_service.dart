import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:albaqer_gemstone_flutter/models/user.dart';

/// Service class for handling all user-related API calls to the backend
class UserService {
  // For Android Emulator: use 10.0.2.2 (maps to host machine's localhost)
  final String baseUrl = 'http://192.168.0.102:3000/api';

  // ========== CREATE (Register) ==========
  /// Register a new user on the backend
  /// Returns the created User with its ID, or null if failed
  Future<User?> registerUser(User user) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.userMap),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return User(
          id: data['id'],
          email: data['email'],
          passwordHash: data['password_hash'] ?? '',
          fullName: data['full_name'],
          phone: data['phone'],
          isActive: data['is_active'] ?? true,
          createdAt: data['created_at'] != null
              ? DateTime.parse(data['created_at'])
              : null,
          updatedAt: data['updated_at'] != null
              ? DateTime.parse(data['updated_at'])
              : null,
        );
      } else {
        print('Failed to register user: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error registering user: $e');
      return null;
    }
  }

  // ========== READ (ALL) ==========
  /// Fetch all users from the backend
  Future<List<User>> fetchAllUsers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users/all'));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        List<dynamic> data = jsonResponse['data'];
        return data.map((json) {
          return User(
            id: json['id'],
            email: json['email'],
            passwordHash: json['password_hash'] ?? '',
            fullName: json['full_name'],
            phone: json['phone'],
            isActive: json['is_active'] ?? true,
            createdAt: json['created_at'] != null
                ? DateTime.parse(json['created_at'])
                : null,
            updatedAt: json['updated_at'] != null
                ? DateTime.parse(json['updated_at'])
                : null,
          );
        }).toList();
      } else {
        print('Failed to fetch users: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  // ========== READ (BY ID) ==========
  /// Fetch a single user by ID from the backend
  Future<User?> fetchUserById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users/$id'));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return User(
          id: json['id'],
          email: json['email'],
          passwordHash: json['password_hash'] ?? '',
          fullName: json['full_name'],
          phone: json['phone'],
          isActive: json['is_active'] ?? true,
          createdAt: json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
          updatedAt: json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
        );
      } else if (response.statusCode == 404) {
        print('User not found');
        return null;
      } else {
        print('Failed to fetch user: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  // ========== UPDATE ==========
  /// Update an existing user on the backend
  Future<User?> updateUser(User user) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/${user.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.userMap),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return User(
          id: json['id'],
          email: json['email'],
          passwordHash: json['password_hash'] ?? '',
          fullName: json['full_name'],
          phone: json['phone'],
          isActive: json['is_active'] ?? true,
          createdAt: json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
          updatedAt: json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
        );
      } else if (response.statusCode == 404) {
        print('User not found');
        return null;
      } else {
        print('Failed to update user: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error updating user: $e');
      return null;
    }
  }

  // ========== DELETE ==========
  /// Delete a user from the backend
  Future<bool> deleteUser(int userId) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/users/$userId'));

      if (response.statusCode == 200) {
        print('User deleted successfully');
        return true;
      } else if (response.statusCode == 404) {
        print('User not found');
        return false;
      } else {
        print('Failed to delete user: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }
}
