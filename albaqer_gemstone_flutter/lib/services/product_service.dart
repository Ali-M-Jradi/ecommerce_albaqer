import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:albaqer_gemstone_flutter/models/product.dart';

/// Service class for handling all product-related API calls to the backend
class ProductService {
  // Your backend URL - change this to your actual backend address
  final String baseUrl = 'http://localhost:3000';

  // ========== CREATE ==========
  /// Create a new product on the backend
  /// Returns the created Product with its ID, or null if failed
  Future<Product?> createProduct(Product product) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/products'),
        headers: {'Content-Type': 'application/json'},
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
          basePrice: data['base_price'].toDouble(),
          rating: data['rating']?.toDouble() ?? 0.0,
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
      final response = await http.get(Uri.parse('$baseUrl/products'));

      if (response.statusCode == 200) {
        // Success - parse the JSON array
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) {
          return Product(
            id: json['id'],
            name: json['name'],
            type: json['type'],
            description: json['description'],
            basePrice: json['base_price'].toDouble(),
            rating: json['rating']?.toDouble() ?? 0.0,
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
          basePrice: json['base_price'].toDouble(),
          rating: json['rating']?.toDouble() ?? 0.0,
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
      final response = await http.put(
        Uri.parse('$baseUrl/products/${product.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(product.productMap),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Product(
          id: json['id'],
          name: json['name'],
          type: json['type'],
          description: json['description'],
          basePrice: json['base_price'].toDouble(),
          rating: json['rating']?.toDouble() ?? 0.0,
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
      final response = await http.delete(
        Uri.parse('$baseUrl/products/$productId'),
      );

      if (response.statusCode == 200) {
        print('Product deleted successfully');
        return true;
      } else if (response.statusCode == 404) {
        print('Product not found');
        return false;
      } else {
        print('Failed to delete product: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error deleting product: $e');
      return false;
    }
  }
}
