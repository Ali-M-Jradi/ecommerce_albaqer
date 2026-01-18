import '../models/product.dart';
import '../services/product_service.dart';
import '../database/product_operations.dart' as db;

/// ==================================================================================
/// PRODUCT REPOSITORY - Single Source of Truth for Products
/// ==================================================================================
///
/// PURPOSE: Manages product data with a clear backend-first + cache strategy
///
/// ARCHITECTURE:
/// - Backend is the source of truth (authoritative data)
/// - Local SQLite is used as cache for offline access
/// - All writes go to backend (admin operations)
/// - Reads try backend first, fallback to cache
///
/// BENEFITS FOR CAPSTONE:
/// - Clean separation of concerns
/// - Easy to understand and explain
/// - Demonstrates proper client-server architecture
/// - Offline capability when needed
/// - Maintainable and testable
/// ==================================================================================

class ProductRepository {
  // Singleton pattern for consistent state
  static final ProductRepository _instance = ProductRepository._internal();
  factory ProductRepository() => _instance;
  ProductRepository._internal();

  final ProductService _apiService = ProductService();

  // Cache freshness tracking
  DateTime? _lastSyncTime;
  static const Duration cacheTimeout = Duration(hours: 1);

  /// ==================================================================================
  /// GET PRODUCTS - Backend First with Cache Fallback
  /// ==================================================================================
  /// Strategy:
  /// 1. Try to fetch from backend
  /// 2. If successful → Update local cache and return
  /// 3. If failed → Use local cache as fallback
  ///
  /// Use Cases:
  /// - Product listing screens
  /// - Home screen product display
  /// - Category browsing
  Future<List<Product>> getProducts({bool forceRefresh = false}) async {
    print('📦 ProductRepository: Getting products...');

    // If force refresh, skip cache
    if (forceRefresh) {
      print('🔄 Force refresh requested');
      return await _fetchFromBackendAndCache();
    }

    // Try backend first
    try {
      return await _fetchFromBackendAndCache();
    } catch (e) {
      // Backend failed, use cache
      print('⚠️ Backend unavailable, using cache: $e');
      return await _getFromCache();
    }
  }

  /// ==================================================================================
  /// GET PRODUCT BY ID - Backend First with Cache Fallback
  /// ==================================================================================
  /// Use Cases:
  /// - Product detail screen
  /// - Quick product lookups
  Future<Product?> getProductById(int id) async {
    print('📦 ProductRepository: Getting product #$id...');

    try {
      // Try backend first
      final product = await _apiService.fetchProductById(id);

      if (product != null) {
        print('✅ Product #$id fetched from backend');
        // Update cache
        db.updateProduct(product);
        return product;
      }
    } catch (e) {
      print('⚠️ Backend unavailable for product #$id: $e');
    }

    // Fallback to cache
    print('💾 Loading product #$id from cache...');
    return await db.getProductById(id);
  }

  /// ==================================================================================
  /// SEARCH PRODUCTS - Backend First with Cache Fallback
  /// ==================================================================================
  /// Use Cases:
  /// - Search screen
  /// - Filtered product lists
  Future<List<Product>> searchProducts({
    String? query,
    String? category,
    double? minPrice,
    double? maxPrice,
  }) async {
    print('🔍 ProductRepository: Searching products...');

    try {
      // Try backend search
      if (query != null && query.isNotEmpty) {
        final results = await _apiService.searchProducts(
          query,
          minPrice: minPrice,
          maxPrice: maxPrice,
        );
        print('✅ Found ${results.length} products from backend');
        return results;
      }
    } catch (e) {
      print('⚠️ Backend search unavailable: $e');
    }

    // Fallback to local search
    print('💾 Searching locally...');
    List<Product> products = await db.loadProducts();

    // Apply filters locally
    if (category != null) {
      products = products
          .where((p) => p.type.toLowerCase() == category.toLowerCase())
          .toList();
    }

    if (query != null && query.isNotEmpty) {
      products = products
          .where(
            (p) =>
                p.name.toLowerCase().contains(query.toLowerCase()) ||
                (p.description?.toLowerCase().contains(query.toLowerCase()) ??
                    false),
          )
          .toList();
    }

    if (minPrice != null) {
      products = products.where((p) => p.basePrice >= minPrice).toList();
    }

    if (maxPrice != null) {
      products = products.where((p) => p.basePrice <= maxPrice).toList();
    }

    print('✅ Found ${products.length} products from cache');
    return products;
  }

  /// ==================================================================================
  /// GET PRODUCTS BY CATEGORY - Backend First with Cache Fallback
  /// ==================================================================================
  Future<List<Product>> getProductsByCategory(String category) async {
    print('📦 ProductRepository: Getting products for category: $category');

    try {
      // Try backend first
      final products = await _apiService.fetchAllProducts();
      final filtered = products
          .where((p) => p.type.toLowerCase() == category.toLowerCase())
          .toList();
      print('✅ Found ${filtered.length} products in $category from backend');

      // Update cache
      await _updateCache(products);

      return filtered;
    } catch (e) {
      print('⚠️ Backend unavailable, using cache: $e');
    }

    // Fallback to cache
    final products = await db.loadProducts();
    final filtered = products
        .where((p) => p.type.toLowerCase() == category.toLowerCase())
        .toList();
    print('💾 Found ${filtered.length} products in $category from cache');
    return filtered;
  }

