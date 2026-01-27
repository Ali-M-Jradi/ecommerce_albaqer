import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../database/cart_operations.dart' as cart_db;
import '../database/product_operations.dart';

/// ==================================================================================
/// CART SERVICE - Central Cart Management System
/// ==================================================================================
///
/// PURPOSE: This service manages all shopping cart operations in the application.
/// It acts as a bridge between the UI and the database, handling cart state management.
///
/// KEY FEATURES FOR PRESENTATION:
/// 1. State Management - Uses ChangeNotifier for real-time UI updates
/// 2. Singleton Pattern - Ensures one cart instance across the entire app
/// 3. Cart Persistence - All data saved to local database
/// 4. Cart Analytics - Tracks total items, prices, and calculations
/// 5. Stock Validation - Prevents adding more items than available
/// 6. Product Integration - Links cart items with full product details
/// ==================================================================================

class CartService extends ChangeNotifier {
  // ========================================
  // FEATURE 1: SINGLETON PATTERN
  // ========================================
  // Explanation: Ensures only ONE cart exists throughout the app
  // Benefit: Consistent cart state across all screens
  // Implementation: Private constructor + factory pattern

  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final uuid = Uuid();

  // ========================================
  // FEATURE 2: STATE MANAGEMENT
  // ========================================
  // Explanation: Stores current cart state in memory for fast access
  // These lists update automatically and trigger UI rebuilds

  List<CartItem> _cartItems = [];
  List<Product> _cartProducts = [];
  int _currentCartId = 1; // Each user has one cart

  // Getters - Provide read-only access to cart data
  List<CartItem> get cartItems => _cartItems;
  List<Product> get cartProducts => _cartProducts;
  int get itemCount => _cartItems.length;

  // ========================================
  // FEATURE 3: CART INITIALIZATION
  // ========================================
  // Explanation: Loads saved cart items from database when app starts
  // Called when: App launches, user logs in, or cart screen opens
  // Benefit: Cart persists between app sessions

  Future<void> loadCart() async {
    try {
      // Step 1: Fetch all cart items for current user's cart
      _cartItems = await cart_db.loadCartItems(_currentCartId);

      // Step 2: Load corresponding product details for each cart item
      _cartProducts = [];
      for (var cartItem in _cartItems) {
        Product? product = await getProductById(cartItem.productId);
        if (product != null) {
          _cartProducts.add(product);
        }
      }

      // Step 3: Notify all listeners (UI widgets) to rebuild
      notifyListeners();

      print('✅ Cart loaded: ${_cartItems.length} items');
    } catch (e) {
      print('❌ Error loading cart: $e');
    }
  }

  // ========================================
  // FEATURE 4: ADD TO CART WITH VALIDATION
  // ========================================
  // Explanation: Adds products to cart with smart duplicate handling
  // Logic:
  //   - If item already in cart → Update quantity
  //   - If new item → Add new entry
  //   - Validates stock availability before adding

  Future<bool> addToCart({required Product product, int quantity = 1}) async {
    try {
      // VALIDATION 1: Check if product is available
      if (!product.isAvailable) {
        print('⚠️ Product is not available');
        return false;
      }

      // VALIDATION 2: Check stock availability
      if (product.quantityInStock < quantity) {
        print('⚠️ Insufficient stock. Available: ${product.quantityInStock}');
        return false;
      }

      // SMART DUPLICATE HANDLING
      // Check if product already exists in cart
      int existingIndex = _cartItems.indexWhere(
        (item) => item.productId == product.id,
      );

      if (existingIndex != -1) {
        // Product exists - UPDATE quantity
        CartItem existingItem = _cartItems[existingIndex];
        int newQuantity = existingItem.quantity + quantity;

        // Validate new quantity doesn't exceed stock
        if (newQuantity > product.quantityInStock) {
          print('⚠️ Cannot add more. Stock limit reached.');
          return false;
        }

        // Update cart item in database
        CartItem updatedItem = CartItem(
          id: existingItem.id,
          cartId: existingItem.cartId,
          productId: existingItem.productId,
          quantity: newQuantity,
          priceAtAdd: existingItem.priceAtAdd,
        );

        cart_db.updateCartItem(updatedItem);
        _cartItems[existingIndex] = updatedItem;

        print('✅ Updated quantity: ${product.name} (x$newQuantity)');
      } else {
        // Product doesn't exist - ADD new entry
        // Generate unique tracking ID using UUID
        String uniqueTrackingId = uuid.v4();

        CartItem newItem = CartItem(
          cartId: _currentCartId,
          productId: product.id!,
          quantity: quantity,
          priceAtAdd: product.basePrice,
          trackingId: uniqueTrackingId,
        );

        // Add to database and get the inserted ID
        final insertedId = await cart_db.addToCart(newItem);

        // Create item with proper ID and UUID
        newItem = CartItem(
          id: insertedId,
          cartId: _currentCartId,
          productId: product.id!,
          quantity: quantity,
          priceAtAdd: product.basePrice,
          trackingId: uniqueTrackingId,
        );

        // Add to local state (UI will show immediately)
        _cartItems.add(newItem);
        _cartProducts.add(product);

        print(
          '✅ Added to cart: ${product.name} (x$quantity)\n   DB ID: $insertedId | UUID: $uniqueTrackingId',
        );
      }

      // Notify UI to update (shopping cart icon badge, cart screen, etc.)
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Error adding to cart: $e');
      return false;
    }
  }

