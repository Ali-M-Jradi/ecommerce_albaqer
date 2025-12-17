import 'package:albaqer_gemstone_flutter/database/database.dart';
import 'package:albaqer_gemstone_flutter/models/stone.dart';

// Insert a stone into the database
void insertStone(Stone stone) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  db.insert('stones', stone.stoneMap);
}

// Load all stones from the database
Future<List<Stone>> loadStones() async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  final result = await db.query('stones');
  List<Stone> resultList = result.map((row) {
    return Stone(
      id: row['id'] as int,
      name: row['name'] as String,
      color: row['color'] as String?,
      cut: row['cut'] as String?,
      origin: row['origin'] as String?,
      caratWeight: row['carat_weight'] as double?,
      sizeMm: row['size_mm'] as String?,
      clarity: row['clarity'] as String?,
      price: row['price'] as double,
      imageUrl: row['image_url'] as String?,
      rating: row['rating'] as double? ?? 0.0,
    );
  }).toList();
  return resultList;
}

// Get stone by ID
Future<Stone?> getStoneById(int id) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  final result = await db.query('stones', where: 'id = ?', whereArgs: [id]);
  if (result.isEmpty) {
    return null;
  }
  final row = result.first;
  return Stone(
    id: row['id'] as int,
    name: row['name'] as String,
    color: row['color'] as String?,
    cut: row['cut'] as String?,
    origin: row['origin'] as String?,
    caratWeight: row['carat_weight'] as double?,
    sizeMm: row['size_mm'] as String?,
    clarity: row['clarity'] as String?,
    price: row['price'] as double,
    imageUrl: row['image_url'] as String?,
    rating: row['rating'] as double? ?? 0.0,
  );
}

// Load stones by name (search)
Future<List<Stone>> searchStonesByName(String query) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  final result = await db.query(
    'stones',
    where: 'name LIKE ?',
    whereArgs: ['%$query%'],
  );
  List<Stone> resultList = result.map((row) {
    return Stone(
      id: row['id'] as int,
      name: row['name'] as String,
      color: row['color'] as String?,
      cut: row['cut'] as String?,
      origin: row['origin'] as String?,
      caratWeight: row['carat_weight'] as double?,
      sizeMm: row['size_mm'] as String?,
      clarity: row['clarity'] as String?,
      price: row['price'] as double,
      imageUrl: row['image_url'] as String?,
      rating: row['rating'] as double? ?? 0.0,
    );
  }).toList();
  return resultList;
}

// Load stones by color
Future<List<Stone>> loadStonesByColor(String color) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  final result = await db.query(
    'stones',
    where: 'color = ?',
    whereArgs: [color],
  );
  List<Stone> resultList = result.map((row) {
    return Stone(
      id: row['id'] as int,
      name: row['name'] as String,
      color: row['color'] as String?,
      cut: row['cut'] as String?,
      origin: row['origin'] as String?,
      caratWeight: row['carat_weight'] as double?,
      sizeMm: row['size_mm'] as String?,
      clarity: row['clarity'] as String?,
      price: row['price'] as double,
      imageUrl: row['image_url'] as String?,
      rating: row['rating'] as double? ?? 0.0,
    );
  }).toList();
  return resultList;
}

// Load stones by cut
Future<List<Stone>> loadStonesByCut(String cut) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  final result = await db.query('stones', where: 'cut = ?', whereArgs: [cut]);
  List<Stone> resultList = result.map((row) {
    return Stone(
      id: row['id'] as int,
      name: row['name'] as String,
      color: row['color'] as String?,
      cut: row['cut'] as String?,
      origin: row['origin'] as String?,
      caratWeight: row['carat_weight'] as double?,
      sizeMm: row['size_mm'] as String?,
      clarity: row['clarity'] as String?,
      price: row['price'] as double,
      imageUrl: row['image_url'] as String?,
      rating: row['rating'] as double? ?? 0.0,
    );
  }).toList();
  return resultList;
}

// Load stones within price range
Future<List<Stone>> loadStonesByPriceRange(
  double minPrice,
  double maxPrice,
) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  final result = await db.query(
    'stones',
    where: 'price BETWEEN ? AND ?',
    whereArgs: [minPrice, maxPrice],
    orderBy: 'price ASC',
  );
  List<Stone> resultList = result.map((row) {
    return Stone(
      id: row['id'] as int,
      name: row['name'] as String,
      color: row['color'] as String?,
      cut: row['cut'] as String?,
      origin: row['origin'] as String?,
      caratWeight: row['carat_weight'] as double?,
      sizeMm: row['size_mm'] as String?,
      clarity: row['clarity'] as String?,
      price: row['price'] as double,
      imageUrl: row['image_url'] as String?,
      rating: row['rating'] as double? ?? 0.0,
    );
  }).toList();
  return resultList;
}

// Update a stone
void updateStone(Stone stone) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  db.update('stones', stone.stoneMap, where: 'id = ?', whereArgs: [stone.id]);
}

// Delete a stone
void deleteStone(Stone stone) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  db.delete('stones', where: 'id = ?', whereArgs: [stone.id]);
}
