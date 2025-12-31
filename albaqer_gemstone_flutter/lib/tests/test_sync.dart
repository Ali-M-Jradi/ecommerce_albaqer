// Test script to verify bidirectional sync
// Run this in your app to test sync functionality

import 'package:albaqer_gemstone_flutter/services/data_manager.dart';
import 'package:albaqer_gemstone_flutter/models/product.dart';

/// Test bidirectional sync
Future<void> testBidirectionalSync() async {
  print('🧪 Testing Bidirectional Sync...\n');

  DataManager manager = DataManager();

  // Test 1: Check backend availability
  print('📡 Test 1: Backend Availability');
  bool isOnline = await manager.isBackendAvailable();
  print('Backend status: ${isOnline ? "🟢 Online" : "🔴 Offline"}\n');

  // Test 2: Initial sync
  print('🔄 Test 2: Initial Sync');
  bool synced = await manager.syncWithBackend();
  print('Sync result: ${synced ? "✅ Success" : "❌ Failed"}\n');

  // Test 3: Get products
  print('📦 Test 3: Get Products');
  List<Product> products = await manager.getProducts();
  print('Total products: ${products.length}');
  print('First 3 products:');
  for (var i = 0; i < products.length && i < 3; i++) {
    print('  ${i + 1}. ${products[i].name} - \$${products[i].basePrice}');
  }
  print('');

  // Test 4: Add new product (if online)
  if (isOnline) {
    print('➕ Test 4: Add Product');
    Product testProduct = Product(
      id: 0,
      name: 'Test Sync Product',
      type: 'ring',
      description: 'Testing bidirectional sync',
      basePrice: 99.99,
      quantityInStock: 1,
      rating: 0,
      totalReviews: 0,
      isAvailable: true,
    );

    bool added = await manager.addProduct(testProduct);
    print('Add result: ${added ? "✅ Success" : "❌ Failed"}');

    // Verify it's in both databases
    List<Product> afterAdd = await manager.getProducts(forceRefresh: true);
    bool foundInSync = afterAdd.any((p) => p.name == 'Test Sync Product');
    print('Found in sync: ${foundInSync ? "✅ Yes" : "❌ No"}\n');
  } else {
    print('⚠️ Test 4: Skipped (backend offline)\n');
  }

  // Test 5: Search
  print('🔍 Test 5: Search Products');
  List<Product> searchResults = await manager.searchProductsBidirectional(
    'ring',
  );
  print('Search results for "ring": ${searchResults.length} products\n');

  // Test 6: Check sync time
  print('⏰ Test 6: Last Sync Time');
  DateTime? lastSync = manager.getLastSyncTime();
  if (lastSync != null) {
    Duration diff = DateTime.now().difference(lastSync);
    print('Last synced: ${diff.inSeconds} seconds ago');
  } else {
    print('Never synced');
  }

  print('\n✅ All tests completed!');
}

// Call this in your app to test
// Example: In a button's onPressed:
// ElevatedButton(
//   onPressed: testBidirectionalSync,
//   child: Text('Test Sync'),
// )
