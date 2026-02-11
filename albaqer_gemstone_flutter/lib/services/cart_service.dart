import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import './auth_service.dart';

/// ==================================================================================
/// CART SERVICE - Backend-Based Per-User Cart Management
/// ==================================================================================
///
/// PURPOSE: Manages shopping cart with backend storage, tied to user accounts
///
/// KEY FEATURES:
/// 1. User-Specific Carts - Each user has their own cart stored on backend
/// 2. Cross-Device Sync - Cart accessible from any device
/// 3. Secure - Cart data tied to authenticated user
/// 4. State Management - Real-time UI updates via ChangeNotifier
/// 5. Auto-Sync - All operations immediately synced to backend
/// ==================================================================================

class CartService extends ChangeNotifier {
  // Singleton pattern
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final AuthService _authService = AuthService();

  // State
  List<Map<String, dynamic>> _cartItems = [];
  bool _isLoading = false;
  int? _cartId; // ignore: unused_field

  // Getters
  List<Map<String, dynamic>> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  int get itemCount => _cartItems.length;

  // ========================================
  // LOAD CART FROM BACKEND
  // ========================================
  Future<void> loadCart() async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _authService.getToken();
      if (token == null) {
        print('⚠️ No auth token - cart not loaded');
        _cartItems = [];
        _isLoading = false;
        notifyListeners();
        return;
      }

      final baseUrl = ApiConfig.baseUrl;
      final response = await http.get(
        Uri.parse('$baseUrl/cart'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _cartId = data['data']['cart_id'];
        _cartItems = List<Map<String, dynamic>>.from(data['data']['items']);
        print('✅ Cart loaded: ${_cartItems.length} items');
      } else {
        print('⚠️ Failed to load cart: ${response.statusCode}');
        _cartItems = [];
      }
    } catch (e) {
      print('❌ Error loading cart: $e');
      _cartItems = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========================================
  // ADD TO CART
  // ========================================
  Future<bool> addToCart({required int productId, int quantity = 1}) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        print('⚠️ Must be logged in to add to cart');
        return false;
      }

      final baseUrl = ApiConfig.baseUrl;
      final response = await http.post(
        Uri.parse('$baseUrl/cart/items'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'product_id': productId, 'quantity': quantity}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('✅ Added to cart: Product #$productId');
        await loadCart(); // Reload cart to get updated data
        return true;
      } else {
        final error = jsonDecode(response.body);
        print('⚠️ Failed to add to cart: ${error['message']}');
        return false;
      }
    } catch (e) {
      print('❌ Error adding to cart: $e');
      return false;
    }
  }

  // ========================================
  // UPDATE QUANTITY
  // ========================================
  Future<bool> updateQuantity({
    required int cartItemId,
    required int newQuantity,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return false;

      if (newQuantity < 1) {
        print('⚠️ Quantity must be at least 1');
        return false;
      }

      final baseUrl = ApiConfig.baseUrl;
      final response = await http.put(
        Uri.parse('$baseUrl/cart/items/$cartItemId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'quantity': newQuantity}),
      );

      if (response.statusCode == 200) {
        print('✅ Quantity updated');
        await loadCart();
        return true;
      } else {
        final error = jsonDecode(response.body);
        print('⚠️ Failed to update: ${error['message']}');
        return false;
      }
    } catch (e) {
      print('❌ Error updating quantity: $e');
      return false;
    }
  }

  // ========================================
  // REMOVE ITEM
  // ========================================
  Future<bool> removeItem(int cartItemId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return false;

      final baseUrl = ApiConfig.baseUrl;
      final response = await http.delete(
        Uri.parse('$baseUrl/cart/items/$cartItemId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        print('✅ Removed from cart');
        await loadCart();
        return true;
      } else {
        print('⚠️ Failed to remove item');
        return false;
      }
    } catch (e) {
      print('❌ Error removing item: $e');
      return false;
    }
  }

  // ========================================
  // CLEAR CART
  // ========================================
  Future<void> clearAllItems() async {
    try {
      final token = await _authService.getToken();
      if (token == null) return;

      final baseUrl = ApiConfig.baseUrl;
      final response = await http.delete(
        Uri.parse('$baseUrl/cart'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        print('✅ Cart cleared');
        _cartItems = [];
        notifyListeners();
      }
    } catch (e) {
      print('❌ Error clearing cart: $e');
    }
  }

  // Clear local cart state without API call (for logout)
  void clearLocalCart() {
    _cartItems = [];
    _cartId = null;
    notifyListeners();
    print('✅ Local cart state cleared');
  }

  // ========================================
  // CALCULATIONS
  // ========================================
  double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  double get subtotal {
    double total = 0.0;
    for (var item in _cartItems) {
      final price = _toDouble(item['price_at_add']);
      final quantity = _toInt(item['quantity']);
      total += price * quantity;
    }
    return total;
  }

  double get tax => subtotal * 0.10;

  double get shippingCost => subtotal >= 100 ? 0.0 : 5.0;

  double get total => subtotal + tax + shippingCost;

  int get totalItemsCount {
    int count = 0;
    for (var item in _cartItems) {
      count += _toInt(item['quantity']);
    }
    return count;
  }

  // ========================================
  // HELPERS
  // ========================================
  bool isInCart(int productId) {
    return _cartItems.any((item) => item['product_id'] == productId);
  }

  int getProductQuantity(int productId) {
    try {
      final item = _cartItems.firstWhere(
        (item) => item['product_id'] == productId,
      );
      return _toInt(item['quantity']);
    } catch (e) {
      return 0;
    }
  }

  int? getCartItemId(int productId) {
    try {
      final item = _cartItems.firstWhere(
        (item) => item['product_id'] == productId,
      );
      return item['id'] as int?;
    } catch (e) {
      return null;
    }
  }

  Future<bool> incrementQuantity(int cartItemId) async {
    final item = _cartItems.firstWhere((item) => item['id'] == cartItemId);
    final currentQuantity = _toInt(item['quantity']);
    return await updateQuantity(
      cartItemId: cartItemId,
      newQuantity: currentQuantity + 1,
    );
  }

  Future<bool> decrementQuantity(int cartItemId) async {
    final item = _cartItems.firstWhere((item) => item['id'] == cartItemId);
    final currentQuantity = _toInt(item['quantity']);

    if (currentQuantity <= 1) {
      return await removeItem(cartItemId);
    } else {
      return await updateQuantity(
        cartItemId: cartItemId,
        newQuantity: currentQuantity - 1,
      );
    }
  }
}
