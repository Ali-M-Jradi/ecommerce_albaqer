import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ChatbotService {
  /// Send a chat message to the AlBaqer chatbot
  static Future<Map<String, dynamic>> sendMessage({
    required String message,
    int? userId,
    String? sessionId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.chatbotUrl}/api/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': message,
          'user_id': userId,
          'session_id': sessionId,
          'metadata': metadata ?? {},
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Failed to send message: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  /// Get chat history for a specific user
  static Future<List<dynamic>> getChatHistory({
    required int userId,
    int limit = 10,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.chatbotUrl}/api/chat/history/$userId?limit=$limit',
        ),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load history: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading history: $e');
      rethrow;
    }
  }

  /// Get a specific conversation by session ID
  static Future<Map<String, dynamic>> getConversation({
    required String sessionId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.chatbotUrl}/api/chat/session/$sessionId'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        throw Exception('Conversation not found');
      } else {
        throw Exception('Failed to load conversation: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading conversation: $e');
      rethrow;
    }
  }

  /// Delete a conversation by session ID
  static Future<void> deleteConversation({required String sessionId}) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.chatbotUrl}/api/chat/history/$sessionId'),
      );

      if (response.statusCode == 200) {
        print('Conversation deleted successfully');
      } else if (response.statusCode == 404) {
        throw Exception('Conversation not found');
      } else {
        throw Exception(
          'Failed to delete conversation: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error deleting conversation: $e');
      rethrow;
    }
  }

  /// Check if the chatbot API is healthy
  static Future<bool> checkHealth() async {
    try {
      final response = await http
          .get(Uri.parse(ApiConfig.chatbotHealthUrl))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'healthy';
      }
      return false;
    } catch (e) {
      print('Health check failed: $e');
      return false;
    }
  }
}
