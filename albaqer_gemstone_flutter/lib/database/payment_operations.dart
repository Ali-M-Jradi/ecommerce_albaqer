import 'package:albaqer_gemstone_flutter/database/database.dart';
import 'package:albaqer_gemstone_flutter/models/payment.dart';
import 'package:sqflite/sqflite.dart';

// Insert a payment into the database (replaces if ID already exists)
void insertPayment(Payment payment) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  db.insert(
    'payments',
    payment.paymentMap,
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

// Load all payments from the database
Future<List<Payment>> loadPayments() async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  final result = await db.query('payments', orderBy: 'created_at DESC');
  List<Payment> resultList = result.map((row) {
    return Payment.fromMap(row);
  }).toList();
  return resultList;
}

// Get a single payment by ID
Future<Payment?> getPaymentById(int paymentId) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  final result = await db.query(
    'payments',
    where: 'id = ?',
    whereArgs: [paymentId],
  );

  if (result.isEmpty) return null;

  return Payment.fromMap(result.first);
}

// Get payment by order ID
Future<Payment?> getPaymentByOrderId(int orderId) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  final result = await db.query(
    'payments',
    where: 'order_id = ?',
    whereArgs: [orderId],
    limit: 1,
  );

  if (result.isEmpty) return null;

  return Payment.fromMap(result.first);
}

// Get all payments by status
Future<List<Payment>> getPaymentsByStatus(String status) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  final result = await db.query(
    'payments',
    where: 'status = ?',
    whereArgs: [status],
    orderBy: 'created_at DESC',
  );
  List<Payment> resultList = result.map((row) {
    return Payment.fromMap(row);
  }).toList();
  return resultList;
}

// Get all payments by payment method
Future<List<Payment>> getPaymentsByMethod(String paymentMethod) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  final result = await db.query(
    'payments',
    where: 'payment_method = ?',
    whereArgs: [paymentMethod],
    orderBy: 'created_at DESC',
  );
  List<Payment> resultList = result.map((row) {
    return Payment.fromMap(row);
  }).toList();
  return resultList;
}

// Update a payment in the database
void updatePayment(Payment payment) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  db.update(
    'payments',
    payment.paymentMap,
    where: 'id = ?',
    whereArgs: [payment.id],
  );
}

// Update payment status
Future<void> updatePaymentStatus(int paymentId, String newStatus) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  await db.update(
    'payments',
    {'status': newStatus},
    where: 'id = ?',
    whereArgs: [paymentId],
  );
}

// Delete a payment from the database
void deletePayment(Payment payment) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  db.delete('payments', where: 'id = ?', whereArgs: [payment.id]);
}

// Get total payment amount by status
Future<double> getTotalPaymentsByStatus(String status) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  final result = await db.rawQuery(
    'SELECT SUM(amount) as total FROM payments WHERE status = ?',
    [status],
  );

  if (result.isEmpty || result.first['total'] == null) {
    return 0.0;
  }

  return result.first['total'] as double;
}
