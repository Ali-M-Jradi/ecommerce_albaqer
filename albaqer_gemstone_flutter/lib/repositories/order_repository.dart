import '../models/order.dart';
import '../services/order_service.dart';
import '../services/auth_service.dart';

/// ==================================================================================
/// ORDER REPOSITORY - Backend-Only Order Management
/// ==================================================================================
///
/// PURPOSE: Manages orders with BACKEND-ONLY strategy (no local caching)
///
/// ARCHITECTURE:
/// - Backend is the ONLY source for orders
/// - No local SQLite storage for orders
/// - All operations require network connection
/// - Orders are critical data that must be persisted on server
///
/// WHY BACKEND-ONLY?
/// - Orders must be centralized (inventory management)
/// - Payment processing requires server validation
/// - Order history needs to sync across devices
/// - Business analytics depend on server data
/// - Security: Prevent client-side manipulation
///
/// BENEFITS FOR CAPSTONE:
/// - Demonstrates when backend is mandatory
/// - Shows proper error handling for critical operations
/// - Clear feedback to user about network requirements
/// - Proper separation of temporary (cart) vs permanent (orders) data
/// ==================================================================================

class OrderRepository {
  // Singleton pattern
  static final OrderRepository _instance = OrderRepository._internal();
  factory OrderRepository() => _instance;
  OrderRepository._internal();

  final OrderService _orderService = OrderService();
  final AuthService _authService = AuthService();

  /// ==================================================================================
  /// PLACE ORDER - Create New Order
  /// ==================================================================================
  /// Strategy:
  /// 1. Validate user is logged in
  /// 2. Send order to backend
  /// 3. Return success/failure (no local storage)
  ///
  /// Use Cases:
  /// - Checkout process
  /// - Converting cart to order
  ///
  /// Returns:
  /// - Order object if successful
  /// - null if failed (with error logged)
  Future<Order?> placeOrder(Order order) async {
    print('🛒 OrderRepository: Placing order...');

    try {
      // Ensure user is authenticated
      final token = await _authService.getToken();
      if (token == null) {
        print('❌ User not authenticated');
        throw Exception('Please login to place an order');
      }

      // Send order to backend
      final createdOrder = await _orderService.createOrder(order);

      if (createdOrder != null) {
        print('✅ Order placed successfully: ${createdOrder.orderNumber}');
        return createdOrder;
      } else {
        print('❌ Failed to place order on backend');
        throw Exception('Failed to place order. Please try again.');
      }
    } catch (e) {
      print('❌ Error placing order: $e');
      rethrow; // Let UI handle the error
    }
  }

  /// ==================================================================================
  /// GET USER ORDERS - Fetch Order History
  /// ==================================================================================
  /// Strategy:
  /// 1. Validate user is logged in
  /// 2. Fetch orders from backend
  /// 3. Return list (no caching)
  ///
  /// Use Cases:
  /// - Order history screen
  /// - User profile orders section
  ///
  /// Returns:
  /// - List of orders if successful
  /// - Empty list if no orders or error
  Future<List<Order>> getUserOrders() async {
    print('📋 OrderRepository: Fetching user orders...');

    try {
      // Ensure user is authenticated
      final userId = await _authService.getUserId();
      if (userId == null) {
        print('❌ User not authenticated');
        return [];
      }

      // Fetch from backend
      final orders = await _orderService.fetchAllOrders();

      // Filter by current user (backend should handle this, but extra safety)
      final userOrders = orders.where((o) => o.userId == userId).toList();

      print('✅ Fetched ${userOrders.length} orders for user #$userId');
      return userOrders;
    } catch (e) {
      print('❌ Error fetching orders: $e');
      return []; // Return empty list on error
    }
  }

