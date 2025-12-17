import 'package:albaqer_gemstone_flutter/database/database.dart';
import 'package:albaqer_gemstone_flutter/models/order.dart';

// Insert an order into the database
void insertOrder(Order order) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  db.insert('orders', order.orderMap);
}

// Load all orders from the database
Future<List<Order>> loadOrders() async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  final result = await db.query('orders');
  List<Order> resultList = result.map((row) {
    return Order(
      id: row['id'] as int,
      userId: row['user_id'] as int,
      orderNumber: row['order_number'] as String,
      totalAmount: row['total_amount'] as double,
      taxAmount: row['tax_amount'] as double? ?? 0.0,
      shippingCost: row['shipping_cost'] as double? ?? 0.0,
      discountAmount: row['discount_amount'] as double? ?? 0.0,
      status: row['status'] as String? ?? 'pending',
      shippingAddressId: row['shipping_address_id'] as int?,
      billingAddressId: row['billing_address_id'] as int?,
      trackingNumber: row['tracking_number'] as String?,
      notes: row['notes'] as String?,
      createdAt: row['created_at'] != null
          ? DateTime.parse(row['created_at'] as String)
          : null,
      updatedAt: row['updated_at'] != null
          ? DateTime.parse(row['updated_at'] as String)
          : null,
    );
  }).toList();
  return resultList;
}

// Load orders by user ID
Future<List<Order>> loadOrdersByUserId(int userId) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  final result = await db.query(
    'orders',
    where: 'user_id = ?',
    whereArgs: [userId],
    orderBy: 'created_at DESC',
  );
  List<Order> resultList = result.map((row) {
    return Order(
      id: row['id'] as int,
      userId: row['user_id'] as int,
      orderNumber: row['order_number'] as String,
      totalAmount: row['total_amount'] as double,
      taxAmount: row['tax_amount'] as double? ?? 0.0,
      shippingCost: row['shipping_cost'] as double? ?? 0.0,
      discountAmount: row['discount_amount'] as double? ?? 0.0,
      status: row['status'] as String? ?? 'pending',
      shippingAddressId: row['shipping_address_id'] as int?,
      billingAddressId: row['billing_address_id'] as int?,
      trackingNumber: row['tracking_number'] as String?,
      notes: row['notes'] as String?,
      createdAt: row['created_at'] != null
          ? DateTime.parse(row['created_at'] as String)
          : null,
      updatedAt: row['updated_at'] != null
          ? DateTime.parse(row['updated_at'] as String)
          : null,
    );
  }).toList();
  return resultList;
}

// Get order by ID
Future<Order?> getOrderById(int id) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  final result = await db.query('orders', where: 'id = ?', whereArgs: [id]);
  if (result.isEmpty) {
    return null;
  }
  final row = result.first;
  return Order(
    id: row['id'] as int,
    userId: row['user_id'] as int,
    orderNumber: row['order_number'] as String,
    totalAmount: row['total_amount'] as double,
    taxAmount: row['tax_amount'] as double? ?? 0.0,
    shippingCost: row['shipping_cost'] as double? ?? 0.0,
    discountAmount: row['discount_amount'] as double? ?? 0.0,
    status: row['status'] as String? ?? 'pending',
    shippingAddressId: row['shipping_address_id'] as int?,
    billingAddressId: row['billing_address_id'] as int?,
    trackingNumber: row['tracking_number'] as String?,
    notes: row['notes'] as String?,
    createdAt: row['created_at'] != null
        ? DateTime.parse(row['created_at'] as String)
        : null,
    updatedAt: row['updated_at'] != null
        ? DateTime.parse(row['updated_at'] as String)
        : null,
  );
}

// Load orders by status
Future<List<Order>> loadOrdersByStatus(String status) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  final result = await db.query(
    'orders',
    where: 'status = ?',
    whereArgs: [status],
    orderBy: 'created_at DESC',
  );
  List<Order> resultList = result.map((row) {
    return Order(
      id: row['id'] as int,
      userId: row['user_id'] as int,
      orderNumber: row['order_number'] as String,
      totalAmount: row['total_amount'] as double,
      taxAmount: row['tax_amount'] as double? ?? 0.0,
      shippingCost: row['shipping_cost'] as double? ?? 0.0,
      discountAmount: row['discount_amount'] as double? ?? 0.0,
      status: row['status'] as String? ?? 'pending',
      shippingAddressId: row['shipping_address_id'] as int?,
      billingAddressId: row['billing_address_id'] as int?,
      trackingNumber: row['tracking_number'] as String?,
      notes: row['notes'] as String?,
      createdAt: row['created_at'] != null
          ? DateTime.parse(row['created_at'] as String)
          : null,
      updatedAt: row['updated_at'] != null
          ? DateTime.parse(row['updated_at'] as String)
          : null,
    );
  }).toList();
  return resultList;
}

// Update an order
void updateOrder(Order order) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  db.update('orders', order.orderMap, where: 'id = ?', whereArgs: [order.id]);
}

// Update order status
void updateOrderStatus(int orderId, String status) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  db.update(
    'orders',
    {'status': status, 'updated_at': DateTime.now().toIso8601String()},
    where: 'id = ?',
    whereArgs: [orderId],
  );
}

// Delete an order
void deleteOrder(Order order) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  db.delete('orders', where: 'id = ?', whereArgs: [order.id]);
}
