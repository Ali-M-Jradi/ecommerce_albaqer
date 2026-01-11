import 'package:albaqer_gemstone_flutter/database/database.dart';
import 'package:albaqer_gemstone_flutter/models/category.dart';
import 'package:sqflite/sqflite.dart';

// Insert a category into the database (replaces if ID already exists)
void insertCategory(Category category) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  db.insert(
    'categories',
    category.categoryMap,
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

// Load all categories from the database
Future<List<Category>> loadCategories() async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  final result = await db.query('categories');
  List<Category> resultList = result.map((row) {
    return Category.fromMap(row);
  }).toList();
  return resultList;
}

// Get a single category by ID
Future<Category?> getCategoryById(int categoryId) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  final result = await db.query(
    'categories',
    where: 'id = ?',
    whereArgs: [categoryId],
  );

  if (result.isEmpty) return null;

  return Category.fromMap(result.first);
}

// Update a category in the database
void updateCategory(Category category) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  db.update(
    'categories',
    category.categoryMap,
    where: 'id = ?',
    whereArgs: [category.id],
  );
}

// Delete a category from the database
void deleteCategory(Category category) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  db.delete('categories', where: 'id = ?', whereArgs: [category.id]);
}

// Link a product to a category (many-to-many relationship)
Future<void> addProductToCategory(int productId, int categoryId) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  await db.insert('product_categories', {
    'product_id': productId,
    'category_id': categoryId,
  }, conflictAlgorithm: ConflictAlgorithm.ignore);
}

// Remove a product from a category
Future<void> removeProductFromCategory(int productId, int categoryId) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  await db.delete(
    'product_categories',
    where: 'product_id = ? AND category_id = ?',
    whereArgs: [productId, categoryId],
  );
}

// Get all category IDs for a product
Future<List<int>> getCategoriesForProduct(int productId) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  final result = await db.query(
    'product_categories',
    where: 'product_id = ?',
    whereArgs: [productId],
  );
  return result.map((row) => row['category_id'] as int).toList();
}

// Get all product IDs for a category
Future<List<int>> getProductsForCategory(int categoryId) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  final result = await db.query(
    'product_categories',
    where: 'category_id = ?',
    whereArgs: [categoryId],
  );
  return result.map((row) => row['product_id'] as int).toList();
}
