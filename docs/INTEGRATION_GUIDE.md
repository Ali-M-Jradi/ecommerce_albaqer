# 🎯 Integration Guide: Connecting Flutter to Your PostgreSQL Backend

## ✅ Current Status

Your backend is **fully operational** with:
- PostgreSQL database: `albaqer_gemstone_ecommerce_db`
- 12 tables with complete schema
- Backend API running on port 3000
- Environment configured in `.env`

## 📋 Your Database Tables

Based on your actual PostgreSQL schema, you have:

### Core Tables
1. **users** (8 columns) - User authentication and profiles
2. **products** (21 columns) - Complete product catalog with metal/stone specs
3. **orders** (14 columns) - Order management with shipping and tracking
4. **order_items** (5 columns) - Individual items in orders

### E-commerce Features
5. **payments** (10 columns) - Payment processing and transactions
6. **carts** (4 columns) - User shopping carts
7. **cart_items** (5 columns) - Items in shopping carts
8. **addresses** (7 columns) - Shipping and billing addresses

### Product Organization
9. **categories** (4 columns) - Product category hierarchy
10. **product_categories** (2 columns) - Many-to-many product-category relationships

### User Engagement
11. **reviews** (11 columns) - Product reviews and ratings
12. **wishlists** (4 columns) - User wishlists

---

## 🚀 Quick Start: Using Your Backend Right Now

### 1. Start Your Backend Server

```powershell
cd "C:\Users\hp 15\Desktop\flutter_university\ecommerce_albaqer\albaqer_gemstone_backend"
node server.js
```

Expected output:
```
✅ Connected to PostgreSQL database
🚀 Server running on port 3000
📊 Environment: development
🌐 Accessible at: http://localhost:3000 and http://10.0.2.2:3000
```

### 2. Test Your API Endpoints

```powershell
# Health check
curl http://localhost:3000/api/health

# Database connection test
curl http://localhost:3000/api/test-db

# Get all products
curl http://localhost:3000/api/products

# Get specific product
curl http://localhost:3000/api/products/1
```

---

## 🔄 Integrating DataManager with Your Flutter App

### Step 1: Verify Backend Connectivity

Your Flutter services already point to the backend at `http://10.0.2.2:3000/api` (for Android Emulator).

Current files:
- [product_service.dart](albaqer_gemstone_flutter/lib/services/product_service.dart)
- [user_service.dart](albaqer_gemstone_flutter/lib/services/user_service.dart)
- [order_service.dart](albaqer_gemstone_flutter/lib/services/order_service.dart)

### Step 2: Use DataManager in Your Screens

Replace direct database calls with DataManager for intelligent caching:

#### Example: Updating a Product List Screen

**Before (Local SQLite Only):**
```dart
import 'package:albaqer_gemstone_flutter/database/product_operations.dart';

class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    List<Product> products = await loadProducts(); // Only local SQLite
    setState(() => _products = products);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _products.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(_products[index].name),
        subtitle: Text('\$${_products[index].basePrice}'),
      ),
    );
  }
}
```

**After (With DataManager - Backend + Local):**
```dart
import 'package:albaqer_gemstone_flutter/services/data_manager.dart';

class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final DataManager _dataManager = DataManager();
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    
    try {
      // Smart loading: auto mode with backend sync + local fallback
      List<Product> products = await _dataManager.getProducts();
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshProducts() async {
    // Pull-to-refresh
    bool success = await _dataManager.syncWithBackend();
    if (success) await _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return Center(child: CircularProgressIndicator());

    return RefreshIndicator(
      onRefresh: _refreshProducts,
      child: ListView.builder(
        itemCount: _products.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(_products[index].name),
          subtitle: Text('\$${_products[index].basePrice}'),
        ),
      ),
    );
  }
}
```

**Key Changes:**
- ✅ Import `DataManager` instead of direct database operations
- ✅ Use `getProducts()` for smart data fetching
- ✅ Add `RefreshIndicator` for pull-to-refresh
- ✅ Loading state for better UX
- ✅ Automatic backend sync with local fallback

---

