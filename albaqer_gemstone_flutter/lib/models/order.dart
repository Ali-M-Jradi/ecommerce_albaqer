class Order {
  final int? id;
  final int userId;
  final String orderNumber;
  final double totalAmount;
  final double taxAmount;
  final double shippingCost;
  final double discountAmount;
  final String status;
  final int? shippingAddressId;
  final int? billingAddressId;
  final String? trackingNumber;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Order({
    this.id,
    required this.userId,
    required this.orderNumber,
    required this.totalAmount,
    this.taxAmount = 0.0,
    this.shippingCost = 0.0,
    this.discountAmount = 0.0,
    this.status = 'pending',
    this.shippingAddressId,
    this.billingAddressId,
    this.trackingNumber,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> get orderMap {
    return {
      'id': id,
      'user_id': userId,
      'order_number': orderNumber,
      'total_amount': totalAmount,
      'tax_amount': taxAmount,
      'shipping_cost': shippingCost,
      'discount_amount': discountAmount,
      'status': status,
      'shipping_address_id': shippingAddressId,
      'billing_address_id': billingAddressId,
      'tracking_number': trackingNumber,
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