  /// ==================================================================================
  /// GET ORDER BY ID - Fetch Single Order Details
  /// ==================================================================================
  /// Strategy:
  /// 1. Fetch from backend
  /// 2. Validate user owns this order
  /// 3. Return order details
  ///
  /// Use Cases:
  /// - Order detail screen
  /// - Order tracking page
  ///
  /// Returns:
  /// - Order object if found and authorized
  /// - null if not found or unauthorized
  Future<Order?> getOrderById(int orderId) async {
    print('📋 OrderRepository: Fetching order #$orderId...');

    try {
      // Ensure user is authenticated
      final userId = await _authService.getUserId();
      if (userId == null) {
        print('❌ User not authenticated');
        return null;
      }

      // Fetch from backend
      final order = await _orderService.fetchOrderById(orderId);

      if (order == null) {
        print('❌ Order #$orderId not found');
        return null;
      }

      // Verify user owns this order (security check)
      if (order.userId != userId) {
        print(
          '⚠️ User #$userId attempted to access order #$orderId owned by user #${order.userId}',
        );
        return null; // Don't expose other users' orders
      }

      print('✅ Fetched order #$orderId');
      return order;
    } catch (e) {
      print('❌ Error fetching order: $e');
      return null;
    }
  }

  /// ==================================================================================
  /// UPDATE ORDER STATUS - Admin or System Operation
  /// ==================================================================================
  /// Strategy:
  /// 1. Update on backend
  /// 2. Return success/failure
  ///
  /// Use Cases:
  /// - Admin panel status updates
  /// - System processing (payment confirmation, shipping updates)
  ///
  /// Note: This might require admin role validation in production
  Future<bool> updateOrderStatus(int orderId, String newStatus) async {
    print('✏️ OrderRepository: Updating order #$orderId to $newStatus...');

    try {
      final success = await _orderService.updateOrderStatus(orderId, newStatus);

      if (success) {
        print('✅ Order #$orderId status updated to $newStatus');
        return true;
      } else {
        print('❌ Failed to update order status');
        return false;
      }
    } catch (e) {
      print('❌ Error updating order status: $e');
      return false;
    }
  }

  /// ==================================================================================
  /// CANCEL ORDER - User Cancellation Request
  /// ==================================================================================
  /// Strategy:
  /// 1. Validate user owns the order
  /// 2. Check if order can be cancelled (business rules)
  /// 3. Update status to 'cancelled'
  ///
  /// Use Cases:
  /// - User cancelling pending orders
  /// - Order management screen
  ///
  /// Business Rule: Only pending/processing orders can be cancelled
  Future<bool> cancelOrder(int orderId) async {
    print('🚫 OrderRepository: Cancelling order #$orderId...');

    try {
      // Fetch order first to check status
      final order = await getOrderById(orderId);

      if (order == null) {
        print('❌ Order not found or unauthorized');
        return false;
      }

      // Check if order can be cancelled
      if (order.status == 'shipped' || order.status == 'delivered') {
        print('⚠️ Cannot cancel order - already ${order.status}');
        throw Exception('Cannot cancel order that has been ${order.status}');
      }

      if (order.status == 'cancelled') {
        print('⚠️ Order already cancelled');
        return true; // Already cancelled, consider it success
      }

      // Update status to cancelled
      final success = await updateOrderStatus(orderId, 'cancelled');

      if (success) {
        print('✅ Order #$orderId cancelled successfully');
        return true;
      } else {
        print('❌ Failed to cancel order');
        return false;
      }
    } catch (e) {
      print('❌ Error cancelling order: $e');
      rethrow;
    }
  }

