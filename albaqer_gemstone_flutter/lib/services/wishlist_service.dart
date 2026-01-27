import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Wishlist Service - Manages user's favorite products
/// Stores wishlist locally using SharedPreferences
class WishlistService extends ChangeNotifier {
  List<int> _wishlistProductIds = [];

  List<int> get wishlistProductIds => _wishlistProductIds;

  bool isInWishlist(int productId) => _wishlistProductIds.contains(productId);

  int get count => _wishlistProductIds.length;

  WishlistService() {
    loadWishlist();
  }

  /// Load wishlist from local storage
  Future<void> loadWishlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wishlistJson = prefs.getString('wishlist');

      if (wishlistJson != null) {
        final List<dynamic> decoded = jsonDecode(wishlistJson);
        _wishlistProductIds = decoded.map((e) => e as int).toList();
        notifyListeners();
        print('✅ Loaded ${_wishlistProductIds.length} wishlist items');
      }
    } catch (e) {
      print('❌ Error loading wishlist: $e');
    }
  }

  /// Save wishlist to local storage
  Future<void> _saveWishlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wishlistJson = jsonEncode(_wishlistProductIds);
      await prefs.setString('wishlist', wishlistJson);
      print('✅ Saved wishlist: ${_wishlistProductIds.length} items');
    } catch (e) {
      print('❌ Error saving wishlist: $e');
    }
  }

  /// Add product to wishlist
  Future<void> addToWishlist(int productId) async {
    if (!_wishlistProductIds.contains(productId)) {
      _wishlistProductIds.add(productId);
      await _saveWishlist();
      notifyListeners();
    }
  }

  /// Remove product from wishlist
  Future<void> removeFromWishlist(int productId) async {
    if (_wishlistProductIds.contains(productId)) {
      _wishlistProductIds.remove(productId);
      await _saveWishlist();
      notifyListeners();
    }
  }

  /// Toggle product in wishlist
  Future<void> toggleWishlist(int productId) async {
    if (isInWishlist(productId)) {
      await removeFromWishlist(productId);
    } else {
      await addToWishlist(productId);
    }
  }

  /// Clear entire wishlist
  Future<void> clearWishlist() async {
    _wishlistProductIds.clear();
    await _saveWishlist();
    notifyListeners();
  }
}