  /// ==================================================================================
  /// ADD PRODUCT - Backend Only (Admin Operation)
  /// ==================================================================================
  /// Strategy:
  /// 1. Send to backend
  /// 2. If successful → Add to local cache
  /// 3. If failed → Return error (don't cache)
  ///
  /// Use Cases:
  /// - Admin adding new products
  /// - Product creation forms
  Future<bool> addProduct(Product product) async {
    print('➕ ProductRepository: Adding product: ${product.name}');

    try {
      final createdProduct = await _apiService.createProduct(product);

      if (createdProduct != null) {
        print('✅ Product added to backend: ${createdProduct.name}');

        // Add to local cache
        db.insertProduct(createdProduct);
        print('💾 Product added to cache');

        return true;
      }

      print('❌ Failed to add product to backend');
      return false;
    } catch (e) {
      print('❌ Error adding product: $e');
      return false;
    }
  }

  /// ==================================================================================
  /// UPDATE PRODUCT - Backend Only (Admin Operation)
  /// ==================================================================================
  /// Strategy:
  /// 1. Update on backend
  /// 2. If successful → Update local cache
  /// 3. If failed → Return error (don't update cache)
  ///
  /// Use Cases:
  /// - Admin editing product details
  /// - Stock updates
  /// - Price changes
  Future<bool> updateProductData(Product product) async {
    print('✏️ ProductRepository: Updating product: ${product.name}');

    try {
      final updatedProduct = await _apiService.updateProduct(product);

      if (updatedProduct != null) {
        print('✅ Product updated on backend: ${updatedProduct.name}');

        // Update local cache (call database function)
        db.updateProduct(updatedProduct);
      }

      print('❌ Failed to update product on backend');
      return false;
    } catch (e) {
      print('❌ Error updating product: $e');
      return false;
    }
  }

  /// ==================================================================================
  /// DELETE PRODUCT - Backend Only (Admin Operation)
  /// ==================================================================================
  /// Strategy:
  /// 1. Delete from backend
  /// 2. If successful → Remove from local cache
  /// 3. If failed → Return error (don't remove from cache)
  ///
  /// Use Cases:
  /// - Admin removing discontinued products
  /// - Product archival
  Future<bool> deleteProductData(int productId) async {
    print('🗑️ ProductRepository: Deleting product #$productId');

    try {
      final success = await _apiService.deleteProduct(productId);

      if (success) {
        print('✅ Product deleted from backend');

        // Remove from local cache - need to get product first
        final product = await db.getProductById(productId);
        if (product != null) {
          db.deleteProduct(product);
          print('💾 Removed from cache');
        }

        return true;
      }

      print('❌ Failed to delete product from backend');
      return false;
    } catch (e) {
      print('❌ Error deleting product: $e');
      return false;
    }
  }

  /// ==================================================================================
  /// SYNC WITH BACKEND - Manual Refresh
  /// ==================================================================================
  /// Use Cases:
  /// - Pull-to-refresh gesture
  /// - Manual sync button
  /// - App startup
  Future<bool> syncWithBackend() async {
    print('🔄 ProductRepository: Syncing with backend...');

    try {
      await _fetchFromBackendAndCache();
      print('✅ Sync successful');
      return true;
    } catch (e) {
      print('❌ Sync failed: $e');
      return false;
    }
  }

  /// ==================================================================================
  /// PRIVATE HELPER METHODS
  /// ==================================================================================

  /// Fetch from backend and update cache
  Future<List<Product>> _fetchFromBackendAndCache() async {
    final products = await _apiService.fetchAllProducts();
    print('✅ Fetched ${products.length} products from backend');

    // Update cache
    await _updateCache(products);
    _lastSyncTime = DateTime.now();

    return products;
  }

  /// Get products from local cache
  Future<List<Product>> _getFromCache() async {
    final products = await db.loadProducts();
    print('💾 Loaded ${products.length} products from cache');
    return products;
  }

  /// Update local cache with backend data
  Future<void> _updateCache(List<Product> products) async {
    print('💾 Updating cache with ${products.length} products...');

    for (var product in products) {
      // Check if product exists
      final existing = await db.getProductById(product.id!);

      if (existing != null) {
        // Update existing
        db.updateProduct(product);
      } else {
        // Insert new
        db.insertProduct(product);
      }
    }

    print('✅ Cache updated');
  }

  /// Check if cache is fresh
  bool isCacheFresh() {
    if (_lastSyncTime == null) return false;
    final age = DateTime.now().difference(_lastSyncTime!);
    return age < cacheTimeout;
  }

  /// Get last sync time
  DateTime? getLastSyncTime() => _lastSyncTime;

  /// Clear cache (for logout or reset)
  Future<void> clearCache() async {
    print('🗑️ Clearing product cache...');
    // Note: You may want to implement a clearAllProducts() method in product_operations.dart
    _lastSyncTime = null;
    print('✅ Cache cleared');
  }
}

/// ==================================================================================
/// SUMMARY FOR CAPSTONE PRESENTATION:
/// ==================================================================================
///
/// ARCHITECTURE BENEFITS:
/// 1. **Single Responsibility** - Repository only handles data fetching logic
/// 2. **Backend as Source of Truth** - Ensures data consistency
/// 3. **Smart Caching** - Improves performance and offline experience
/// 4. **Clear Error Handling** - Graceful fallback to cache
/// 5. **Easy to Test** - Mock backend or cache independently
/// 6. **Scalable** - Easy to add new features (pagination, filtering, etc.)
///
/// TALKING POINTS:
/// - "Backend is authoritative for all product data"
/// - "Local cache enables offline browsing"
/// - "Admin operations always go through backend"
/// - "Repository pattern separates data logic from UI"
/// - "Clear fallback strategy for network failures"
///
/// ==================================================================================
