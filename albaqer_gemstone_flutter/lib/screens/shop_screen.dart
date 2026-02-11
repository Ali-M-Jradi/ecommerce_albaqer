import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/data_manager.dart';
import '../services/wishlist_service.dart';
import '../services/cart_service.dart';
import 'product_detail_screen.dart';
import '../config/app_theme.dart';

/// Unified Shop Screen - Combines product browsing, search, and filters
/// Provides clean UX with persistent search and category filters
class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  // Controllers
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebouncer;

  // State
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  List<String> _categories = [];
  Set<String> _selectedCategories = {}; // Multi-select categories
  String _sortBy = 'name'; // name, price_low, price_high, newest
  bool _isLoading = true;
  bool _showFilters = false;
  bool _hasCheckedCacheOnResume =
      false; // Track if we've checked cache on resume

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if cache is stale when screen becomes visible (after navigation)
    if (_hasCheckedCacheOnResume) {
      _checkAndReloadIfCacheStale();
    }
    _hasCheckedCacheOnResume = true;
  }

  /// Check if product cache is stale and reload if needed
  Future<void> _checkAndReloadIfCacheStale() async {
    final dataManager = DataManager();
    // If cache is not fresh, reload products
    if (!dataManager.isCacheFresh() && !_isLoading) {
      print('🔄 Cache is stale, reloading products in shop screen...');
      await _loadData();
    }
  }

  @override
  void dispose() {
    _searchDebouncer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final dataManager = DataManager();

      // Load products and categories in parallel
      final results = await Future.wait([
        dataManager.getProducts(), // Will auto-refresh if cache is stale
        dataManager.getCategoriesOfflineFirst(),
      ]);

      setState(() {
        _allProducts = results[0] as List<Product>;
        _filteredProducts = List.from(_allProducts);
        _categories = results[1] as List<String>;
        _isLoading = false;
      });

      _applySorting();
    } catch (e) {
      print('❌ Error loading shop data: $e');
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load products'),
            backgroundColor: AppColors.error,
            action: SnackBarAction(
              label: 'Retry',
              textColor: AppColors.textOnPrimary,
              onPressed: _loadData,
            ),
          ),
        );
      }
    }
  }

  void _onSearchChanged() {
    _searchDebouncer?.cancel();
    _searchDebouncer = Timer(const Duration(milliseconds: 300), () {
      _applyFilters();
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredProducts = _allProducts.where((product) {
        // Multi-category filter - match ANY selected category
        if (_selectedCategories.isNotEmpty) {
          bool matchesCategory = _selectedCategories.any(
            (category) => product.type.toLowerCase() == category.toLowerCase(),
          );
          if (!matchesCategory) return false;
        }

        // Search filter
        final query = _searchController.text.toLowerCase();
        if (query.isNotEmpty) {
          return product.name.toLowerCase().contains(query) ||
              (product.description?.toLowerCase().contains(query) ?? false);
        }

        return true;
      }).toList();
    });

    _applySorting();
  }

  void _applySorting() {
    setState(() {
      switch (_sortBy) {
        case 'price_low':
          _filteredProducts.sort((a, b) => a.basePrice.compareTo(b.basePrice));
          break;
        case 'price_high':
          _filteredProducts.sort((a, b) => b.basePrice.compareTo(a.basePrice));
          break;
        case 'newest':
          _filteredProducts.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
          break;
        case 'name':
        default:
          _filteredProducts.sort((a, b) => a.name.compareTo(b.name));
      }
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedCategories.clear();
      _searchController.clear();
      _sortBy = 'name';
      _filteredProducts = List.from(_allProducts);
    });
    _applySorting();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(),

          // Filter Chips
          if (_categories.isNotEmpty) _buildFilterSection(),

          // Products Grid
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredProducts.isEmpty
                ? _buildEmptyState()
                : _buildProductsGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.background,
      child: Column(
        children: [
          // Search TextField
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search gemstones, rings, necklaces...',
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.textSecondary,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _applyFilters();
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Sort & Filter Row
          Row(
            children: [
              // Sort Dropdown
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _sortBy,
                      icon: const Icon(Icons.sort, size: 20),
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(
                          value: 'name',
                          child: Text('Sort: A-Z'),
                        ),
                        DropdownMenuItem(
                          value: 'price_low',
                          child: Text('Sort: Price Low-High'),
                        ),
                        DropdownMenuItem(
                          value: 'price_high',
                          child: Text('Sort: Price High-Low'),
                        ),
                        DropdownMenuItem(
                          value: 'newest',
                          child: Text('Sort: Newest'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _sortBy = value);
                          _applySorting();
                        }
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Filter Toggle Button
              Container(
                decoration: BoxDecoration(
                  color: _showFilters ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.filter_list,
                    color: _showFilters
                        ? AppColors.textOnPrimary
                        : AppColors.primary,
                  ),
                  onPressed: () {
                    setState(() => _showFilters = !_showFilters);
                  },
                ),
              ),

              // Results count
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  '${_filteredProducts.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    if (!_showFilters) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'Categories',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  if (_selectedCategories.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${_selectedCategories.length}',
                          style: const TextStyle(
                            color: AppColors.textOnPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              if (_selectedCategories.isNotEmpty ||
                  _searchController.text.isNotEmpty)
                TextButton.icon(
                  icon: const Icon(Icons.clear_all, size: 16),
                  label: const Text('Clear'),
                  onPressed: _clearFilters,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8),

          // Category Chips (Multi-select)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories.map((category) {
              final isSelected = _selectedCategories.contains(category);
              return FilterChip(
                label: Text(
                  category.toUpperCase(),
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.textOnPrimary
                        : AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedCategories.add(category);
                    } else {
                      _selectedCategories.remove(category);
                    }
                  });
                  _applyFilters();
                },
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.background,
                checkmarkColor: AppColors.textOnPrimary,
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsGrid() {
    return Consumer<CartService>(
      builder: (context, cartService, child) {
        return RefreshIndicator(
          onRefresh: _loadData,
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _filteredProducts.length,
            itemBuilder: (context, index) {
              final product = _filteredProducts[index];
              return _buildProductCard(product, cartService);
            },
          ),
        );
      },
    );
  }

  Widget _buildProductCard(Product product, CartService cartService) {
    final availableStock = cartService.getAvailableStock(product);
    final quantityInCart = cartService.getProductQuantity(product.id ?? 0);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          product.fullImageUrl != null
                              ? Image.network(
                                  product.fullImageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Icon(
                                        Icons.diamond,
                                        size: 40,
                                        color: AppColors.textSecondary,
                                      ),
                                    );
                                  },
                                )
                              : const Center(
                                  child: Icon(
                                    Icons.diamond,
                                    size: 40,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                          // Out of stock overlay
                          if (availableStock == 0)
                            Container(
                              color: AppColors.primary.withOpacity(0.6),
                              child: Center(
                                child: Text(
                                  quantityInCart > 0
                                      ? 'ALL IN\nCART'
                                      : 'OUT OF\nSTOCK',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.textOnPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Product Info
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          product.type.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accent,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Product Name
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      // Price
                      Text(
                        '\$${product.basePrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Stock Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: availableStock == 0
                              ? AppColors.stockLow
                              : availableStock <= 5
                              ? AppColors.stockMedium
                              : AppColors.stockHigh,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: availableStock == 0
                                ? AppColors.stockLowText
                                : availableStock <= 5
                                ? AppColors.stockMediumText
                                : AppColors.stockHighText,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              availableStock == 0
                                  ? Icons.cancel
                                  : availableStock <= 5
                                  ? Icons.warning_amber_rounded
                                  : Icons.check_circle,
                              size: 12,
                              color: availableStock == 0
                                  ? AppColors.stockLowText
                                  : availableStock <= 5
                                  ? AppColors.stockMediumText
                                  : AppColors.stockHighText,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                availableStock == 0
                                    ? (quantityInCart > 0
                                          ? 'All in cart'
                                          : 'Out of Stock')
                                    : availableStock <= 5
                                    ? 'Only $availableStock left'
                                    : '$availableStock available',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: availableStock == 0
                                      ? AppColors.stockLowText
                                      : availableStock <= 5
                                      ? AppColors.stockMediumText
                                      : AppColors.stockHighText,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Wishlist Heart Icon
            Positioned(
              top: 8,
              right: 8,
              child: Consumer<WishlistService>(
                builder: (context, wishlistService, child) {
                  if (product.id == null) return const SizedBox.shrink();

                  final isInWishlist = wishlistService.isInWishlist(
                    product.id!,
                  );
                  return GestureDetector(
                    onTap: () async {
                      await wishlistService.toggleWishlist(product.id!);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isInWishlist
                                  ? 'Removed from wishlist'
                                  : 'Added to wishlist',
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        isInWishlist ? Icons.favorite : Icons.favorite_border,
                        color: isInWishlist
                            ? AppColors.favorite
                            : AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchController.text.isNotEmpty
                  ? Icons.search_off
                  : Icons.shopping_bag_outlined,
              size: 80,
              color: AppColors.textLight,
            ),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isNotEmpty
                  ? 'No products found'
                  : 'No products available',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isNotEmpty
                  ? 'Try different keywords or filters'
                  : 'Check back later for new arrivals',
              style: const TextStyle(fontSize: 14, color: AppColors.textLight),
              textAlign: TextAlign.center,
            ),
            if (_selectedCategories.isNotEmpty ||
                _searchController.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: ElevatedButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear Filters'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
