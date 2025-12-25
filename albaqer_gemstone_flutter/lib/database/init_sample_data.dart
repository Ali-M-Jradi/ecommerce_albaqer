import 'package:albaqer_gemstone_flutter/database/database.dart';
import 'package:albaqer_gemstone_flutter/models/product.dart';

/// Initialize the database with sample products
Future<void> initializeSampleData() async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();

  // Check if we already have products
  final count = await db.rawQuery('SELECT COUNT(*) as count FROM products');
  final productCount = count.first['count'] as int;

  if (productCount > 0) {
    print('✅ Database already has $productCount products');
    return;
  }

  print('📦 Initializing sample data...');

  // Sample products
  final sampleProducts = [
    {
      'name': 'Classic Diamond Engagement Ring',
      'type': 'ring',
      'description': 'Elegant solitaire diamond ring perfect for engagements',
      'base_price': 2500.00,
      'rating': 4.8,
      'total_reviews': 124,
      'quantity_in_stock': 5,
      'image_url': 'https://example.com/diamond-ring.jpg',
      'is_available': 1,
      'metal_type': 'Gold',
      'metal_color': 'White',
      'metal_purity': '14K',
      'metal_weight_grams': 3.5,
      'stone_type': 'Diamond',
      'stone_color': 'Colorless',
      'stone_carat': 1.0,
      'stone_cut': 'Round',
      'stone_clarity': 'VS1',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    },
    {
      'name': 'Ruby Pendant Necklace',
      'type': 'necklace',
      'description': 'Beautiful ruby pendant on gold chain',
      'base_price': 1800.00,
      'rating': 4.6,
      'total_reviews': 89,
      'quantity_in_stock': 8,
      'image_url': 'https://example.com/ruby-necklace.jpg',
      'is_available': 1,
      'metal_type': 'Gold',
      'metal_color': 'Yellow',
      'metal_purity': '18K',
      'metal_weight_grams': 5.2,
      'stone_type': 'Ruby',
      'stone_color': 'Red',
      'stone_carat': 2.5,
      'stone_cut': 'Oval',
      'stone_clarity': 'VVS2',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    },
    {
      'name': 'Emerald Stud Earrings',
      'type': 'earrings',
      'description': 'Pair of emerald stud earrings in white gold',
      'base_price': 1200.00,
      'rating': 4.7,
      'total_reviews': 56,
      'quantity_in_stock': 12,
      'image_url': 'https://example.com/emerald-earrings.jpg',
      'is_available': 1,
      'metal_type': 'Gold',
      'metal_color': 'White',
      'metal_purity': '14K',
      'metal_weight_grams': 2.8,
      'stone_type': 'Emerald',
      'stone_color': 'Green',
      'stone_carat': 1.5,
      'stone_cut': 'Square',
      'stone_clarity': 'VS2',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    },
    {
      'name': 'Sapphire Tennis Bracelet',
      'type': 'bracelet',
      'description': 'Stunning sapphire tennis bracelet with diamonds',
      'base_price': 3500.00,
      'rating': 4.9,
      'total_reviews': 201,
      'quantity_in_stock': 3,
      'image_url': 'https://example.com/sapphire-bracelet.jpg',
      'is_available': 1,
      'metal_type': 'Platinum',
      'metal_color': 'White',
      'metal_purity': '950',
      'metal_weight_grams': 12.5,
      'stone_type': 'Sapphire',
      'stone_color': 'Blue',
      'stone_carat': 8.0,
      'stone_cut': 'Round',
      'stone_clarity': 'VVS1',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    },
    {
      'name': 'Pearl Drop Necklace',
      'type': 'necklace',
      'description': 'Elegant freshwater pearl necklace',
      'base_price': 450.00,
      'rating': 4.5,
      'total_reviews': 34,
      'quantity_in_stock': 15,
      'image_url': 'https://example.com/pearl-necklace.jpg',
      'is_available': 1,
      'metal_type': 'Silver',
      'metal_color': 'White',
      'metal_purity': '925',
      'metal_weight_grams': 8.0,
      'stone_type': 'Pearl',
      'stone_color': 'White',
      'stone_carat': 0.0,
      'stone_cut': 'Round',
      'stone_clarity': 'AAA',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    },
  ];

  // Insert all sample products
  for (var product in sampleProducts) {
    await db.insert('products', product);
  }

  print('✅ Successfully added ${sampleProducts.length} sample products!');
}
