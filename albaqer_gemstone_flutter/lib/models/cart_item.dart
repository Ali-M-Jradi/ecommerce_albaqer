class CartItem {
  final int? id;
  final int cartId;
  final int productId;
  final int quantity;
  final double priceAtAdd;
  final String? trackingId;

  CartItem({
    this.id,
    required this.cartId,
    required this.productId,
    required this.quantity,
    required this.priceAtAdd,
    this.trackingId,
  });

  Map<String, dynamic> get cartItemMap {
    return {
      'id': id,
      'cart_id': cartId,
      'product_id': productId,
      'quantity': quantity,
      'price_at_add': priceAtAdd,
      'tracking_id': trackingId,
    };
  }
}
