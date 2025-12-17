import 'package:albaqer_gemstone_flutter/database/database.dart';
import 'package:albaqer_gemstone_flutter/models/wishlist_item.dart';

// Add to wishlist
void addToWishlist(WishlistItem item) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  db.insert('wishlists', item.wishlistMap);
}

// Load wishlist items
Future<List<WishlistItem>> loadWishlist(int userId) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  final result = await db.query(
    'wishlists',
    where: 'user_id = ?',
    whereArgs: [userId],
  );
  List<WishlistItem> resultList = result.map((row) {
    return WishlistItem(
      id: row['id'] as int,
      userId: row['user_id'] as int,
      productId: row['product_id'] as int,
      addedAt: row['added_at'] != null
          ? DateTime.parse(row['added_at'] as String)
          : null,
    );
  }).toList();
  return resultList;
}

// Remove from wishlist
void removeFromWishlist(int wishlistId) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  db.delete('wishlists', where: 'id = ?', whereArgs: [wishlistId]);
}

// Check if product is in wishlist
Future<bool> isInWishlist(int userId, int productId) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  final result = await db.query(
    'wishlists',
    where: 'user_id = ? AND product_id = ?',
    whereArgs: [userId, productId],
  );
  return result.isNotEmpty;
}
