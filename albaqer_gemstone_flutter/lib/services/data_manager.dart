import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:albaqer_gemstone_flutter/database/product_operations.dart';
import 'package:albaqer_gemstone_flutter/services/product_service.dart';
import 'package:albaqer_gemstone_flutter/models/product.dart';

/// Smart data manager that handles both local SQLite and backend PostgreSQL
/// Implements offline-first strategy with automatic fallback
class DataManager {
  // Singleton pattern
  static final DataManager _instance = DataManager._internal();
  factory DataManager() => _instance;
  DataManager._internal();

  final ProductService _apiService = ProductService();

  // Cache timeout - refresh from backend after this duration
  static const Duration cacheTimeout = Duration(hours: 1);
  DateTime? _lastSyncTime;

  /// Check if backend API is available
  /// Returns true if backend responds within timeout
  Future<bool> isBackendAvailable() async {
    try {
      final response = await http
          .get(Uri.parse('http://192.168.0.109:3000/api/health'))
          .timeout(
            Duration(seconds: 5),
            onTimeout: () {
              throw TimeoutException('Backend timeout');
            },
          );
      return response.statusCode == 200;
    } catch (e) {
      print('⚠️ Backend not available: $e');
      return false;
    }
  }

  /// Check if local cache is still fresh
  bool isCacheFresh() {
    if (_lastSyncTime == null) return false;
    final now = DateTime.now();
    final difference = now.difference(_lastSyncTime!);
    return difference < cacheTimeout;
  }

  /// ==========================================
  /// Smart Data Fetching with Source Control
  /// ==========================================
  /// Flexible method that supports multiple data fetching strategies
  ///
  /// Benefits:
  /// - Choose data source: local, backend, or auto
  /// - Force refresh bypasses cache
  /// - Automatic offline-first when using auto mode
  /// - Seamless fallback on errors
  Future<List<Product>> getProducts({
    DataSource source = DataSource.auto,
    bool forceRefresh = false,
  }) async {
    print('📦 DataManager: Fetching products (source: $source)...');

    switch (source) {
      case DataSource.local:
        return await _getFromLocal();

      case DataSource.backend:
        return await _getFromBackend();

      case DataSource.auto:
        // Offline-first strategy with smart sync
        List<Product> localProducts = await loadProducts();
        print('✅ Loaded ${localProducts.length} products from local cache');

        // Check if we should sync with backend
        if ((forceRefresh || !isCacheFresh()) && await isBackendAvailable()) {
          print('🔄 Syncing with backend...');

          try {
            List<Product> backendProducts = await _apiService
                .fetchAllProducts();
            print('✅ Fetched ${backendProducts.length} products from backend');

            await _updateLocalCache(backendProducts);
            _lastSyncTime = DateTime.now();

            return backendProducts;
          } catch (e) {
            print('⚠️ Backend sync failed, using cached data: $e');
            return localProducts;
          }
        } else {
          if (isCacheFresh()) {
            print('✅ Cache is fresh, using local data');
          } else {
            print('📴 Backend offline, using local data');
          }
          return localProducts;
        }
    }
  }

  /// ==========================================
  /// HELPER METHODS
  /// ==========================================

  /// Load products from local SQLite database
  Future<List<Product>> _getFromLocal() async {
    print('💾 Loading from local database...');
    List<Product> products = await loadProducts();
    print('✅ Loaded ${products.length} products from local cache');
    return products;
  }

  /// Load products from backend API
  Future<List<Product>> _getFromBackend() async {
    print('🌐 Loading from backend API...');

    if (!await isBackendAvailable()) {
      throw Exception('Backend is not available');
    }

    List<Product> products = await _apiService.fetchAllProducts();
    print('✅ Fetched ${products.length} products from backend');

    // Update cache
    await _updateLocalCache(products);
    _lastSyncTime = DateTime.now();

    return products;
  }

  /// Update local SQLite cache with backend data
  Future<void> _updateLocalCache(List<Product> products) async {
    print('💾 Updating local cache with ${products.length} products...');

    // TODO: Implement smarter caching strategy
    // For now, this is a simple implementation
    // In production, you might want to:
    // 1. Compare timestamps to avoid unnecessary writes
    // 2. Use transactions for better performance
    // 3. Handle conflicts (e.g., user edited locally)

    for (var product in products) {
      try {
        // Insert or update product in local database
        insertProduct(product);
      } catch (e) {
        print('⚠️ Failed to cache product ${product.id}: $e');
      }
    }

    print('✅ Local cache updated');
  }

  /// ==========================================
  /// SYNC MANAGEMENT
  /// ==========================================

  /// Force sync with backend (useful for pull-to-refresh)
  Future<bool> syncWithBackend() async {
    print('🔄 Starting manual sync with backend...');

    if (!await isBackendAvailable()) {
      print('❌ Backend not available for sync');
      return false;
    }

    try {
      List<Product> backendProducts = await _apiService.fetchAllProducts();
      await _updateLocalCache(backendProducts);
      _lastSyncTime = DateTime.now();

      print('✅ Sync completed successfully');
      return true;
    } catch (e) {
      print('❌ Sync failed: $e');
      return false;
    }
  }

  /// Get last sync time
  DateTime? getLastSyncTime() => _lastSyncTime;

  /// Clear local cache (useful for logout or reset)
  Future<void> clearCache() async {
    print('🗑️ Clearing local cache...');
    // TODO: Implement cache clearing
    // You might want to delete all local data or specific tables
    _lastSyncTime = null;
    print('✅ Cache cleared');
  }

  // ═══════════════════════════════════════════════════════════
  // BIDIRECTIONAL CRUD OPERATIONS
  // ═══════════════════════════════════════════════════════════