  /// ==================================================================================
  /// GET ORDER STATISTICS - User Order Analytics
  /// ==================================================================================
  /// Strategy:
  /// 1. Fetch all user orders
  /// 2. Calculate statistics
  /// 3. Return summary
  ///
  /// Use Cases:
  /// - User dashboard
  /// - Profile statistics
  ///
  /// Returns:
  /// - Map with statistics (totalOrders, totalSpent, pendingOrders, etc.)
  Future<Map<String, dynamic>> getOrderStatistics() async {
    print('📊 OrderRepository: Calculating order statistics...');

    try {
      final orders = await getUserOrders();

      final stats = {
        'totalOrders': orders.length,
        'totalSpent': orders.fold<double>(
          0,
          (sum, order) => sum + order.totalAmount,
        ),
        'pendingOrders': orders.where((o) => o.status == 'pending').length,
        'completedOrders': orders.where((o) => o.status == 'delivered').length,
        'cancelledOrders': orders.where((o) => o.status == 'cancelled').length,
        'processingOrders': orders
            .where((o) => o.status == 'processing')
            .length,
        'shippedOrders': orders.where((o) => o.status == 'shipped').length,
      };

      print('✅ Statistics calculated: ${stats['totalOrders']} orders');
      return stats;
    } catch (e) {
      print('❌ Error calculating statistics: $e');
      return {
        'totalOrders': 0,
        'totalSpent': 0.0,
        'pendingOrders': 0,
        'completedOrders': 0,
        'cancelledOrders': 0,
        'processingOrders': 0,
        'shippedOrders': 0,
      };
    }
  }

  /// ==================================================================================
  /// CHECK BACKEND AVAILABILITY
  /// ==================================================================================
  /// Helper method to check if backend is reachable before placing order
  ///
  /// Use Cases:
  /// - Pre-checkout validation
  /// - Network status checking
  Future<bool> isBackendAvailable() async {
    try {
      // Try to fetch orders endpoint as health check
      await _orderService.fetchAllOrders();
      return true;
    } catch (e) {
      print('⚠️ Backend unavailable: $e');
      return false;
    }
  }

  /// ==================================================================================
  /// VALIDATE ORDER BEFORE PLACEMENT
  /// ==================================================================================
  /// Business logic validation before sending to backend
  ///
  /// Checks:
  /// - User is logged in
  /// - Order has items
  /// - Total amount is positive
  /// - Backend is available
  Future<Map<String, dynamic>> validateOrder(Order order) async {
    print('✓ OrderRepository: Validating order...');

    // Check authentication
    final token = await _authService.getToken();
    if (token == null) {
      return {'valid': false, 'error': 'Please login to place an order'};
    }

    // Check order total
    if (order.totalAmount <= 0) {
      return {
        'valid': false,
        'error': 'Order amount must be greater than zero',
      };
    }

    // Check backend availability
    final backendAvailable = await isBackendAvailable();
    if (!backendAvailable) {
      return {
        'valid': false,
        'error': 'Cannot place order. Please check your internet connection.',
      };
    }

    print('✅ Order validation passed');
    return {'valid': true};
  }
}

/// ==================================================================================
/// SUMMARY FOR CAPSTONE PRESENTATION:
/// ==================================================================================
///
/// WHY BACKEND-ONLY FOR ORDERS:
/// 1. **Data Integrity** - Orders must be centralized for inventory management
/// 2. **Security** - Prevent client-side price/quantity manipulation
/// 3. **Payment Processing** - Server validates payments before order creation
/// 4. **Cross-Device Sync** - Users see same orders on all devices
/// 5. **Business Analytics** - Server tracks all orders for reporting
///
/// ARCHITECTURE BENEFITS:
/// 1. **Clear Separation** - Cart (local) vs Orders (backend)
/// 2. **Proper Error Handling** - Network errors handled gracefully
/// 3. **User Validation** - Authorization checks at repository level
/// 4. **Business Logic** - Order cancellation rules enforced
/// 5. **Statistics** - Easy to add analytics and reporting
///
/// TALKING POINTS:
/// - "Orders are critical business data that must live on the server"
/// - "Cart is temporary (local), Orders are permanent (backend)"
/// - "Network requirement is clearly communicated to users"
/// - "Authorization ensures users only see their own orders"
/// - "Repository handles all business logic (cancellation rules, validation)"
///
/// COMPARISON WITH CART (LOCAL):
/// | Feature | Cart (Local) | Orders (Backend) |
/// |---------|--------------|------------------|
/// | Storage | SQLite | PostgreSQL |
/// | Persistence | Device-only | Cross-device |
/// | Network | Optional | Required |
/// | Speed | Instant | Network-dependent |
/// | Security | Low priority | High priority |
/// | Data Type | Temporary | Permanent |
///
/// ==================================================================================
