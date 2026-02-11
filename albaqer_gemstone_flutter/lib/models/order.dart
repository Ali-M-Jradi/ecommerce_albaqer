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
  final int? deliveryManId;
  final DateTime? assignedAt;
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
    this.deliveryManId,
    this.assignedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
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
      deliveryManId: json['delivery_man_id'],
      assignedAt: json['assigned_at'] != null
          ? DateTime.parse(json['assigned_at'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

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
      'delivery_man_id': deliveryManId,
      'assigned_at': assignedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