## 📱 Testing the Integration
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _refreshProducts,
      child: Column(
        children: [
          // Backend status indicator
          Container(
            padding: EdgeInsets.all(8),
            color: _isBackendAvailable ? Colors.green.shade100 : Colors.grey.shade200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isBackendAvailable ? Icons.cloud_done : Icons.cloud_off,
                  size: 16,
                  color: _isBackendAvailable ? Colors.green : Colors.grey,
                ),
                SizedBox(width: 8),
                Text(
                  _isBackendAvailable ? 'Online' : 'Offline Mode',
                  style: TextStyle(
                    fontSize: 12,
                    color: _isBackendAvailable ? Colors.green.shade900 : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          
          // Product list
          Expanded(
            child: ListView.builder(
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return ListTile(
                  leading: product.imageUrl != null
                      ? Image.network(
                          product.imageUrl!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.image_not_supported);
                          },
                        )
                      : Icon(Icons.shopping_bag),
                  title: Text(product.name),
                  subtitle: Text('\$${product.basePrice.toStringAsFixed(2)}'),
                  trailing: Text(
                    '${product.quantityInStock} in stock',
                    style: TextStyle(fontSize: 12),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 📱 Testing the Integration

### Test Scenario 1: Backend Online
1. Start backend: `node server.js`
2. Run Flutter app
3. Open product list screen
4. Should show "Online" status
5. Pull to refresh should sync with backend

### Test Scenario 2: Backend Offline
1. Stop backend server
2. Run Flutter app
3. Open product list screen
4. Should show "Offline Mode" status
5. Data loads from local SQLite cache
6. Pull to refresh shows "Could not sync with server"

### Test Scenario 3: Initial Sync
1. Start with backend running
2. Add products via backend API or pgAdmin
3. Open Flutter app
4. New products should sync automatically
5. Products cached locally for offline use

---

## 🔐 Adding Authentication

Your backend has JWT authentication ready. Here's how to integrate it:

### Step 1: Login and Store Token

```dart
// lib/services/auth_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = 'http://10.0.2.2:3000/api';

  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        
        // Store token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }
}
```

### Step 2: Use Token in API Calls

```dart
Future<List<Order>> getMyOrders() async {
  final token = await AuthService().getToken();
  
  final response = await http.get(
    Uri.parse('$baseUrl/orders/my-orders'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );
  
  // Parse orders...
}
```

---

## 📊 Advanced Features to Implement

### 1. Categories & Filtering

Your backend has `categories` and `product_categories` tables for product organization:

```dart
// Get categories
Future<List<Category>> getCategories() async {
  final response = await http.get(
    Uri.parse('$baseUrl/categories'),
  );
  // Parse and return categories
}

// Get products by category
Future<List<Product>> getProductsByCategory(int categoryId) async {
  final response = await http.get(
    Uri.parse('$baseUrl/products?category=$categoryId'),
  );
  // Parse and return filtered products
}
```

### 3. Payments Integration

Use your `payments` table to track transactions:

```dart
Future<bool> processPayment({
  required int orderId,
  required String paymentMethod,
  required double amount,
  required String currency,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/payments'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'order_id': orderId,
      'payment_method': paymentMethod,
      'amount': amount,
      'currency': currency,
    }),
  );
  
  return response.statusCode == 201;
}
```

---

## 🎨 UI Enhancements

### Add Sync Indicator

```dart
// Show last sync time
class SyncIndicator extends StatelessWidget {
  final DataManager dataManager;

  const SyncIndicator({required this.dataManager});

  @override
  Widget build(BuildContext context) {
    final lastSync = dataManager.getLastSyncTime();
    
    if (lastSync == null) {
      return Text('Never synced');
    }
    
    final difference = DateTime.now().difference(lastSync);
    String timeAgo;
    
    if (difference.inMinutes < 1) {
      timeAgo = 'Just now';
    } else if (difference.inMinutes < 60) {
      timeAgo = '${difference.inMinutes}m ago';
    } else {
      timeAgo = '${difference.inHours}h ago';
    }
    
    return Row(
      children: [
        Icon(Icons.sync, size: 14),
        SizedBox(width: 4),
        Text('Synced $timeAgo', style: TextStyle(fontSize: 12)),
      ],
    );
  }
}
```

---

## ✅ Checklist: Integration Steps

- [ ] Backend server is running (`node server.js`)
- [ ] Test API endpoints with curl/browser
- [ ] Add `DataManager` to your Flutter screens
- [ ] Test with backend online (products sync)
- [ ] Test with backend offline (local cache works)
- [ ] Implement pull-to-refresh
- [ ] Add sync status indicator
- [ ] Implement authentication flow
- [ ] Add category filtering
- [ ] Test payment processing
- [ ] Verify all 12 tables are accessible via API

---

## 🔗 Your Project Files

- **Backend API**: [albaqer_gemstone_backend/](../albaqer_gemstone_backend/)
- **Backend Routes**: [routes/](../albaqer_gemstone_backend/routes/)
- **Backend Controllers**: [controllers/](../albaqer_gemstone_backend/controllers/)
- **Flutter Services**: [lib/services/](../albaqer_gemstone_flutter/lib/services/)
- **DataManager**: [lib/services/data_manager.dart](../albaqer_gemstone_flutter/lib/services/data_manager.dart)
- **Local DB Operations**: [lib/database/](../albaqer_gemstone_flutter/lib/database/)

---

## 🚀 You're Ready to Go!

Your backend is fully configured and ready. Just:
1. Start the backend server
2. Use `DataManager` in your Flutter screens
3. Enjoy offline-first functionality with backend sync!
