import 'package:albaqer_gemstone_flutter/database/database.dart';
import 'package:albaqer_gemstone_flutter/models/product.dart';

// Insert a product into the database
void insertProduct(Product product) async {
  // get an instance of the database
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  // insert product into the database
  db.insert('products', product.productMap);
}

// Load all products from the database
Future<List<Product>> loadProducts() async {
  // get an instance of the database
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  // get all products from the database
  final result = await db.query('products');
  // map every row into a Product object
  List<Product> resultList = result.map((row) {
    return Product(
      id: row['id'] as int,
      name: row['name'] as String,
      type: row['type'] as String,
      description: row['description'] as String?,
      basePrice: row['base_price'] as double,
      rating: row['rating'] as double? ?? 0.0,
      totalReviews: row['total_reviews'] as int? ?? 0,
      quantityInStock: row['quantity_in_stock'] as int,
      imageUrl: row['image_url'] as String?,
      isAvailable: (row['is_available'] as int) == 1,
      createdAt: row['created_at'] != null
          ? DateTime.parse(row['created_at'] as String)
          : null,
      updatedAt: row['updated_at'] != null
          ? DateTime.parse(row['updated_at'] as String)
          : null,
      metalType: row['metal_type'] as String?,
      metalColor: row['metal_color'] as String?,
      metalPurity: row['metal_purity'] as String?,
      metalWeightGrams: row['metal_weight_grams'] as double?,
      stoneType: row['stone_type'] as String?,
      stoneColor: row['stone_color'] as String?,
      stoneCarat: row['stone_carat'] as double?,
      stoneCut: row['stone_cut'] as String?,
      stoneClarity: row['stone_clarity'] as String?,
    );
  }).toList();
  // return the resulting products list
  return resultList;
}

// Load products by type (e.g., 'ring', 'necklace')
Future<List<Product>> loadProductsByType(String type) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  final result = await db.query(
    'products',
    where: 'type = ?',
    whereArgs: [type],
  );
  List<Product> resultList = result.map((row) {
    return Product(
      id: row['id'] as int,
      name: row['name'] as String,
      type: row['type'] as String,
      description: row['description'] as String?,
      basePrice: row['base_price'] as double,
      rating: row['rating'] as double? ?? 0.0,
      totalReviews: row['total_reviews'] as int? ?? 0,
      quantityInStock: row['quantity_in_stock'] as int,
      imageUrl: row['image_url'] as String?,
      isAvailable: (row['is_available'] as int) == 1,
      createdAt: row['created_at'] != null
          ? DateTime.parse(row['created_at'] as String)
          : null,
      updatedAt: row['updated_at'] != null
          ? DateTime.parse(row['updated_at'] as String)
          : null,
      metalType: row['metal_type'] as String?,
      metalColor: row['metal_color'] as String?,
      metalPurity: row['metal_purity'] as String?,
      metalWeightGrams: row['metal_weight_grams'] as double?,
      stoneType: row['stone_type'] as String?,
      stoneColor: row['stone_color'] as String?,
      stoneCarat: row['stone_carat'] as double?,
      stoneCut: row['stone_cut'] as String?,
      stoneClarity: row['stone_clarity'] as String?,
    );
  }).toList();
  return resultList;
}

// Update a product in the database
void updateProduct(Product product) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  db.update(
    'products',
    product.productMap,
    where: 'id = ?',
    whereArgs: [product.id],
  );
}

// Delete a product from the database
void deleteProduct(Product product) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  db.delete('products', where: 'id = ?', whereArgs: [product.id]);
}

// Search products by name
Future<List<Product>> searchProducts(String query) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  final result = await db.query(
    'products',
    where: 'name LIKE ?',
    whereArgs: ['%$query%'],
  );
  List<Product> resultList = result.map((row) {
    return Product(
      id: row['id'] as int,
      name: row['name'] as String,
      type: row['type'] as String,
      description: row['description'] as String?,
      basePrice: row['base_price'] as double,
      rating: row['rating'] as double? ?? 0.0,
      totalReviews: row['total_reviews'] as int? ?? 0,
      quantityInStock: row['quantity_in_stock'] as int,
      imageUrl: row['image_url'] as String?,
      isAvailable: (row['is_available'] as int) == 1,
      createdAt: row['created_at'] != null
          ? DateTime.parse(row['created_at'] as String)
          : null,
      updatedAt: row['updated_at'] != null
          ? DateTime.parse(row['updated_at'] as String)
          : null,
    );
  }).toList();
  return resultList;
}

// Load all unique product categories (types) from local database
Future<List<String>> loadCategories() async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  final result = await db.rawQuery(
    'SELECT DISTINCT type FROM products WHERE type IS NOT NULL ORDER BY type',
  );
  return result.map((row) => row['type'] as String).toList();
}
