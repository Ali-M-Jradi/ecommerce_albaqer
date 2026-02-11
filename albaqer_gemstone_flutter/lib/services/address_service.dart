import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/address.dart';

/// Service class for handling all address-related API calls to the backend
/// with local caching for offline support
class AddressService {
  static const String _cacheKey = 'cached_addresses';

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

  // ========== LOCAL CACHE METHODS ==========

  /// Save addresses to local cache
  Future<void> _cacheAddresses(List<Address> addresses) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> addressesJson = addresses
          .map((addr) => addr.addressMap)
          .toList();
      await prefs.setString(_cacheKey, jsonEncode(addressesJson));
      print('✅ Cached ${addresses.length} addresses locally');
    } catch (e) {
      print('❌ Error caching addresses: $e');
    }
  }

  /// Load addresses from local cache
  Future<List<Address>> _loadCachedAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cachedData = prefs.getString(_cacheKey);

      if (cachedData == null) {
        print('ℹ️ No cached addresses found');
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(cachedData);
      final List<Address> addresses = jsonList.map((item) {
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

      print('✅ Loaded ${addresses.length} addresses from cache');
      return addresses;
    } catch (e) {
      print('❌ Error loading cached addresses: $e');
      return [];
    }
  }

  /// Clear address cache (useful for logout or refresh)
  // ignore: unused_element
  Future<void> _clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      print('🗑️ Address cache cleared');
    } catch (e) {
      print('❌ Error clearing address cache: $e');
    }
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
        final newAddress = Address(
          id: data['id'],
          userId: data['user_id'],
          addressType: data['address_type'],
          streetAddress: data['street_address'],
          city: data['city'],
          country: data['country'],
          isDefault: data['is_default'] == true || data['is_default'] == 1,
        );

        // Update cache after creating
        final cachedAddresses = await _loadCachedAddresses();
        cachedAddresses.add(newAddress);
        await _cacheAddresses(cachedAddresses);

        return newAddress;
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
  /// Fetch all addresses from the backend with offline fallback
  Future<List<Address>> fetchAllAddresses() async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(Uri.parse('${ApiConfig.baseUrl}/addresses'), headers: headers)
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List<dynamic> data =
            json['data']; // Backend returns {success: true, data: [...]}
        final addresses = data.map((item) {
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

        // Cache addresses for offline use
        await _cacheAddresses(addresses);
        print('✅ Fetched ${addresses.length} addresses from backend');

        return addresses;
      } else {
        print('Failed to fetch addresses: ${response.statusCode}');
        // Load from cache on error
        return await _loadCachedAddresses();
      }
    } catch (e) {
      print('⚠️ Error fetching addresses (likely offline): $e');
      print('📦 Loading addresses from local cache...');
      // Load from cache when offline
      return await _loadCachedAddresses();
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
  /// Fetch a single address by ID with offline fallback
  Future<Address?> fetchAddressById(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/addresses/$id'),
            headers: headers,
          )
          .timeout(Duration(seconds: 10));

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
        // Try cache on error
        final cached = await _loadCachedAddresses();
        try {
          return cached.firstWhere((a) => a.id == id);
        } catch (e) {
          return null;
        }
      }
    } catch (e) {
      print('⚠️ Error fetching address (likely offline): $e');
      print('📦 Searching in local cache...');
      // Load from cache when offline
      final cached = await _loadCachedAddresses();
      try {
        return cached.firstWhere((a) => a.id == id);
      } catch (e) {
        return null;
      }
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
        final updatedAddress = Address(
          id: data['id'],
          userId: data['user_id'],
          addressType: data['address_type'],
          streetAddress: data['street_address'],
          city: data['city'],
          country: data['country'],
          isDefault: data['is_default'] == true || data['is_default'] == 1,
        );

        // Update cache
        final cachedAddresses = await _loadCachedAddresses();
        final index = cachedAddresses.indexWhere(
          (a) => a.id == updatedAddress.id,
        );
        if (index != -1) {
          cachedAddresses[index] = updatedAddress;
          await _cacheAddresses(cachedAddresses);
        }

        return updatedAddress;
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

        // Remove from cache
        final cachedAddresses = await _loadCachedAddresses();
        cachedAddresses.removeWhere((a) => a.id == addressId);
        await _cacheAddresses(cachedAddresses);

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
  /// Fetch a specific address by ID with offline fallback
  /// Used by delivery persons to view shipping address for assigned orders
  Future<Address?> getAddressById(int addressId) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/addresses/$addressId'),
            headers: headers,
          )
          .timeout(Duration(seconds: 10));

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
        // Try cache on error
        final cached = await _loadCachedAddresses();
        try {
          return cached.firstWhere((a) => a.id == addressId);
        } catch (e) {
          return null;
        }
      }
    } catch (e) {
      print('⚠️ Error fetching address (likely offline): $e');
      print('📦 Searching in local cache...');
      // Load from cache when offline
      final cached = await _loadCachedAddresses();
      try {
        return cached.firstWhere((a) => a.id == addressId);
      } catch (e) {
        return null;
      }
    }
  }
}
