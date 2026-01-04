import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:albaqer_gemstone_flutter/models/order.dart';

/// Service class for handling all order-related API calls to the backend
class OrderService {
  // For Android Emulator: use 10.0.2.2 (maps to host machine's localhost)
  final String baseUrl = 'http://192.168.0.109:3000/api';

  // ========== CREATE ==========
  /// Create a new order on the backend
  Future<Order?> createOrder(Order order) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(order.orderMap),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Order(
          id: data['id'],
          userId: data['user_id'],
          orderNumber: data['order_number'],
          totalAmount: data['total_amount'].toDouble(),
          taxAmount: data['tax_amount']?.toDouble() ?? 0.0,
          shippingCost: data['shipping_cost']?.toDouble() ?? 0.0,
          discountAmount: data['discount_amount']?.toDouble() ?? 0.0,
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
      } else {
        print('Failed to create order: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error creating order: $e');
      return null;
    }
  }

  // ========== READ (ALL) ==========
  /// Fetch all orders from the backend
  Future<List<Order>> fetchAllOrders() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/orders'));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        List<dynamic> data = jsonResponse['data'];
        return data.map((json) {
          return Order(
            id: json['id'],
            userId: json['user_id'],
            orderNumber: json['order_number'],
            totalAmount: json['total_amount'].toDouble(),
            taxAmount: json['tax_amount']?.toDouble() ?? 0.0,
            shippingCost: json['shipping_cost']?.toDouble() ?? 0.0,
            discountAmount: json['discount_amount']?.toDouble() ?? 0.0,
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
      final response = await http.get(Uri.parse('$baseUrl/orders/$id'));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Order(
          id: json['id'],
          userId: json['user_id'],
          orderNumber: json['order_number'],
          totalAmount: json['total_amount'].toDouble(),
          taxAmount: json['tax_amount']?.toDouble() ?? 0.0,
          shippingCost: json['shipping_cost']?.toDouble() ?? 0.0,
          discountAmount: json['discount_amount']?.toDouble() ?? 0.0,
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
          totalAmount: json['total_amount'].toDouble(),
          taxAmount: json['tax_amount']?.toDouble() ?? 0.0,
          shippingCost: json['shipping_cost']?.toDouble() ?? 0.0,
          discountAmount: json['discount_amount']?.toDouble() ?? 0.0,
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
      final response = await http.delete(Uri.parse('$baseUrl/orders/$orderId'));

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
}