  // ========================================
  // FEATURE 5: UPDATE QUANTITY
  // ========================================
  // Explanation: Changes quantity of existing cart item
  // Use cases: User increases/decreases quantity in cart screen
  // Validation: Ensures quantity is within valid range (1 to stock limit)

  Future<bool> updateQuantity({
    required int cartItemId,
    required int newQuantity,
  }) async {
    try {
      // Find the cart item
      int index = _cartItems.indexWhere((item) => item.id == cartItemId);
      if (index == -1) {
        print('⚠️ Cart item not found');
        return false;
      }

      CartItem cartItem = _cartItems[index];
      Product product = _cartProducts[index];

      // VALIDATION 1: Quantity must be at least 1
      if (newQuantity < 1) {
        print('⚠️ Quantity must be at least 1');
        return false;
      }

      // VALIDATION 2: Check stock availability
      if (newQuantity > product.quantityInStock) {
        print('⚠️ Only ${product.quantityInStock} available');
        return false;
      }

      // Update in database
      CartItem updatedItem = CartItem(
        id: cartItem.id,
        cartId: cartItem.cartId,
        productId: cartItem.productId,
        quantity: newQuantity,
        priceAtAdd: cartItem.priceAtAdd,
      );

      cart_db.updateCartItem(updatedItem);
      _cartItems[index] = updatedItem;

      print('✅ Quantity updated: ${product.name} (x$newQuantity)');
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Error updating quantity: $e');
      return false;
    }
  }

  // ========================================
  // FEATURE 6: REMOVE FROM CART
  // ========================================
  // Explanation: Deletes item from cart
  // Updates both database and UI immediately

  Future<bool> removeItem(int cartItemId) async {
    try {
      // Find item index
      int index = _cartItems.indexWhere((item) => item.id == cartItemId);
      if (index == -1) {
        print('⚠️ Item not found in cart');
        return false;
      }

      // Remove from database
      cart_db.removeFromCart(cartItemId);

      // Remove from local state
      String productName = _cartProducts[index].name;
      _cartItems.removeAt(index);
      _cartProducts.removeAt(index);

      print('✅ Removed from cart: $productName');
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Error removing item: $e');
      return false;
    }
  }

  // ========================================
  // FEATURE 7: CLEAR ENTIRE CART
  // ========================================
  // Explanation: Removes all items from cart
  // Use cases: After order completion, manual clear by user

  Future<void> clearAllItems() async {
    try {
      // Clear from database
      cart_db.clearCart(_currentCartId);

      // Clear local state
      _cartItems.clear();
      _cartProducts.clear();

      print('✅ Cart cleared');
      notifyListeners();
    } catch (e) {
      print('❌ Error clearing cart: $e');
    }
  }

  // ========================================
  // FEATURE 8: CART CALCULATIONS & ANALYTICS
  // ========================================
  // Explanation: Real-time price calculations for cart summary
  // These getters automatically recalculate when cart changes

