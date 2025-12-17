class WishlistItem {
  final int? id;
  final int userId;
  final int productId;
  final DateTime? addedAt;

  WishlistItem({
    this.id,
    required this.userId,
    required this.productId,
    this.addedAt,
  });

  Map<String, dynamic> get wishlistMap {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'added_at': addedAt?.toIso8601String(),
    };
  }
}
