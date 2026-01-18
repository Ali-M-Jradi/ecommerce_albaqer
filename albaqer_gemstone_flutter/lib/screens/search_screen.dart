import 'dart:async';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/data_manager.dart';
import 'product_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;

  const SearchScreen({super.key, this.onBackPressed});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // Services & Controllers
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // State Variables
  List<String> categories = [];
  List<Product> _searchResults = [];
  String? _selectedCategory;
  RangeValues _priceRange = RangeValues(0, 4000);
  bool _isSearching = false;
  bool _categoriesLoaded = false;

  // Debounce Timers
  Timer? _priceDebouncer;
  Timer? _textSearchDebouncer;

  // Computed Properties
  bool get _hasActiveFilters =>
      _selectedCategory != null ||
      _priceRange.start > 0 ||
      _priceRange.end < 4000 ||
      _searchController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _loadCategoriesOfflineFirst(); // Load local first for instant display

    // Debounced text search listener
    _searchController.addListener(() {
      _textSearchDebouncer?.cancel();
      _textSearchDebouncer = Timer(Duration(milliseconds: 500), () {
        if (_searchController.text.isNotEmpty) {
          _applyFilters();
        }
      });
    });
  }

  @override
  void dispose() {
    _priceDebouncer?.cancel();
    _textSearchDebouncer?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════
  // CATEGORY LOADING - OFFLINE-FIRST APPROACH
  // ═══════════════════════════════════════════════════════════

  /// Load categories with offline-first strategy for instant display
  Future<void> _loadCategoriesOfflineFirst() async {
    try {
      final dataManager = DataManager();
      final result = await dataManager.getCategoriesOfflineFirst();

      if (mounted) {
        setState(() {
          categories = result;
          _categoriesLoaded = true;
        });
        print('✅ Categories loaded via DataManager: ${result.length}');
      }
    } catch (e) {
      print('❌ Failed to load categories: $e');
      if (mounted) {
        setState(() {
          categories = ['ring', 'necklace', 'bracelet', 'earring'];
          _categoriesLoaded = true;
        });
      }
      // Fallback to hardcoded categories
      setState(() {
        categories = ['ring', 'necklace', 'bracelet', 'earring'];
      });
    }
  }

  // ═══════════════════════════════════════════════════════════
  // FILTERING LOGIC
  // ═══════════════════════════════════════════════════════════

  Future<void> _applyFilters() async {
    setState(() => _isSearching = true);

    try {
      final dataManager = DataManager();
      List<Product> results;

      // Step 1: Get products by category or all
      if (_selectedCategory != null) {
        results = await dataManager.getProductsByCategory(_selectedCategory!);
      } else {
        results = await dataManager.getProducts();
      }

      // Step 2: Apply price filter
      results = results.where((product) {
        return product.basePrice >= _priceRange.start &&
            product.basePrice <= _priceRange.end;
      }).toList();

      // Step 3: Apply text search if exists
      if (_searchController.text.isNotEmpty) {
        final query = _searchController.text.toLowerCase();
        results = results.where((product) {
          return product.name.toLowerCase().contains(query) ||
              (product.description?.toLowerCase().contains(query) ?? false);
        }).toList();
      }

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });

      // Auto-scroll to show results
      if (_searchResults.isNotEmpty && _scrollController.hasClients) {
        await Future.delayed(Duration(milliseconds: 100));
        _scrollController.animateTo(
          400,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      print('Filter error: $e');
      setState(() => _isSearching = false);
    }
  }

  void _clearAllFilters() {
    setState(() {
      _selectedCategory = null;
      _priceRange = RangeValues(0, 4000);
      _searchController.clear();
      _searchResults = [];
    });
  }

  void _onCategoryTap(String category) {
    setState(() {
      if (_selectedCategory == category) {
        _selectedCategory = null; // Deselect if already selected
      } else {
        _selectedCategory = category; // Select new category
      }
    });
    _applyFilters();
  }

  void _onPriceChanged(RangeValues values) {
    setState(() => _priceRange = values);

    // Debounce: Apply filters after user stops moving slider
    _priceDebouncer?.cancel();
    _priceDebouncer = Timer(Duration(milliseconds: 300), () {
      _applyFilters();
    });
  }

  // ═══════════════════════════════════════════════════════════
  // UI BUILDERS
  // ═══════════════════════════════════════════════════════════

  Widget _buildActiveFiltersBar() {
    if (!_hasActiveFilters) return SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.filter_alt, size: 16, color: Colors.amber[700]),
                  SizedBox(width: 8),
                  Text(
                    'Active Filters',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[900],
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: _clearAllFilters,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.amber[700],
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size(0, 30),
                ),
                child: Text(
                  'Clear All',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (_selectedCategory != null)
                Chip(
                  label: Text(_selectedCategory!),
                  onDeleted: () {
                    setState(() => _selectedCategory = null);
                    _applyFilters();
                  },
                  deleteIcon: Icon(Icons.close, size: 16),
                  backgroundColor: Colors.amber[100],
                  side: BorderSide(color: Colors.amber[300]!),
                ),
              if (_priceRange.start > 0 || _priceRange.end < 4000)
                Chip(
                  label: Text(
                    '\$${_priceRange.start.round()}-\$${_priceRange.end.round()}',
                  ),
                  onDeleted: () {
                    setState(() => _priceRange = RangeValues(0, 4000));
                    _applyFilters();
                  },
                  deleteIcon: Icon(Icons.close, size: 16),
                  backgroundColor: Colors.amber[100],
                  side: BorderSide(color: Colors.amber[300]!),
                ),
              if (_searchController.text.isNotEmpty)
                Chip(
                  label: Text('"${_searchController.text}"'),
                  onDeleted: () {
                    _searchController.clear();
                    _applyFilters();
                  },
                  deleteIcon: Icon(Icons.close, size: 16),
                  backgroundColor: Colors.amber[100],
                  side: BorderSide(color: Colors.amber[300]!),
                ),
            ],
          ),
          if (_searchResults.isNotEmpty && !_isSearching)
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                '${_searchResults.length} ${_searchResults.length == 1 ? 'product' : 'products'} found',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String category, int index) {
    final isSelected = _selectedCategory == category;
    final isOddTotal = categories.length % 2 != 0;
    final isLastItem = index == categories.length - 1;
    final makeWide = isOddTotal && isLastItem;

    return GestureDetector(
      onTap: () => _onCategoryTap(category),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.amber : Colors.transparent,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Card(
          elevation: isSelected ? 8 : (makeWide ? 6 : 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: EdgeInsets.all(makeWide ? 24 : 16),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [Colors.amber[400]!, Colors.amber[700]!],
                    )
                  : (makeWide
                        ? LinearGradient(
                            colors: [Colors.amber[300]!, Colors.amber[600]!],
                          )
                        : null),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isSelected || makeWide)
                    Icon(
                      Icons.category,
                      size: makeWide ? 40 : 30,
                      color: Colors.white,
                    ),
                  if (isSelected || makeWide) SizedBox(height: 8),
                  Text(
                    category.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: makeWide ? 22 : 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : (makeWide ? Colors.white : Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.diamond,
                                size: 50,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.diamond,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '\$${product.basePrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        if (product.rating > 0)
                          Row(
                            children: [
                              Icon(Icons.star, size: 12, color: Colors.amber),
                              SizedBox(width: 2),
                              Text(
                                '${product.rating.toStringAsFixed(1)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
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
        padding: EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'No products found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try adjusting your filters',
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _clearAllFilters,
              icon: Icon(Icons.clear_all),
              label: Text('Clear All Filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                elevation: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (!_hasActiveFilters || _searchResults.isEmpty && !_isSearching) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'Search Results',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
        SizedBox(height: 10),

        if (_isSearching)
          Padding(
            padding: EdgeInsets.all(48),
            child: Center(
              child: CircularProgressIndicator(color: Colors.amber),
            ),
          )
        else if (_searchResults.isEmpty)
          _buildEmptyState()
        else
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.65,
            ),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              return _buildProductCard(_searchResults[index]);
            },
          ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // MAIN BUILD
  // ═══════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Fixed header section
        SizedBox(height: 40),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: widget.onBackPressed ?? () => Navigator.pop(context),
              ),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: Icon(Icons.search, color: Colors.amber),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.amber),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchResults = []);
                            },
                          )
                        : null,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(color: Colors.amber, width: 2),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  onSubmitted: (_) => _applyFilters(),
                ),
              ),
              SizedBox(width: 10),
              IconButton(
                icon: Icon(Icons.shopping_cart, color: Colors.amber),
                onPressed: () {
                  // Navigate to cart screen
                },
              ),
            ],
          ),
        ),

        // Active filters bar
        _buildActiveFiltersBar(),

        // Scrollable content section
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),

                // Categories section
             

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.all(8),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      return _buildCategoryCard(categories[index], index);
                    },
                  ),
                ),

                SizedBox(height: 30),

                // Price range section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    "Price Range",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 4000,
                    divisions: 80,
                    activeColor: Colors.amber,
                    inactiveColor: Colors.amber[100],
                    labels: RangeLabels(
                      '\$${_priceRange.start.round()}',
                      '\$${_priceRange.end.round()}',
                    ),
                    onChanged: _onPriceChanged,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 26),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${_priceRange.start.round()}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '\$${_priceRange.end.round()}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                // Search results section
                _buildSearchResults(),

                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
