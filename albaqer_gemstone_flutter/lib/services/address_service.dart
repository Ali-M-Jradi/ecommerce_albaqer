import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/address.dart';

/// Service class for handling all address-related API calls to the backend
class AddressService {
  /// Get JWT token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Get authorization headers with JWT token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ========== CREATE ==========
  /// Create a new address on the backend
  Future<Address?> createAddress(Address address) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/addresses'),
        headers: headers,
        body: jsonEncode(address.addressMap),
      );

      if (response.statusCode == 201) {
        final json = jsonDecode(response.body);
        final data =
            json['data']; // Backend returns {success: true, data: {...}}
        return Address(
          id: data['id'],
          userId: data['user_id'],
          addressType: data['address_type'],
          streetAddress: data['street_address'],
          city: data['city'],
          country: data['country'],
          isDefault: data['is_default'] == true || data['is_default'] == 1,
        );
      } else {
        print('Failed to create address: ${response.statusCode}');
        print('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error creating address: $e');
      return null;
    }
  }

  // ========== READ (ALL) ==========
  /// Fetch all addresses from the backend
  Future<List<Address>> fetchAllAddresses() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/addresses'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List<dynamic> data =
            json['data']; // Backend returns {success: true, data: [...]}
        return data.map((item) {
          return Address(
            id: item['id'],
            userId: item['user_id'],
            addressType: item['address_type'],
            streetAddress: item['street_address'],
            city: item['city'],
            country: item['country'],
            isDefault: item['is_default'] == true || item['is_default'] == 1,
          );
        }).toList();
      } else {
        print('Failed to fetch addresses: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching addresses: $e');
      return [];
    }
  }

  // ========== READ (BY USER ID) ==========
  /// Fetch addresses for a specific user (admin only)
  Future<List<Address>> fetchAddressesByUserId(int userId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/addresses/user/$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List<dynamic> data = json['data'];
        return data.map((item) {
          return Address(
            id: item['id'],
            userId: item['user_id'],
            addressType: item['address_type'],
            streetAddress: item['street_address'],
            city: item['city'],
            country: item['country'],
            isDefault: item['is_default'] == true || item['is_default'] == 1,
          );
        }).toList();
      } else {
        print('Failed to fetch user addresses: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching user addresses: $e');
      return [];
    }
  }

  // ========== READ (BY ID) ==========
  /// Fetch a single address by ID
  Future<Address?> fetchAddressById(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/addresses/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final data = json['data'];
        return Address(
          id: data['id'],
          userId: data['user_id'],
          addressType: data['address_type'],
          streetAddress: data['street_address'],
          city: data['city'],
          country: data['country'],
          isDefault: data['is_default'] == true || data['is_default'] == 1,
        );
      } else if (response.statusCode == 404) {
        print('Address not found');
        return null;
      } else {
        print('Failed to fetch address: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching address: $e');
      return null;
    }
  }

  // ========== UPDATE ==========
  /// Update an existing address
  Future<Address?> updateAddress(Address address) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/addresses/${address.id}'),
        headers: headers,
        body: jsonEncode(address.addressMap),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final data = json['data'];
        return Address(
          id: data['id'],
          userId: data['user_id'],
          addressType: data['address_type'],
          streetAddress: data['street_address'],
          city: data['city'],
          country: data['country'],
          isDefault: data['is_default'] == true || data['is_default'] == 1,
        );
      } else if (response.statusCode == 404) {
        print('Address not found');
        return null;
      } else {
        print('Failed to update address: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error updating address: $e');
      return null;
    }
  }

  // ========== DELETE ==========
  /// Delete an address
  /// Returns a map with 'success' boolean and optional 'message' string
  Future<Map<String, dynamic>> deleteAddress(int addressId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/addresses/$addressId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        print('Address deleted successfully');
        return {'success': true};
      } else if (response.statusCode == 404) {
        print('Address not found');
        return {'success': false, 'message': 'Address not found'};
      } else if (response.statusCode == 400) {
        // Parse error message from backend
        final json = jsonDecode(response.body);
        final message = json['message'] ?? 'Cannot delete this address';
        return {'success': false, 'message': message};
      } else {
        print('Failed to delete address: ${response.statusCode}');
        return {'success': false, 'message': 'Failed to delete address'};
      }
    } catch (e) {
      print('Error deleting address: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // ========== READ (BY ID) ==========
  /// Fetch a specific address by ID
  /// Used by delivery persons to view shipping address for assigned orders
  Future<Address?> getAddressById(int addressId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/addresses/$addressId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final data = json['data'];
        return Address(
          id: data['id'],
          userId: data['user_id'],
          addressType: data['address_type'],
          streetAddress: data['street_address'],
          city: data['city'],
          country: data['country'],
          isDefault: data['is_default'] == true || data['is_default'] == 1,
        );
      } else {
        print('Failed to fetch address: ${response.statusCode}');
        print('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching address: $e');
      return null;
    }
  }
}
