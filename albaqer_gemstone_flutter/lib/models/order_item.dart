/// Order Item Model - Represents a single product in an order
class OrderItem {
  final int? id;
  final int orderId;
  final int productId;
  final int quantity;
  final double priceAtPurchase;

  OrderItem({
    this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.priceAtPurchase,
  });

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
      'price_at_purchase': priceAtPurchase,
    };
  }

  /// Create from API response
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      orderId: json['order_id'],
      productId: json['product_id'],
      quantity: json['quantity'],
      priceAtPurchase: json['price_at_purchase']?.toDouble() ?? 0.0,
    );
  }
}
