class Review {
  final int? id;
  final int userId;
  final int productId;
  final int? orderId;
  final int rating;
  final String? title;
  final String? comment;
  final bool isVerifiedPurchase;
  final int helpfulCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Review({
    this.id,
    required this.userId,
    required this.productId,
    this.orderId,
    required this.rating,
    this.title,
    this.comment,
    this.isVerifiedPurchase = false,
    this.helpfulCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> get reviewMap {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'order_id': orderId,
      'rating': rating,
      'title': title,
      'comment': comment,
      'is_verified_purchase': isVerifiedPurchase ? 1 : 0,
      'helpful_count': helpfulCount,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
