import 'dart:async';
import 'package:http/http.dart' as http;

import 'package:albaqer_gemstone_flutter/repositories/product_repository.dart';
import 'package:albaqer_gemstone_flutter/database/category_operations.dart';
import 'package:albaqer_gemstone_flutter/models/product.dart';
import 'package:albaqer_gemstone_flutter/models/category.dart';

/// ==================================================================================
/// DATA MANAGER - Simplified Coordinator for Data Operations
/// ==================================================================================
///
/// UPDATED PURPOSE: Acts as a coordinator, delegating to appropriate repositories
///
/// ARCHITECTURE CHANGES:
/// - Product operations → Delegated to ProductRepository
/// - Category operations → Still handles directly (simple, local-only)
/// - Removed bidirectional CRUD complexity
/// - Cleaner separation of concerns
///
/// BENEFITS:
/// - Easier to understand
/// - ProductRepository handles all product logic
/// - DataManager focuses on coordination and categories
/// - Maintains backward compatibility for existing code
/// ==================================================================================

class DataManager {
  // Singleton pattern
  static final DataManager _instance = DataManager._internal();
  factory DataManager() => _instance;
  DataManager._internal();

  final ProductRepository _productRepository = ProductRepository();

  /// ==================================================================================
  /// PRODUCT OPERATIONS - Delegated to ProductRepository
  /// ==================================================================================

  /// Get products with smart backend-first + cache strategy
  /// This method delegates to ProductRepository
  Future<List<Product>> getProducts({bool forceRefresh = false}) async {
    return await _productRepository.getProducts(forceRefresh: forceRefresh);
  }

  /// Get product by ID
  Future<Product?> getProductById(int id) async {
    return await _productRepository.getProductById(id);
  }

  /// Search products
  Future<List<Product>> searchProductsBidirectional(String query) async {
    return await _productRepository.searchProducts(query: query);
  }

  /// Get products by category
  Future<List<Product>> getProductsByCategory(String category) async {
    return await _productRepository.getProductsByCategory(category);
  }

  /// Add product (admin operation)
  Future<bool> addProduct(Product product) async {
    return await _productRepository.addProduct(product);
  }

  /// Update product (admin operation)
  Future<bool> updateProductBidirectional(Product product) async {
    return await _productRepository.updateProductData(product);
  }

  /// Delete product (admin operation)
  Future<bool> deleteProductBidirectional(Product product) async {
    if (product.id == null) return false;
    return await _productRepository.deleteProductData(product.id!);
  }

  /// Manual sync with backend
  Future<bool> syncWithBackend() async {
    return await _productRepository.syncWithBackend();
  }

  /// Check if backend is available
  Future<bool> isBackendAvailable() async {
    try {
      final response = await http
          .get(Uri.parse('http://10.91.89.60:3000/api/health'))
          .timeout(
            Duration(seconds: 5),
            onTimeout: () {
              throw TimeoutException('Backend timeout');
            },
          );
      return response.statusCode == 200;
    } catch (e) {
      print('⚠️ Backend unavailable: $e');
      return false;
    }
  }

  /// Get last sync time from ProductRepository
  DateTime? getLastSyncTime() => _productRepository.getLastSyncTime();

  /// Clear cache
  Future<void> clearCache() async {
    await _productRepository.clearCache();
  }

  /// ==================================================================================
  /// CATEGORY OPERATIONS - Handled Directly (Local Only)
  /// ==================================================================================

  /// Get categories with offline-first strategy
  /// Loads from local database only (no backend dependency)
  Future<List<String>> getCategoriesOfflineFirst() async {
    print('📂 Loading categories from local database...');

    // Load categories from the categories table
    List<Category> categoryObjects = await loadCategories();
    List<String> categoryNames = categoryObjects.map((c) => c.name).toList();

    print('✅ Loaded ${categoryNames.length} categories from local database');

    return categoryNames;
  }
}

/// ==================================================================================
/// BACKWARD COMPATIBILITY NOTE:
/// ==================================================================================
///
/// This simplified version maintains the same public API as before, so existing
/// screens don't need to change immediately. However, it's recommended to:
///
/// 1. Gradually migrate screens to use ProductRepository directly
/// 2. This shows clearer architecture in your capstone
/// 3. DataManager can eventually be removed or kept for coordination only
///
/// ==================================================================================
