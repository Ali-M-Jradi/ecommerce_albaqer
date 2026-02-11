import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:albaqer_gemstone_flutter/models/order.dart';
import 'package:albaqer_gemstone_flutter/models/order_item.dart';
import '../config/api_config.dart';

/// Service class for handling all order-related API calls to the backend
class OrderService {
  /// Get authentication token from storage
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Get current user ID from storage
  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  /// Generate a unique order number
  String _generateOrderNumber() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'ORD-$timestamp-$random';
  }

  /// Get current user orders
  Future<List<Order>> getMyOrders() async {
    try {
      final token = await _getToken();
      if (token == null) {
        print('No auth token found');
        return [];
      }

      final baseUrl = ApiConfig.baseUrl;

      final response = await http.get(
        Uri.parse('$baseUrl/orders/my-orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        List<dynamic> data = jsonResponse['data'];
        return data.map((json) {
          return Order(
            id: json['id'],
            userId: json['user_id'],
            orderNumber: json['order_number'],
            totalAmount: double.parse(json['total_amount'].toString()),
            taxAmount: json['tax_amount'] != null
                ? double.parse(json['tax_amount'].toString())
                : 0.0,
            shippingCost: json['shipping_cost'] != null
                ? double.parse(json['shipping_cost'].toString())
                : 0.0,
            discountAmount: json['discount_amount'] != null
                ? double.parse(json['discount_amount'].toString())
                : 0.0,
            status: json['status'] ?? 'pending',
            shippingAddressId: json['shipping_address_id'],
            billingAddressId: json['billing_address_id'],
            trackingNumber: json['tracking_number'],
            notes: json['notes'],
            createdAt: json['created_at'] != null
                ? DateTime.parse(json['created_at'])
                : null,
            updatedAt: json['updated_at'] != null
                ? DateTime.parse(json['updated_at'])
                : null,
          );
        }).toList();
      } else {
        print('Failed to fetch my orders: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching my orders: $e');
      return [];
    }
  }

  // ========== CREATE ==========
  /// Create a new order on the backend with order items
  /// Takes cart totals and items, creates order and updates inventory
  Future<Order?> createOrder({
    required double subtotal,
    required double taxAmount,
    required double shippingCost,
    required List<OrderItem> orderItems,
    int? shippingAddressId,
    String? notes,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        print('❌ No auth token - user must be logged in to place order');
        return null;
      }

      final userId = await _getUserId();
      if (userId == null) {
        print('❌ No user ID found');
        return null;
      }

      final orderNumber = _generateOrderNumber();
      final totalAmount = subtotal + taxAmount + shippingCost;

      final orderData = {
        'user_id': userId,
        'order_number': orderNumber,
        'total_amount': totalAmount,
        'tax_amount': taxAmount,
        'shipping_cost': shippingCost,
        'discount_amount': 0.0,
        'shipping_address_id': shippingAddressId,
        'notes': notes,
        'order_items': orderItems.map((item) => item.toJson()).toList(),
      };

      print('🛒 Creating order: $orderNumber');
      print('📊 Total: \$${totalAmount.toStringAsFixed(2)}');
      print('📦 Items: ${orderItems.length}');
      final baseUrl = ApiConfig.baseUrl;
      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(orderData),
      );

      if (response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        final data = jsonResponse['data'];
        print('✅ Order created successfully: ${data['order_number']}');

        return Order(
          id: data['id'],
          userId: data['user_id'],
          orderNumber: data['order_number'],
          totalAmount: double.parse(data['total_amount'].toString()),
          taxAmount: data['tax_amount'] != null
              ? double.parse(data['tax_amount'].toString())
              : 0.0,
          shippingCost: data['shipping_cost'] != null
              ? double.parse(data['shipping_cost'].toString())
              : 0.0,
          discountAmount: data['discount_amount'] != null
              ? double.parse(data['discount_amount'].toString())
              : 0.0,
          status: data['status'] ?? 'pending',
          shippingAddressId: data['shipping_address_id'],
          billingAddressId: data['billing_address_id'],
          trackingNumber: data['tracking_number'],
          notes: data['notes'],
          createdAt: data['created_at'] != null
              ? DateTime.parse(data['created_at'])
              : null,
          updatedAt: data['updated_at'] != null
              ? DateTime.parse(data['updated_at'])
              : null,
        );
      } else if (response.statusCode == 400) {
        // Stock validation error - parse detailed error
        final jsonResponse = jsonDecode(response.body);
        final stockIssues = jsonResponse['stock_issues'] as List<dynamic>?;

        if (stockIssues != null && stockIssues.isNotEmpty) {
          print('❌ Stock validation failed:');
          for (var issue in stockIssues) {
            print(
              '   - ${issue['product_name']}: requested ${issue['requested']}, available ${issue['available']}',
            );
          }
        }

        print('Response: ${response.body}');
        return null;
      } else {
        print('❌ Failed to create order: ${response.statusCode}');
        print('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error creating order: $e');
      return null;
    }
  }

  // ========== READ (ALL) ==========
  /// Fetch all orders from the backend
  Future<List<Order>> fetchAllOrders() async {
    try {
      final baseUrl = ApiConfig.baseUrl;
      final response = await http.get(Uri.parse('$baseUrl/orders'));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        List<dynamic> data = jsonResponse['data'];
        return data.map((json) {
          return Order(
            id: json['id'],
            userId: json['user_id'],
            orderNumber: json['order_number'],
            totalAmount: double.parse(json['total_amount'].toString()),
            taxAmount: json['tax_amount'] != null
                ? double.parse(json['tax_amount'].toString())
                : 0.0,
            shippingCost: json['shipping_cost'] != null
                ? double.parse(json['shipping_cost'].toString())
                : 0.0,
            discountAmount: json['discount_amount'] != null
                ? double.parse(json['discount_amount'].toString())
                : 0.0,
            status: json['status'] ?? 'pending',
            shippingAddressId: json['shipping_address_id'],
            billingAddressId: json['billing_address_id'],
            trackingNumber: json['tracking_number'],
            notes: json['notes'],
            createdAt: json['created_at'] != null
                ? DateTime.parse(json['created_at'])
                : null,
            updatedAt: json['updated_at'] != null
                ? DateTime.parse(json['updated_at'])
                : null,
          );
        }).toList();
      } else {
        print('Failed to fetch orders: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching orders: $e');
      return [];
    }
  }

  // ========== READ (BY ID) ==========
  /// Fetch a single order by ID from the backend
  Future<Order?> fetchOrderById(int id) async {
    try {
      final baseUrl = ApiConfig.baseUrl;
      final response = await http.get(Uri.parse('$baseUrl/orders/$id'));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Order(
          id: json['id'],
          userId: json['user_id'],
          orderNumber: json['order_number'],
          totalAmount: double.parse(json['total_amount'].toString()),
          taxAmount: json['tax_amount'] != null
              ? double.parse(json['tax_amount'].toString())
              : 0.0,
          shippingCost: json['shipping_cost'] != null
              ? double.parse(json['shipping_cost'].toString())
              : 0.0,
          discountAmount: json['discount_amount'] != null
              ? double.parse(json['discount_amount'].toString())
              : 0.0,
          status: json['status'] ?? 'pending',
          shippingAddressId: json['shipping_address_id'],
          billingAddressId: json['billing_address_id'],
          trackingNumber: json['tracking_number'],
          notes: json['notes'],
          createdAt: json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
          updatedAt: json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
        );
      } else if (response.statusCode == 404) {
        print('Order not found');
        return null;
      } else {
        print('Failed to fetch order: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching order: $e');
      return null;
    }
  }

  // ========== UPDATE ==========
  /// Update an existing order on the backend
  Future<Order?> updateOrder(Order order) async {
    try {
      final baseUrl = ApiConfig.baseUrl;
      final response = await http.put(
        Uri.parse('$baseUrl/orders/${order.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(order.orderMap),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Order(
          id: json['id'],
          userId: json['user_id'],
          orderNumber: json['order_number'],
          totalAmount: double.parse(json['total_amount'].toString()),
          taxAmount: json['tax_amount'] != null
              ? double.parse(json['tax_amount'].toString())
              : 0.0,
          shippingCost: json['shipping_cost'] != null
              ? double.parse(json['shipping_cost'].toString())
              : 0.0,
          discountAmount: json['discount_amount'] != null
              ? double.parse(json['discount_amount'].toString())
              : 0.0,
          status: json['status'] ?? 'pending',
          shippingAddressId: json['shipping_address_id'],
          billingAddressId: json['billing_address_id'],
          trackingNumber: json['tracking_number'],
          notes: json['notes'],
          createdAt: json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
          updatedAt: json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
        );
      } else if (response.statusCode == 404) {
        print('Order not found');
        return null;
      } else {
        print('Failed to update order: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error updating order: $e');
      return null;
    }
  }

  // ========== UPDATE STATUS ==========
  /// Update order status only
  Future<bool> updateOrderStatus(int orderId, String status) async {
    try {
      final baseUrl = ApiConfig.baseUrl;
      final response = await http.put(
        Uri.parse('$baseUrl/orders/$orderId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': status}),
      );

      if (response.statusCode == 200) {
        print('Order status updated successfully');
        return true;
      } else {
        print('Failed to update order status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error updating order status: $e');
      return false;
    }
  }

  // ========== DELETE ==========
  /// Delete an order from the backend
  Future<bool> deleteOrder(int orderId) async {
    try {
      final baseUrl = ApiConfig.baseUrl;
      final token = await _getToken();
      if (token == null) {
        print('No auth token found');
        return false;
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/orders/$orderId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('Order deleted successfully');
        return true;
      } else if (response.statusCode == 404) {
        print('Order not found');
        return false;
      } else {
        print('Failed to delete order: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error deleting order: $e');
      return false;
    }
  }

  // ========== ADMIN FUNCTIONS ==========
  /// Fetch ALL orders (Admin only)
  Future<List<Order>> getAllOrdersAdmin() async {
    try {
      final token = await _getToken();
      if (token == null) {
        print('❌ No auth token found');
        return [];
      }

      final baseUrl = ApiConfig.baseUrl;
      final response = await http.get(
        Uri.parse('$baseUrl/orders/all'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        List<dynamic> data = jsonResponse['data'];
        return data.map((json) {
          return Order(
            id: json['id'],
            userId: json['user_id'],
            orderNumber: json['order_number'],
            totalAmount: double.parse(json['total_amount'].toString()),
            taxAmount: json['tax_amount'] != null
                ? double.parse(json['tax_amount'].toString())
                : 0.0,
            shippingCost: json['shipping_cost'] != null
                ? double.parse(json['shipping_cost'].toString())
                : 0.0,
            discountAmount: json['discount_amount'] != null
                ? double.parse(json['discount_amount'].toString())
                : 0.0,
            status: json['status'] ?? 'pending',
            shippingAddressId: json['shipping_address_id'],
            billingAddressId: json['billing_address_id'],
            trackingNumber: json['tracking_number'],
            notes: json['notes'],
            createdAt: json['created_at'] != null
                ? DateTime.parse(json['created_at'])
                : null,
            updatedAt: json['updated_at'] != null
                ? DateTime.parse(json['updated_at'])
                : null,
          );
        }).toList();
      } else {
        print('Failed to fetch all orders: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching all orders: $e');
      return [];
    }
  }

  /// Update order status (Admin only)
  Future<bool> updateOrderStatusAdmin(int orderId, String newStatus) async {
    try {
      final token = await _getToken();
      if (token == null) {
        print('❌ No auth token found');
        return false;
      }

      // Validate status value on client side
      const validStatuses = [
        'pending',
        'confirmed',
        'assigned',
        'in_transit',
        'delivered',
        'cancelled',
      ];
      if (!validStatuses.contains(newStatus)) {
        print('❌ Invalid status value: $newStatus');
        print('   Valid statuses: ${validStatuses.join(', ')}');
        return false;
      }

      final baseUrl = ApiConfig.baseUrl;
      print('📡 Updating order #$orderId status to: $newStatus');

      final response = await http.put(
        Uri.parse('$baseUrl/orders/$orderId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'status': newStatus, 'tracking_number': null}),
      );

      if (response.statusCode == 200) {
        print('✅ Order status updated to: $newStatus');
        return true;
      } else if (response.statusCode == 400) {
        // Bad request - invalid status or constraint violation
        final responseData = jsonDecode(response.body);
        print('❌ Invalid status update request: ${responseData['message']}');
        if (responseData['validStatuses'] != null) {
          print(
            '   Valid statuses: ${responseData['validStatuses'].join(', ')}',
          );
        }
        return false;
      } else if (response.statusCode == 404) {
        print('❌ Order not found');
        return false;
      } else if (response.statusCode == 403) {
        print('❌ Not authorized to update order status (admin only)');
        return false;
      } else {
        print('❌ Failed to update order status: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error updating order status: $e');
      return false;
    }
  }

  // ========================================================================
  // MANAGER-SPECIFIC METHODS
  // ========================================================================

  /// Get all pending orders (Manager only)
  Future<List<Order>> getPendingOrdersManager() async {
    try {
      final token = await _getToken();
      if (token == null) {
        print('❌ No auth token found');
        return [];
      }

      final baseUrl = ApiConfig.baseUrl;
      final response = await http.get(
        Uri.parse('$baseUrl/orders/manager/pending'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> ordersJson = data['data'];
          return ordersJson.map((json) => Order.fromJson(json)).toList();
        }
      }
      print('❌ Failed to fetch pending orders: ${response.statusCode}');
      return [];
    } catch (e) {
      print('❌ Error fetching pending orders: $e');
      return [];
    }
  }

  /// Get list of all delivery people (Manager only)
  Future<List<Map<String, dynamic>>> getDeliveryPeople() async {
    try {
      final token = await _getToken();
      if (token == null) {
        print('❌ No auth token found');
        return [];
      }

      final baseUrl = ApiConfig.baseUrl;
      final response = await http.get(
        Uri.parse('$baseUrl/orders/manager/delivery-men'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      print('❌ Failed to fetch delivery people: ${response.statusCode}');
      return [];
    } catch (e) {
      print('❌ Error fetching delivery people: $e');
      return [];
    }
  }

  /// Get orders assigned to a specific delivery person (Manager only)
  Future<List<Order>> getDeliveryPersonOrders(int deliveryManId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        print('❌ No auth token found');
        return [];
      }

      final baseUrl = ApiConfig.baseUrl;
      final response = await http.get(
        Uri.parse('$baseUrl/orders/manager/delivery-man/$deliveryManId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> ordersJson = data['data'];
          return ordersJson.map((json) => Order.fromJson(json)).toList();
        }
      }
      print('❌ Failed to fetch delivery person orders: ${response.statusCode}');
      return [];
    } catch (e) {
      print('❌ Error fetching delivery person orders: $e');
      return [];
    }
  }

  /// Assign order to delivery person (Manager only)
  Future<bool> assignOrderToDelivery(int orderId, int deliveryManId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        print('❌ No auth token found');
        return false;
      }

      final baseUrl = ApiConfig.baseUrl;
      final response = await http.put(
        Uri.parse('$baseUrl/orders/$orderId/assign-delivery'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'delivery_man_id': deliveryManId}),
      );

      if (response.statusCode == 200) {
        print('✅ Order assigned to delivery person #$deliveryManId');
        return true;
      } else {
        print('❌ Failed to assign order: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error assigning order: $e');
      return false;
    }
  }

  /// Unassign delivery person from order (Manager only)
  Future<bool> unassignOrderFromDelivery(int orderId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        print('❌ No auth token found');
        return false;
      }

      final baseUrl = ApiConfig.baseUrl;
      final response = await http.put(
        Uri.parse('$baseUrl/orders/$orderId/unassign-delivery'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('✅ Delivery person unassigned from order');
        return true;
      } else {
        print('❌ Failed to unassign delivery person: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error unassigning delivery person: $e');
      return false;
    }
  }
}
