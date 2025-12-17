class Product {
  final int? id;
  final String name;
  final String type;
  final String? description;
  final double basePrice;
  final double rating;
  final int totalReviews;
  final int quantityInStock;
  final String? imageUrl;
  final bool isAvailable;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    this.id,
    required this.name,
    required this.type,
    this.description,
    required this.basePrice,
    this.rating = 0.0,
    this.totalReviews = 0,
    required this.quantityInStock,
    this.imageUrl,
    this.isAvailable = true,
    this.createdAt,
    this.updatedAt,
  });

  // Convert Product to Map for database insertion
  Map<String, dynamic> get productMap {
    return {
      'id': id,
      'name': name,
      'type': type,
      'description': description,
      'base_price': basePrice,
      'rating': rating,
      'total_reviews': totalReviews,
      'quantity_in_stock': quantityInStock,
      'image_url': imageUrl,
      'is_available': isAvailable ? 1 : 0,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
