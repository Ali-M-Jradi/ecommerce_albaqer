import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:albaqer_gemstone_flutter/models/address.dart';

/// Service class for handling all address-related API calls to the backend
class AddressService {
  final String baseUrl = 'http://localhost:3000';

  // ========== CREATE ==========
  /// Create a new address on the backend
  Future<Address?> createAddress(Address address) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/addresses'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(address.addressMap),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Address(
          id: data['id'],
          userId: data['user_id'],
          addressType: data['address_type'],
          streetAddress: data['street_address'],
          city: data['city'],
          country: data['country'],
          isDefault: data['is_default'] == 1,
        );
      } else {
        print('Failed to create address: ${response.statusCode}');
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
      final response = await http.get(Uri.parse('$baseUrl/addresses'));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) {
          return Address(
            id: json['id'],
            userId: json['user_id'],
            addressType: json['address_type'],
            streetAddress: json['street_address'],
            city: json['city'],
            country: json['country'],
            isDefault: json['is_default'] == 1,
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
  /// Fetch addresses for a specific user
  Future<List<Address>> fetchAddressesByUserId(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/addresses?user_id=$userId'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) {
          return Address(
            id: json['id'],
            userId: json['user_id'],
            addressType: json['address_type'],
            streetAddress: json['street_address'],
            city: json['city'],
            country: json['country'],
            isDefault: json['is_default'] == 1,
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
      final response = await http.get(Uri.parse('$baseUrl/addresses/$id'));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Address(
          id: json['id'],
          userId: json['user_id'],
          addressType: json['address_type'],
          streetAddress: json['street_address'],
          city: json['city'],
          country: json['country'],
          isDefault: json['is_default'] == 1,
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
      final response = await http.put(
        Uri.parse('$baseUrl/addresses/${address.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(address.addressMap),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Address(
          id: json['id'],
          userId: json['user_id'],
          addressType: json['address_type'],
          streetAddress: json['street_address'],
          city: json['city'],
          country: json['country'],
          isDefault: json['is_default'] == 1,
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
  Future<bool> deleteAddress(int addressId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/addresses/$addressId'),
      );

      if (response.statusCode == 200) {
        print('Address deleted successfully');
        return true;
      } else if (response.statusCode == 404) {
        print('Address not found');
        return false;
      } else {
        print('Failed to delete address: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error deleting address: $e');
      return false;
    }
  }
}
