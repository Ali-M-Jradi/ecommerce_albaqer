# 🔄 Bidirectional Database Sync Guide

## ✅ What's Implemented

Your app now has **full bidirectional sync** between:
- **Local SQLite** (on device - offline capable)
- **Backend PostgreSQL** (on server - source of truth)

---

## 🚀 How It Works

### **On App Startup**
```dart
// main.dart automatically:
1. Initializes local database with samples (fallback)
2. Syncs with backend to get real products (17 products)
3. Updates local cache
```

### **All CRUD Operations**
Every operation now works on BOTH databases:

| Operation | Local First | Then Backend | Offline Safe |
|-----------|-------------|--------------|--------------|
| **Add Product** | ✅ Save locally | ✅ Send to backend | ✅ Yes |
| **Update Product** | ✅ Update locally | ✅ Update backend | ✅ Yes |
| **Delete Product** | ✅ Delete locally | ✅ Delete from backend | ✅ Yes |
| **Get Products** | ✅ Load from cache | ✅ Sync if stale | ✅ Yes |
| **Search** | ✅ Search local | ✅ Merge with backend | ✅ Yes |

---

## 📝 How to Use in Your Code

### **Instead of Direct Database Operations**

❌ **OLD WAY (Don't use):**
```dart
// Only updates local - NOT synced!
insertProduct(product);
updateProduct(product);
deleteProduct(product);
```

✅ **NEW WAY (Use this):**
```dart
import 'package:albaqer_gemstone_flutter/services/data_manager.dart';

DataManager manager = DataManager();

// Add product to both databases
await manager.addProduct(newProduct);

// Update product in both databases
await manager.updateProductBidirectional(updatedProduct);

// Delete product from both databases
await manager.deleteProductBidirectional(product);

// Get products (auto-syncs if needed)
List<Product> products = await manager.getProducts();

// Search across both databases
List<Product> results = await manager.searchProductsBidirectional("diamond");

// Force sync anytime
bool synced = await manager.syncWithBackend();
```

---

## 🎯 Real-World Examples

### **Example 1: Admin Adding New Product**
```dart
// In your admin screen
Future<void> addNewProduct() async {
  DataManager manager = DataManager();
  
  Product newProduct = Product(
    id: 0, // Auto-generated
    name: 'Emerald Bracelet',
    type: 'bracelet',
    basePrice: 1200.00,
    quantityInStock: 10,
    // ... other fields
  );
  
  bool success = await manager.addProduct(newProduct);
  
  if (success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ Product added successfully!')),
    );
  }
}
```

### **Example 2: User Browsing Products**
```dart
// In your ProductsScreen
Future<void> _loadProducts() async {
  DataManager manager = DataManager();
  
  // Loads from local cache (instant)
  // Syncs with backend in background if cache is stale
  List<Product> products = await manager.getProducts();
  
  setState(() {
    _products = products;
  });
}
```

### **Example 3: Pull-to-Refresh**
```dart
RefreshIndicator(
  onRefresh: () async {
    DataManager manager = DataManager();
    await manager.syncWithBackend();
    await _loadProducts();
  },
  child: ListView(...),
)
```

### **Example 4: Delete Product**
```dart
Future<void> deleteProduct(Product product) async {
  DataManager manager = DataManager();
  
  bool success = await manager.deleteProductBidirectional(product);
  
  if (success) {
    print('✅ Product deleted from both databases');
  }
}
```

---

## 📊 Sync Status

### **Check Backend Availability**
```dart
DataManager manager = DataManager();
bool isOnline = await manager.isBackendAvailable();

if (isOnline) {
  print('🌐 Backend online');
} else {
  print('📴 Backend offline - using local cache');
}
```

### **Check Last Sync Time**
```dart
DataManager manager = DataManager();
DateTime? lastSync = manager.getLastSyncTime();

if (lastSync != null) {
  print('Last synced: ${lastSync.toLocal()}');
}
```

---

## 🔧 Configuration

### **Adjust Cache Timeout**
```dart
// In data_manager.dart
static const Duration cacheTimeout = Duration(hours: 1); // Change this
```

### **Backend URL**
```dart
// In product_service.dart
final String baseUrl = 'http://10.0.2.2:3000/api'; // Android Emulator
// final String baseUrl = 'http://localhost:3000/api'; // iOS Simulator
// final String baseUrl = 'http://YOUR_IP:3000/api'; // Physical Device
```

---

## 🐛 Troubleshooting

### **Products Not Syncing?**
1. Check backend is running: `node server.js`
2. Test backend: `curl http://localhost:3000/api/products`
3. Check console logs for sync errors
4. Verify network connectivity

### **Duplicate Products?**
- Run full sync: `await manager.syncWithBackend()`
- This replaces local cache with backend data

### **Old Data Showing?**
- Force refresh: `await manager.getProducts(forceRefresh: true)`
- Or pull-to-refresh in UI

---

## ✅ Testing Checklist

Test these scenarios:

- [ ] App starts → Products load from backend
- [ ] Backend offline → Products load from local cache
- [ ] Add product online → Shows in both databases
- [ ] Add product offline → Saves locally, syncs when online
- [ ] Update product → Updates both databases
- [ ] Delete product → Deletes from both
- [ ] Search → Works offline and online
- [ ] Pull-to-refresh → Syncs with backend

---

## 🎯 Next Steps

### **Phase 1: Current (Implemented)** ✅
- Bidirectional CRUD operations
- Automatic sync on startup
- Offline-first strategy
- Manual sync (pull-to-refresh)

### **Phase 2: Advanced (Future)**
- Conflict resolution (what if same product edited offline and online?)
- Optimistic updates (show changes immediately, sync in background)
- Batch operations (bulk insert/update)
- Delta sync (only sync changes, not all products)
- Push notifications (notify app when backend data changes)

### **Phase 3: Production (Later)**
- User-specific data sync (orders, cart, wishlist)
- Authentication with JWT
- Encrypted local storage
- Background sync with WorkManager
- Offline queue for failed operations

---

## 📚 Key Files

- **`lib/main.dart`** - Initial sync on startup
- **`lib/services/data_manager.dart`** - All sync logic
- **`lib/services/product_service.dart`** - Backend API calls
- **`lib/database/product_operations.dart`** - Local database operations

---

## 💡 Pro Tips

1. **Always use DataManager** for product operations
2. **Never call database operations directly** (breaks sync)
3. **Test with backend offline** to ensure offline functionality
4. **Monitor console logs** to see sync status
5. **Use pull-to-refresh** to let users manually sync

---

## 🎉 Summary

Your app now maintains **perfect sync** between local and backend databases:

```
User Action → DataManager → Local SQLite ✅
                         → Backend API ✅
                         → Both Updated! 🎉
```

**Offline?** No problem! Operations save locally and sync when online.

**Online?** Both databases update immediately.

**Result:** Users always see up-to-date data, whether online or offline! 🚀
