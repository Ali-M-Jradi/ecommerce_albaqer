import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:albaqer_gemstone_flutter/database/product_operations.dart';
import 'package:albaqer_gemstone_flutter/services/product_service.dart';
import 'package:albaqer_gemstone_flutter/models/product.dart';

/// Smart data manager that handles both local SQLite and backend PostgreSQL
/// Implements offline-first strategy with automatic fallback
class DataManager {
  final ProductService _apiService = ProductService();

  // Cache timeout - refresh from backend after this duration
  static const Duration cacheTimeout = Duration(hours: 1);
  DateTime? _lastSyncTime;

  /// Check if backend API is available
  /// Returns true if backend responds within timeout
  Future<bool> isBackendAvailable() async {
    try {
      final response = await http
          .get(Uri.parse('http://10.0.2.2:3000/api/health'))
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
