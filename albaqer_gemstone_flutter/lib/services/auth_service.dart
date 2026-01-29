import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../config/api_config.dart';

class AuthService {
  // Singleton pattern (optional but recommended)
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // ========== REGISTER (BACKEND) ==========
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      print('📝 Registering with backend: $email');

      final baseUrl = ApiConfig.baseUrl;

      final response = await http
          .post(
            Uri.parse('$baseUrl/users/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'password': password,
              'full_name': name,
              'phone': phone,
            }),
          )
          .timeout(Duration(seconds: 10));

      print('📥 Registration response: ${response.statusCode}');

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          final data = responseData['data'];

          // Save token
          await _saveToken(data['token']);

          // Save user data
          await _saveUserData(data);

          return {
            'success': true,
            'user': User.fromJson(data),
            'message': responseData['message'] ?? 'Registration successful',
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Registration failed',
          };
        }
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      print('❌ Registration error: $e');
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  // ========== HELPER: SAVE TOKEN ==========
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    print('🔐 Token saved');
  }

  // ========== HELPER: SAVE USER DATA ==========
  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(userData));
    if (userData['id'] != null) {
      await prefs.setInt('user_id', userData['id']);
    }
    await prefs.setString('user_email', userData['email']);
    await prefs.setString(
      'user_name',
      userData['full_name'] ?? userData['name'] ?? 'User',
    );
    if (userData['role'] != null) {
      await prefs.setString('user_role', userData['role']);
    }
    print('💾 User data saved');
  }

  // ========== LOGIN (BACKEND) ==========
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 Logging in with backend: $email');

      final baseUrl = ApiConfig.baseUrl;

      final response = await http
          .post(
            Uri.parse('$baseUrl/users/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(Duration(seconds: 10));

      print('📥 Login response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          final data = responseData['data'];

          // Save token
          await _saveToken(data['token']);

          // Save user data
          await _saveUserData(data);

          return {
            'success': true,
            'user': User.fromJson(data),
            'message': responseData['message'] ?? 'Login successful',
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Login failed',
          };
        }
      } else if (response.statusCode == 401) {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Invalid email or password',
        };
      } else if (response.statusCode == 403) {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Account is inactive',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      print('❌ Login error: $e');
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  // ========== LOGOUT ==========
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    await prefs.remove('user_id');
    await prefs.remove('user_email');
    await prefs.remove('user_name');
    print('✅ Logged out successfully');
  }

  // ========== GET TOKEN ==========
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // ========== CHECK IF LOGGED IN ==========
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ========== GET CURRENT USER ==========
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user');

    if (userData != null) {
      final userMap = jsonDecode(userData);
      return User.fromJson(userMap);
    }
    return null;
  }

  // ========== GET USER ID ==========
  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  // ========== GET USER EMAIL ==========
  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email');
  }

  // ========== VALIDATE TOKEN ==========
  Future<bool> validateToken() async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final baseUrl = ApiConfig.baseUrl;

      final response = await http.get(
        Uri.parse('$baseUrl/users/validate'),
        headers: {'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ========== GET AUTH HEADERS ==========
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    final headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }
}
