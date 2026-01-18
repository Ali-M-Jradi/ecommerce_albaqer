import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:albaqer_gemstone_flutter/models/product.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service class for handling all product-related API calls to the backend
class ProductService {
  // For Android Emulator: use 10.0.2.2 (maps to host machine's localhost)
  // For physical device/iOS simulator: use your computer's IP address
  final String baseUrl = 'http://10.91.89.60:3000/api';

  /// Get authentication headers with token
  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(
      'token',
    ); // Changed from 'auth_token' to 'token'

    print(
      '🔍 Retrieved token: ${token != null ? "Found (${token.substring(0, 10)}...)" : "Not found"}',
    );

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Helper to safely convert to double from dynamic (handles both String and num)
  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // ========== CREATE ==========
  /// Create a new product on the backend
  /// Returns the created Product with its ID, or null if failed
  Future<Product?> createProduct(Product product) async {
    try {
      final headers = await _getAuthHeaders();

      final response = await http.post(
        Uri.parse('$baseUrl/products'),
        headers: headers,
        body: jsonEncode(product.productMap),
      );

      if (response.statusCode == 201) {
        // Success - backend created the product
        final data = jsonDecode(response.body);
        return Product(
          id: data['id'],
          name: data['name'],
          type: data['type'],
          description: data['description'],
          basePrice: _toDouble(data['base_price']),
          rating: _toDouble(data['rating']),
          totalReviews: data['total_reviews'] ?? 0,
          quantityInStock: data['quantity_in_stock'],
          imageUrl: data['image_url'],
          isAvailable: data['is_available'] ?? true,
          createdAt: data['created_at'] != null
              ? DateTime.parse(data['created_at'])
              : null,
          updatedAt: data['updated_at'] != null
              ? DateTime.parse(data['updated_at'])
              : null,
          metalType: data['metal_type'],
          metalColor: data['metal_color'],
          metalPurity: data['metal_purity'],
          metalWeightGrams: _toDouble(data['metal_weight_grams']),
          stoneType: data['stone_type'],
          stoneColor: data['stone_color'],
          stoneCarat: _toDouble(data['stone_carat']),
          stoneCut: data['stone_cut'],
          stoneClarity: data['stone_clarity'],
        );
      } else {
        print('Failed to create product: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error creating product: $e');
      return null;
    }
  }

  // ========== READ (ALL) ==========
  /// Fetch all products from the backend
  /// Returns a list of products, or empty list if failed
  Future<List<Product>> fetchAllProducts() async {
    try {
      print('📡 Fetching products from: $baseUrl/products');

      final response = await http
          .get(Uri.parse('$baseUrl/products'))
          .timeout(Duration(seconds: 10));

      print('📥 Response status: ${response.statusCode}');
      print('📦 Response body length: ${response.body.length}');

      if (response.statusCode == 200) {
        // Success - parse the JSON response with wrapped data
        final jsonResponse = jsonDecode(response.body);
        print('✅ JSON decoded successfully');
        List<dynamic> data = jsonResponse['data'];
        print('📊 Found ${data.length} products');

        return data.map((json) {
          return Product(
            id: json['id'],
            name: json['name'],
            type: json['type'],
            description: json['description'],
            basePrice: _toDouble(json['base_price']),
            rating: _toDouble(json['rating']),
            totalReviews: json['total_reviews'] ?? 0,
            quantityInStock: json['quantity_in_stock'],
            imageUrl: json['image_url'],
            isAvailable: json['is_available'] ?? true,
            createdAt: json['created_at'] != null
                ? DateTime.parse(json['created_at'])
                : null,
            updatedAt: json['updated_at'] != null
                ? DateTime.parse(json['updated_at'])
                : null,
            metalType: json['metal_type'],
            metalColor: json['metal_color'],
            metalPurity: json['metal_purity'],
            metalWeightGrams: _toDouble(json['metal_weight_grams']),
            stoneType: json['stone_type'],
            stoneColor: json['stone_color'],
            stoneCarat: _toDouble(json['stone_carat']),
            stoneCut: json['stone_cut'],
            stoneClarity: json['stone_clarity'],
          );
        }).toList();
      } else {
        print('Failed to fetch products: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }

  // ========== READ (BY ID) ==========
  /// Fetch a single product by ID from the backend
  /// Returns the product or null if not found or failed
  Future<Product?> fetchProductById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products/$id'));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Product(
          id: json['id'],
          name: json['name'],
          type: json['type'],
          description: json['description'],
          basePrice: _toDouble(json['base_price']),
          rating: _toDouble(json['rating']),
          totalReviews: json['total_reviews'] ?? 0,
          quantityInStock: json['quantity_in_stock'],
          imageUrl: json['image_url'],
          isAvailable: json['is_available'] ?? true,
          createdAt: json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
          updatedAt: json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
          metalType: json['metal_type'],
          metalColor: json['metal_color'],
          metalPurity: json['metal_purity'],
          metalWeightGrams: _toDouble(json['metal_weight_grams']),
          stoneType: json['stone_type'],
          stoneColor: json['stone_color'],
          stoneCarat: _toDouble(json['stone_carat']),
          stoneCut: json['stone_cut'],
          stoneClarity: json['stone_clarity'],
        );
      } else if (response.statusCode == 404) {
        print('Product not found');
        return null;
      } else {
        print('Failed to fetch product: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching product: $e');
      return null;
    }
  }

  // ========== UPDATE ==========
  /// Update an existing product on the backend
  /// Returns the updated product or null if failed
  Future<Product?> updateProduct(Product product) async {
    try {
      final headers = await _getAuthHeaders();

      final response = await http.put(
        Uri.parse('$baseUrl/products/${product.id}'),
        headers: headers,
        body: jsonEncode(product.productMap),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Product(
          id: json['id'],
          name: json['name'],
          type: json['type'],
          description: json['description'],
          basePrice: _toDouble(json['base_price']),
          rating: _toDouble(json['rating']),
          totalReviews: json['total_reviews'] ?? 0,
          quantityInStock: json['quantity_in_stock'],
          imageUrl: json['image_url'],
          isAvailable: json['is_available'] ?? true,
          createdAt: json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
          updatedAt: json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
          metalType: json['metal_type'],
          metalColor: json['metal_color'],
          metalPurity: json['metal_purity'],
          metalWeightGrams: _toDouble(json['metal_weight_grams']),
          stoneType: json['stone_type'],
          stoneColor: json['stone_color'],
          stoneCarat: _toDouble(json['stone_carat']),
          stoneCut: json['stone_cut'],
          stoneClarity: json['stone_clarity'],
        );
      } else if (response.statusCode == 404) {
        print('Product not found');
        return null;
      } else {
        print('Failed to update product: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error updating product: $e');
      return null;
    }
  }

  // ========== DELETE ==========
  /// Delete a product from the backend
  /// Returns true if successful, false otherwise
  Future<bool> deleteProduct(int productId) async {
    try {
      final headers = await _getAuthHeaders();
      print('🔑 Delete headers: $headers');
      print('🗑️ Deleting product ID: $productId');

      final response = await http.delete(
        Uri.parse('$baseUrl/products/$productId'),
        headers: headers,
      );

      print('📡 Delete response: ${response.statusCode}');
      print('📄 Delete body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Product deleted successfully');
        return true;
      } else if (response.statusCode == 404) {
        print('❌ Product not found');
        return false;
      } else {
        print('❌ Failed to delete product: ${response.statusCode}');
        print('Error details: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error deleting product: $e');
      return false;
    }
  }

  // ========== GET CATEGORIES ==========
  /// Fetch all unique product categories from the backend
  /// Returns a list of category names, or empty list if failed
  Future<List<String>> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/categories'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        List<dynamic> data = jsonResponse['data'];
        return data.map((category) => category.toString()).toList();
      } else {
        print('Failed to fetch categories: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  // ========== SEARCH PRODUCTS ==========
  /// Search products by query, type, price range
  /// Returns a list of matching products
  Future<List<Product>> searchProducts(
    String query, {
    String? type,
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      // Build query parameters
      Map<String, String> queryParams = {};
      if (query.isNotEmpty) {
        queryParams['query'] = query;
      }
      if (type != null) {
        queryParams['type'] = type;
      }
      if (minPrice != null) {
        queryParams['minPrice'] = minPrice.toString();
      }
      if (maxPrice != null) {
        queryParams['maxPrice'] = maxPrice.toString();
      }

      final uri = Uri.parse(
        '$baseUrl/products/search',
      ).replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        List<dynamic> data = jsonResponse['data'];
        return data.map((json) {
          return Product(
            id: json['id'],
            name: json['name'],
            type: json['type'],
            description: json['description'],
            basePrice: _toDouble(json['base_price']),
            rating: _toDouble(json['rating']),
            totalReviews: json['total_reviews'] ?? 0,
            quantityInStock: json['quantity_in_stock'],
            imageUrl: json['image_url'],
            isAvailable: json['is_available'] ?? true,
            createdAt: json['created_at'] != null
                ? DateTime.parse(json['created_at'])
                : null,
            updatedAt: json['updated_at'] != null
                ? DateTime.parse(json['updated_at'])
                : null,
            metalType: json['metal_type'],
            metalColor: json['metal_color'],
            metalPurity: json['metal_purity'],
            metalWeightGrams: _toDouble(json['metal_weight_grams']),
            stoneType: json['stone_type'],
            stoneColor: json['stone_color'],
            stoneCarat: _toDouble(json['stone_carat']),
            stoneCut: json['stone_cut'],
            stoneClarity: json['stone_clarity'],
          );
        }).toList();
      } else {
        print('Failed to search products: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error searching products: $e');
      return [];
    }
  }
}