  /// Calculate subtotal (sum of all items)
  /// Formula: Σ(price × quantity) for each item
  double get subtotal {
    double total = 0.0;
    for (int i = 0; i < _cartItems.length; i++) {
      total += _cartItems[i].priceAtAdd * _cartItems[i].quantity;
    }
    return total;
  }

  /// Calculate tax (example: 10% of subtotal)
  /// In production: Tax rate may vary by region
  double get tax {
    return subtotal * 0.10; // 10% tax
  }

  /// Calculate shipping cost
  /// Logic: Free shipping over $100, otherwise $5
  double get shippingCost {
    if (subtotal >= 100) {
      return 0.0; // Free shipping
    }
    return 5.0;
  }

  /// Calculate final total
  /// Formula: Subtotal + Tax + Shipping
  double get total {
    return subtotal + tax + shippingCost;
  }

  /// Get total number of individual items (not unique products)
  /// Example: 2x Product A + 3x Product B = 5 total items
  int get totalItemsCount {
    int count = 0;
    for (var item in _cartItems) {
      count += item.quantity;
    }
    return count;
  }

  // ========================================
  // FEATURE 9: CART ITEM LOOKUP
  // ========================================
  // Explanation: Helper methods to find specific cart items
  // Used for checking if product is in cart, getting quantities, etc.

  /// Check if a product is already in the cart
  bool isInCart(int productId) {
    return _cartItems.any((item) => item.productId == productId);
  }

  /// Get quantity of specific product in cart
  /// Returns 0 if product not in cart
  int getProductQuantity(int productId) {
    try {
      CartItem item = _cartItems.firstWhere(
        (item) => item.productId == productId,
      );
      return item.quantity;
    } catch (e) {
      return 0; // Product not in cart
    }
  }

  /// Get cart item by product ID
  /// Used when you need the full CartItem object
  CartItem? getCartItemByProductId(int productId) {
    try {
      return _cartItems.firstWhere((item) => item.productId == productId);
    } catch (e) {
      return null;
    }
  }

  // ========================================
  // FEATURE 10: INCREMENT/DECREMENT HELPERS
  // ========================================
  // Explanation: Convenience methods for +1/-1 operations
  // Commonly used in cart UI with +/- buttons

  /// Increase quantity by 1
  Future<bool> incrementQuantity(int cartItemId) async {
    int index = _cartItems.indexWhere((item) => item.id == cartItemId);
    if (index == -1) return false;

    int currentQuantity = _cartItems[index].quantity;
    return await updateQuantity(
      cartItemId: cartItemId,
      newQuantity: currentQuantity + 1,
    );
  }

  /// Decrease quantity by 1
  /// If quantity becomes 0, removes item from cart
  Future<bool> decrementQuantity(int cartItemId) async {
    int index = _cartItems.indexWhere((item) => item.id == cartItemId);
    if (index == -1) return false;

    int currentQuantity = _cartItems[index].quantity;

    if (currentQuantity <= 1) {
      // Remove item if quantity would be 0
      return await removeItem(cartItemId);
    } else {
      return await updateQuantity(
        cartItemId: cartItemId,
        newQuantity: currentQuantity - 1,
      );
    }
  }
}

/// ==================================================================================
/// PRESENTATION TALKING POINTS:
/// ==================================================================================
///
/// 1. ARCHITECTURE:
///    - Service layer pattern separates business logic from UI
///    - Makes code maintainable, testable, and reusable
///
/// 2. STATE MANAGEMENT:
///    - ChangeNotifier pattern for reactive UI updates
///    - When cart changes, all listening widgets rebuild automatically
///
/// 3. DATA PERSISTENCE:
///    - All cart operations saved to SQLite database
///    - Cart survives app restarts (shopping session preserved)
///
/// 4. USER EXPERIENCE FEATURES:
///    - Real-time calculations (subtotal, tax, total)
///    - Stock validation prevents over-ordering
///    - Smart duplicate handling (update vs add new)
///    - Free shipping threshold incentive
///
/// 5. PERFORMANCE:
///    - Singleton pattern prevents multiple instances
///    - In-memory caching reduces database queries
///    - Efficient list operations with indexWhere()
///
/// 6. SCALABILITY:
///    - Easy to add discount codes, coupons
///    - Tax rate can be made dynamic based on location
///    - Shipping cost can integrate with real shipping APIs
///
/// ==================================================================================