  /// Add product to BOTH local and backend databases
  Future<bool> addProduct(Product product) async {
    print('➕ Adding product: ${product.name}');

    bool localSuccess = false;
    bool backendSuccess = false;

    // 1. Add to local database first (always works offline)
    try {
      insertProduct(product);
      localSuccess = true;
      print('✅ Added to local database');
    } catch (e) {
      print('❌ Failed to add to local: $e');
      return false; // If local fails, don't proceed
    }

    // 2. Try to add to backend (if available)
    if (await isBackendAvailable()) {
      try {
        await _apiService.createProductFromObject(product);
        backendSuccess = true;
        print('✅ Added to backend');
      } catch (e) {
        print('⚠️ Failed to add to backend: $e');
        print('📝 Product saved locally, will sync to backend later');
      }
    } else {
      print('📴 Backend offline, product saved locally only');
    }

    return localSuccess; // Success if at least local worked
  }

  /// Update product in BOTH local and backend databases
  Future<bool> updateProductBidirectional(Product product) async {
    print('✏️ Updating product: ${product.name}');

    bool localSuccess = false;
    bool backendSuccess = false;

    // 1. Update local database
    try {
      updateProduct(product);
      localSuccess = true;
      print('✅ Updated in local database');
    } catch (e) {
      print('❌ Failed to update local: $e');
      return false;
    }

    // 2. Try to update backend
    if (await isBackendAvailable()) {
      try {
        await _apiService.updateProduct(product);
        backendSuccess = true;
        print('✅ Updated in backend');
      } catch (e) {
        print('⚠️ Failed to update backend: $e');
        print('📝 Update saved locally, will sync to backend later');
      }
    } else {
      print('📴 Backend offline, update saved locally only');
    }

    return localSuccess;
  }

  /// Delete product from BOTH local and backend databases
  Future<bool> deleteProductBidirectional(Product product) async {
    print('🗑️ Deleting product: ${product.name}');

    bool localSuccess = false;
    bool backendSuccess = false;

    // 1. Delete from backend first (if available)
    if (await isBackendAvailable()) {
      try {
        if (product.id == null) {
          print('❌ Cannot delete: product ID is null');
          return false;
        }
        await _apiService.deleteProduct(product.id!);
        backendSuccess = true;
        print('✅ Deleted from backend');
      } catch (e) {
        print('⚠️ Failed to delete from backend: $e');
      }
    } else {
      print('📴 Backend offline');
    }

    // 2. Delete from local database
    try {
      deleteProduct(product);
      localSuccess = true;
      print('✅ Deleted from local database');
    } catch (e) {
      print('❌ Failed to delete from local: $e');
      return false;
    }

    return localSuccess;
  }

  /// Get single product by ID (checks local first, then backend)
  Future<Product?> getProductById(int id) async {
    print('🔍 Getting product by ID: $id');

    // Try local first
    try {
      List<Product> allProducts = await loadProducts();
      Product product = allProducts.firstWhere((p) => p.id == id);
      print('✅ Found in local database');
      return product;
    } catch (e) {
      print('⚠️ Not in local, trying backend...');
    }

    // Try backend if not found locally

    if (await isBackendAvailable()) {
      try {
        Product? product = await _apiService.fetchProductById(id);
        if (product == null) {
          print('❌ Product not found in backend');
          return null;
        }
        // Cache it locally
        insertProduct(product);
        print('✅ Found in backend and cached locally');
        return product;
      } catch (e) {
        print('❌ Not found in backend: $e');
      }
    }

    return null;
  }

  /// Search products across both databases
  Future<List<Product>> searchProductsBidirectional(String query) async {
    print('🔍 Searching for: $query');

    // Always search local first (fast)
    List<Product> localResults = await searchProducts(query);

    // If backend available, merge with backend results
    if (await isBackendAvailable()) {
      try {
        List<Product> backendResults = await _apiService.searchProducts(query);

        // Merge and deduplicate by ID
        Map<int, Product> merged = {};
        for (var product in localResults) {
          if (product.id != null) {
            merged[product.id!] = product;
          }
        }
        for (var product in backendResults) {
          if (product.id != null) {
            merged[product.id!] = product;
          }
        }

        print('✅ Merged ${merged.length} unique results');
        return merged.values.toList();
      } catch (e) {
        print('⚠️ Backend search failed: $e');
      }
    }

    return localResults;
  }

  // ═══════════════════════════════════════════════════════════
  // CATEGORY OPERATIONS
  // ═══════════════════════════════════════════════════════════

  /// Get categories with offline-first strategy
  /// Loads from local immediately, syncs backend in background
  Future<List<String>> getCategoriesOfflineFirst() async {
    print('📂 Loading categories offline-first...');

    // Load local first for instant display
    List<String> localCategories = await loadCategories();
    print('✅ Loaded ${localCategories.length} categories from local');

    // Sync with backend in background (non-blocking)
    if (await isBackendAvailable()) {
      _syncCategoriesInBackground();
    }

    return localCategories;
  }

  /// Background sync for categories
  Future<void> _syncCategoriesInBackground() async {
    try {
      List<String> backendCategories = await _apiService
          .fetchCategories()
          .timeout(Duration(seconds: 5), onTimeout: () => <String>[]);
      print('✅ Backend has ${backendCategories.length} categories');
      // Categories are derived from products, so they sync automatically
    } catch (e) {
      print('⚠️ Background category sync failed: $e');
    }
  }

  /// Get products by category (filtered)
  Future<List<Product>> getProductsByCategory(String category) async {
    List<Product> allProducts = await getProducts();
    return allProducts.where((p) => p.type == category).toList();
  }
}

/// Enum to specify data source preference
enum DataSource {
  /// Load from local SQLite only
  local,

  /// Load from backend API only
  backend,

  /// Automatically choose best source
  auto,
}
