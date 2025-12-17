import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:albaqer_gemstone_flutter/models/review.dart';

/// Service class for handling all review-related API calls to the backend
class ReviewService {
  final String baseUrl = 'http://localhost:3000';

  // ========== CREATE ==========
  /// Create a new review on the backend
  Future<Review?> createReview(Review review) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reviews'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(review.reviewMap),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Review(
          id: data['id'],
          userId: data['user_id'],
          productId: data['product_id'],
          orderId: data['order_id'],
          rating: data['rating'],
          title: data['title'],
          comment: data['comment'],
          isVerifiedPurchase: data['is_verified_purchase'] == 1,
          helpfulCount: data['helpful_count'] ?? 0,
          createdAt: data['created_at'] != null
              ? DateTime.parse(data['created_at'])
              : null,
          updatedAt: data['updated_at'] != null
              ? DateTime.parse(data['updated_at'])
              : null,
        );
      } else {
        print('Failed to create review: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error creating review: $e');
      return null;
    }
  }

  // ========== READ (ALL) ==========
  /// Fetch all reviews from the backend
  Future<List<Review>> fetchAllReviews() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/reviews'));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) {
          return Review(
            id: json['id'],
            userId: json['user_id'],
            productId: json['product_id'],
            orderId: json['order_id'],
            rating: json['rating'],
            title: json['title'],
            comment: json['comment'],
            isVerifiedPurchase: json['is_verified_purchase'] == 1,
            helpfulCount: json['helpful_count'] ?? 0,
            createdAt: json['created_at'] != null
                ? DateTime.parse(json['created_at'])
                : null,
            updatedAt: json['updated_at'] != null
                ? DateTime.parse(json['updated_at'])
                : null,
          );
        }).toList();
      } else {
        print('Failed to fetch reviews: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching reviews: $e');
      return [];
    }
  }

  // ========== READ (BY PRODUCT ID) ==========
  /// Fetch all reviews for a specific product
  Future<List<Review>> fetchReviewsByProductId(int productId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reviews?product_id=$productId'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) {
          return Review(
            id: json['id'],
            userId: json['user_id'],
            productId: json['product_id'],
            orderId: json['order_id'],
            rating: json['rating'],
            title: json['title'],
            comment: json['comment'],
            isVerifiedPurchase: json['is_verified_purchase'] == 1,
            helpfulCount: json['helpful_count'] ?? 0,
            createdAt: json['created_at'] != null
                ? DateTime.parse(json['created_at'])
                : null,
            updatedAt: json['updated_at'] != null
                ? DateTime.parse(json['updated_at'])
                : null,
          );
        }).toList();
      } else {
        print('Failed to fetch product reviews: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching product reviews: $e');
      return [];
    }
  }

  // ========== READ (BY USER ID) ==========
  /// Fetch all reviews by a specific user
  Future<List<Review>> fetchReviewsByUserId(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reviews?user_id=$userId'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) {
          return Review(
            id: json['id'],
            userId: json['user_id'],
            productId: json['product_id'],
            orderId: json['order_id'],
            rating: json['rating'],
            title: json['title'],
            comment: json['comment'],
            isVerifiedPurchase: json['is_verified_purchase'] == 1,
            helpfulCount: json['helpful_count'] ?? 0,
            createdAt: json['created_at'] != null
                ? DateTime.parse(json['created_at'])
                : null,
            updatedAt: json['updated_at'] != null
                ? DateTime.parse(json['updated_at'])
                : null,
          );
        }).toList();
      } else {
        print('Failed to fetch user reviews: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching user reviews: $e');
      return [];
    }
  }

  // ========== READ (BY ID) ==========
  /// Fetch a single review by ID
  Future<Review?> fetchReviewById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/reviews/$id'));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Review(
          id: json['id'],
          userId: json['user_id'],
          productId: json['product_id'],
          orderId: json['order_id'],
          rating: json['rating'],
          title: json['title'],
          comment: json['comment'],
          isVerifiedPurchase: json['is_verified_purchase'] == 1,
          helpfulCount: json['helpful_count'] ?? 0,
          createdAt: json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
          updatedAt: json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
        );
      } else if (response.statusCode == 404) {
        print('Review not found');
        return null;
      } else {
        print('Failed to fetch review: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching review: $e');
      return null;
    }
  }

  // ========== UPDATE ==========
  /// Update an existing review
  Future<Review?> updateReview(Review review) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/reviews/${review.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(review.reviewMap),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Review(
          id: json['id'],
          userId: json['user_id'],
          productId: json['product_id'],
          orderId: json['order_id'],
          rating: json['rating'],
          title: json['title'],
          comment: json['comment'],
          isVerifiedPurchase: json['is_verified_purchase'] == 1,
          helpfulCount: json['helpful_count'] ?? 0,
          createdAt: json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
          updatedAt: json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
        );
      } else if (response.statusCode == 404) {
        print('Review not found');
        return null;
      } else {
        print('Failed to update review: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error updating review: $e');
      return null;
    }
  }

  // ========== DELETE ==========
  /// Delete a review
  Future<bool> deleteReview(int reviewId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/reviews/$reviewId'),
      );

      if (response.statusCode == 200) {
        print('Review deleted successfully');
        return true;
      } else if (response.statusCode == 404) {
        print('Review not found');
        return false;
      } else {
        print('Failed to delete review: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error deleting review: $e');
      return false;
    }
  }
}
