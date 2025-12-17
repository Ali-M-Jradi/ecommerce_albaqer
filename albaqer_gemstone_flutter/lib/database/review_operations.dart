import 'package:albaqer_gemstone_flutter/database/database.dart';
import 'package:albaqer_gemstone_flutter/models/review.dart';

// Insert a review into the database
void insertReview(Review review) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  db.insert('reviews', review.reviewMap);
}

// Load all reviews from the database
Future<List<Review>> loadReviews() async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  final result = await db.query('reviews', orderBy: 'created_at DESC');
  List<Review> resultList = result.map((row) {
    return Review(
      id: row['id'] as int,
      userId: row['user_id'] as int,
      productId: row['product_id'] as int,
      orderId: row['order_id'] as int?,
      rating: row['rating'] as int,
      title: row['title'] as String?,
      comment: row['comment'] as String?,
      isVerifiedPurchase: (row['is_verified_purchase'] as int) == 1,
      helpfulCount: row['helpful_count'] as int? ?? 0,
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

// Load reviews by product ID
Future<List<Review>> loadReviewsByProductId(int productId) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  final result = await db.query(
    'reviews',
    where: 'product_id = ?',
    whereArgs: [productId],
    orderBy: 'created_at DESC',
  );
  List<Review> resultList = result.map((row) {
    return Review(
      id: row['id'] as int,
      userId: row['user_id'] as int,
      productId: row['product_id'] as int,
      orderId: row['order_id'] as int?,
      rating: row['rating'] as int,
      title: row['title'] as String?,
      comment: row['comment'] as String?,
      isVerifiedPurchase: (row['is_verified_purchase'] as int) == 1,
      helpfulCount: row['helpful_count'] as int? ?? 0,
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

// Load reviews by user ID
Future<List<Review>> loadReviewsByUserId(int userId) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  final result = await db.query(
    'reviews',
    where: 'user_id = ?',
    whereArgs: [userId],
    orderBy: 'created_at DESC',
  );
  List<Review> resultList = result.map((row) {
    return Review(
      id: row['id'] as int,
      userId: row['user_id'] as int,
      productId: row['product_id'] as int,
      orderId: row['order_id'] as int?,
      rating: row['rating'] as int,
      title: row['title'] as String?,
      comment: row['comment'] as String?,
      isVerifiedPurchase: (row['is_verified_purchase'] as int) == 1,
      helpfulCount: row['helpful_count'] as int? ?? 0,
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

// Get review by ID
Future<Review?> getReviewById(int id) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  final result = await db.query('reviews', where: 'id = ?', whereArgs: [id]);
  if (result.isEmpty) {
    return null;
  }
  final row = result.first;
  return Review(
    id: row['id'] as int,
    userId: row['user_id'] as int,
    productId: row['product_id'] as int,
    orderId: row['order_id'] as int?,
    rating: row['rating'] as int,
    title: row['title'] as String?,
    comment: row['comment'] as String?,
    isVerifiedPurchase: (row['is_verified_purchase'] as int) == 1,
    helpfulCount: row['helpful_count'] as int? ?? 0,
    createdAt: row['created_at'] != null
        ? DateTime.parse(row['created_at'] as String)
        : null,
    updatedAt: row['updated_at'] != null
        ? DateTime.parse(row['updated_at'] as String)
        : null,
  );
}

// Get average rating for a product
Future<double> getAverageRatingForProduct(int productId) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  final result = await db.rawQuery(
    'SELECT AVG(rating) as average FROM reviews WHERE product_id = ?',
    [productId],
  );
  if (result.isEmpty || result.first['average'] == null) {
    return 0.0;
  }
  return result.first['average'] as double;
}

// Get review count for a product
Future<int> getReviewCountForProduct(int productId) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  final result = await db.rawQuery(
    'SELECT COUNT(*) as count FROM reviews WHERE product_id = ?',
    [productId],
  );
  if (result.isEmpty) {
    return 0;
  }
  return result.first['count'] as int;
}

// Update a review
void updateReview(Review review) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  db.update(
    'reviews',
    review.reviewMap,
    where: 'id = ?',
    whereArgs: [review.id],
  );
}

// Increment helpful count
void incrementHelpfulCount(int reviewId) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  db.rawUpdate(
    'UPDATE reviews SET helpful_count = helpful_count + 1 WHERE id = ?',
    [reviewId],
  );
}

// Delete a review
void deleteReview(Review review) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  db.delete('reviews', where: 'id = ?', whereArgs: [review.id]);
}
