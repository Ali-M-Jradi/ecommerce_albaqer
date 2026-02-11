/// Product Filters Model - Holds all filter parameters for product search
class ProductFilters {
  // Price range
  double? minPrice;
  double? maxPrice;

  // Category filters (supports multiple)
  List<String>? categories; // ring, necklace, bracelet, earrings, prayer_beads

  // Gemstone filters (supports multiple)
  List<String>? gemstoneTypes; // agate, ruby, emerald, turquoise, etc.

  // Style filters (supports multiple)
  List<String>? colors; // red, green, blue, black, etc.
  List<String>? metalTypes; // gold, silver, rose_gold, etc.

  // Availability
  bool? inStock;

  // Rating
  double? minRating;

  // Size
  String? size;

  //  Search query
  String? search;

  // Sort options
  String sortBy; // created_at, base_price, average_rating, name
  String sortOrder; // ASC, DESC

  ProductFilters({
    this.minPrice,
    this.maxPrice,
    this.categories,
    this.gemstoneTypes,
    this.colors,
    this.metalTypes,
    this.inStock,
    this.minRating,
    this.size,
    this.search,
    this.sortBy = 'created_at',
    this.sortOrder = 'DESC',
  });

  /// Convert to query parameters for API request
  Map<String, String> toQueryParams() {
    final Map<String, String> params = {};

    if (minPrice != null) params['minPrice'] = minPrice.toString();
    if (maxPrice != null) params['maxPrice'] = maxPrice.toString();
    if (categories != null && categories!.isNotEmpty)
      params['category'] = categories!.join(',');
    if (gemstoneTypes != null && gemstoneTypes!.isNotEmpty)
      params['gemstoneType'] = gemstoneTypes!.join(',');
    if (colors != null && colors!.isNotEmpty)
      params['color'] = colors!.join(',');
    if (metalTypes != null && metalTypes!.isNotEmpty)
      params['metalType'] = metalTypes!.join(',');
    if (inStock != null) params['inStock'] = inStock.toString();
    if (minRating != null) params['minRating'] = minRating.toString();
    if (size != null) params['size'] = size!;
    if (search != null && search!.isNotEmpty) params['search'] = search!;

    params['sortBy'] = sortBy;
    params['sortOrder'] = sortOrder;

    return params;
  }

  /// Check if any filters are applied
  bool get hasFilters {
    return minPrice != null ||
        maxPrice != null ||
        (categories != null && categories!.isNotEmpty) ||
        (gemstoneTypes != null && gemstoneTypes!.isNotEmpty) ||
        (colors != null && colors!.isNotEmpty) ||
        (metalTypes != null && metalTypes!.isNotEmpty) ||
        inStock != null ||
        minRating != null ||
        size != null ||
        (search != null && search!.isNotEmpty);
  }

  /// Get count of active filters
  int get activeFilterCount {
    int count = 0;
    if (minPrice != null || maxPrice != null) count++;
    if (categories != null && categories!.isNotEmpty)
      count += categories!.length;
    if (gemstoneTypes != null && gemstoneTypes!.isNotEmpty)
      count += gemstoneTypes!.length;
    if (colors != null && colors!.isNotEmpty) count += colors!.length;
    if (metalTypes != null && metalTypes!.isNotEmpty)
      count += metalTypes!.length;
    if (inStock == true) count++;
    if (minRating != null) count++;
    if (size != null) count++;
    return count;
  }

  /// Clear all filters
  void clear() {
    minPrice = null;
    maxPrice = null;
    categories = null;
    gemstoneTypes = null;
    colors = null;
    metalTypes = null;
    inStock = null;
    minRating = null;
    size = null;
    search = null;
    sortBy = 'created_at';
    sortOrder = 'DESC';
  }

  /// Create a copy with modified fields
  /// To explicitly set a field to null, pass the special value
  ProductFilters copyWith({
    Object? minPrice = _undefined,
    Object? maxPrice = _undefined,
    Object? categories = _undefined,
    Object? gemstoneTypes = _undefined,
    Object? colors = _undefined,
    Object? metalTypes = _undefined,
    Object? inStock = _undefined,
    Object? minRating = _undefined,
    Object? size = _undefined,
    Object? search = _undefined,
    Object? sortBy = _undefined,
    Object? sortOrder = _undefined,
  }) {
    return ProductFilters(
      minPrice: minPrice == _undefined ? this.minPrice : minPrice as double?,
      maxPrice: maxPrice == _undefined ? this.maxPrice : maxPrice as double?,
      categories: categories == _undefined
          ? this.categories
          : categories as List<String>?,
      gemstoneTypes: gemstoneTypes == _undefined
          ? this.gemstoneTypes
          : gemstoneTypes as List<String>?,
      colors: colors == _undefined ? this.colors : colors as List<String>?,
      metalTypes: metalTypes == _undefined
          ? this.metalTypes
          : metalTypes as List<String>?,
      inStock: inStock == _undefined ? this.inStock : inStock as bool?,
      minRating: minRating == _undefined
          ? this.minRating
          : minRating as double?,
      size: size == _undefined ? this.size : size as String?,
      search: search == _undefined ? this.search : search as String?,
      sortBy: sortBy == _undefined
          ? this.sortBy
          : sortBy as String? ?? 'created_at',
      sortOrder: sortOrder == _undefined
          ? this.sortOrder
          : sortOrder as String? ?? 'DESC',
    );
  }
}

// Sentinel value for copyWith
const _undefined = Object();
