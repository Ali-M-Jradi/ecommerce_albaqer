import 'package:albaqer_gemstone_flutter/database/database.dart';
import 'package:albaqer_gemstone_flutter/models/cart_item.dart';

// Add item to cart and return the inserted ID
Future<int> addToCart(CartItem cartItem) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  return await db.insert('cart_items', cartItem.cartItemMap);
}

// Load all cart items
Future<List<CartItem>> loadCartItems(int cartId) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  final result = await db.query(
    'cart_items',
    where: 'cart_id = ?',
    whereArgs: [cartId],
  );
  List<CartItem> resultList = result.map((row) {
    return CartItem(
      id: row['id'] as int,
      cartId: row['cart_id'] as int,
      productId: row['product_id'] as int,
      quantity: row['quantity'] as int,
      priceAtAdd: row['price_at_add'] as double,
    );
  }).toList();
  return resultList;
}

// Update cart item quantity
void updateCartItem(CartItem cartItem) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  db.update(
    'cart_items',
    cartItem.cartItemMap,
    where: 'id = ?',
    whereArgs: [cartItem.id],
  );
}

// Remove item from cart
void removeFromCart(int cartItemId) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  db.delete('cart_items', where: 'id = ?', whereArgs: [cartItemId]);
}

// Clear all cart items
void clearCart(int cartId) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  db.delete('cart_items', where: 'cart_id = ?', whereArgs: [cartId]);
}
