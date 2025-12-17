import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:albaqer_gemstone_flutter/models/stone.dart';

/// Service class for handling all stone-related API calls to the backend
class StoneService {
  final String baseUrl = 'http://localhost:3000';

  // ========== CREATE ==========
  /// Create a new stone on the backend
  Future<Stone?> createStone(Stone stone) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/stones'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(stone.stoneMap),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Stone(
          id: data['id'],
          name: data['name'],
          color: data['color'],
          cut: data['cut'],
          origin: data['origin'],
          caratWeight: data['carat_weight']?.toDouble(),
          sizeMm: data['size_mm'],
          clarity: data['clarity'],
          price: data['price'].toDouble(),
          imageUrl: data['image_url'],
          rating: data['rating']?.toDouble() ?? 0.0,
        );
      } else {
        print('Failed to create stone: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error creating stone: $e');
      return null;
    }
  }

  // ========== READ (ALL) ==========
  /// Fetch all stones from the backend
  Future<List<Stone>> fetchAllStones() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/stones'));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) {
          return Stone(
            id: json['id'],
            name: json['name'],
            color: json['color'],
            cut: json['cut'],
            origin: json['origin'],
            caratWeight: json['carat_weight']?.toDouble(),
            sizeMm: json['size_mm'],
            clarity: json['clarity'],
            price: json['price'].toDouble(),
            imageUrl: json['image_url'],
            rating: json['rating']?.toDouble() ?? 0.0,
          );
        }).toList();
      } else {
        print('Failed to fetch stones: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching stones: $e');
      return [];
    }
  }

  // ========== READ (BY ID) ==========
  /// Fetch a single stone by ID
  Future<Stone?> fetchStoneById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/stones/$id'));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Stone(
          id: json['id'],
          name: json['name'],
          color: json['color'],
          cut: json['cut'],
          origin: json['origin'],
          caratWeight: json['carat_weight']?.toDouble(),
          sizeMm: json['size_mm'],
          clarity: json['clarity'],
          price: json['price'].toDouble(),
          imageUrl: json['image_url'],
          rating: json['rating']?.toDouble() ?? 0.0,
        );
      } else if (response.statusCode == 404) {
        print('Stone not found');
        return null;
      } else {
        print('Failed to fetch stone: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching stone: $e');
      return null;
    }
  }

  // ========== READ (BY COLOR) ==========
  /// Fetch stones by color
  Future<List<Stone>> fetchStonesByColor(String color) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/stones?color=$color'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) {
          return Stone(
            id: json['id'],
            name: json['name'],
            color: json['color'],
            cut: json['cut'],
            origin: json['origin'],
            caratWeight: json['carat_weight']?.toDouble(),
            sizeMm: json['size_mm'],
            clarity: json['clarity'],
            price: json['price'].toDouble(),
            imageUrl: json['image_url'],
            rating: json['rating']?.toDouble() ?? 0.0,
          );
        }).toList();
      } else {
        print('Failed to fetch stones by color: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching stones by color: $e');
      return [];
    }
  }

  // ========== UPDATE ==========
  /// Update an existing stone
  Future<Stone?> updateStone(Stone stone) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/stones/${stone.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(stone.stoneMap),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Stone(
          id: json['id'],
          name: json['name'],
          color: json['color'],
          cut: json['cut'],
          origin: json['origin'],
          caratWeight: json['carat_weight']?.toDouble(),
          sizeMm: json['size_mm'],
          clarity: json['clarity'],
          price: json['price'].toDouble(),
          imageUrl: json['image_url'],
          rating: json['rating']?.toDouble() ?? 0.0,
        );
      } else if (response.statusCode == 404) {
        print('Stone not found');
        return null;
      } else {
        print('Failed to update stone: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error updating stone: $e');
      return null;
    }
  }

  // ========== DELETE ==========
  /// Delete a stone
  Future<bool> deleteStone(int stoneId) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/stones/$stoneId'));

      if (response.statusCode == 200) {
        print('Stone deleted successfully');
        return true;
      } else if (response.statusCode == 404) {
        print('Stone not found');
        return false;
      } else {
        print('Failed to delete stone: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error deleting stone: $e');
      return false;
    }
  }
}
