import '../config/api_config.dart';

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

  // Metal specifications
  final String? metalType;
  final String? metalColor;
  final String? metalPurity;
  final double? metalWeightGrams;

  // Stone specifications
  final String? stoneType;
  final String? stoneColor;
  final double? stoneCarat;
  final String? stoneCut;
  final String? stoneClarity;

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
    this.metalType,
    this.metalColor,
    this.metalPurity,
    this.metalWeightGrams,
    this.stoneType,
    this.stoneColor,
    this.stoneCarat,
    this.stoneCut,
    this.stoneClarity,
  });

  // Get full image URL for network images
  String? get fullImageUrl {
    if (imageUrl == null || imageUrl!.isEmpty) return null;

    // If already a full URL, return as is
    if (imageUrl!.startsWith('http://') || imageUrl!.startsWith('https://')) {
      return imageUrl;
    }

    // Build full URL using ApiConfig
    return '${ApiConfig.serverUrl}$imageUrl';
  }

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
      'metal_type': metalType,
      'metal_color': metalColor,
      'metal_purity': metalPurity,
      'metal_weight_grams': metalWeightGrams,
      'stone_type': stoneType,
      'stone_color': stoneColor,
      'stone_carat': stoneCarat,
      'stone_cut': stoneCut,
      'stone_clarity': stoneClarity,
    };
  }
}
