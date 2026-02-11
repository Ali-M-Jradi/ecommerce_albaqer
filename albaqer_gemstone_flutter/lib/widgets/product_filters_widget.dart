import 'package:flutter/material.dart';
import '../models/product_filters.dart';

class ProductFiltersWidget extends StatefulWidget {
  final ProductFilters currentFilters;
  final Function(ProductFilters) onApply;

  const ProductFiltersWidget({
    Key? key,
    required this.currentFilters,
    required this.onApply,
  }) : super(key: key);

  @override
  State<ProductFiltersWidget> createState() => _ProductFiltersWidgetState();
}

class _ProductFiltersWidgetState extends State<ProductFiltersWidget> {
  late ProductFilters _filters;

  // Price range values
  RangeValues _priceRange = const RangeValues(0, 5000);

  // Available options
  final List<String> _categories = [
    'ring',
    'necklace',
    'bracelet',
    'earrings',
    'prayer_beads',
  ];
  final List<String> _gemstones = [
    'agate',
    'ruby',
    'emerald',
    'turquoise',
    'sapphire',
    'diamond',
    'pearl',
  ];
  final List<String> _colors = [
    'red',
    'green',
    'blue',
    'black',
    'white',
    'brown',
    'yellow',
    'orange',
  ];
  final List<String> _metals = [
    'gold',
    'silver',
    'rose_gold',
    'platinum',
    'bronze',
  ];
  final List<String> _ringSizes = ['6', '7', '8', '9', '10', '11', '12'];
  final List<String> _necklaceSizes = ['14', '16', '18', '20', '24'];

  int? _selectedRating;

  @override
  void initState() {
    super.initState();
    _filters = widget.currentFilters.copyWith();

    // Initialize price range from current filters
    _priceRange = RangeValues(
      _filters.minPrice?.toDouble() ?? 0,
      _filters.maxPrice?.toDouble() ?? 5000,
    );

    // Initialize rating
    if (_filters.minRating != null) {
      _selectedRating = _filters.minRating!.toInt();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              _buildHeader(),

              const Divider(height: 1),

              // Filter content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildPriceFilter(),
                    const SizedBox(height: 24),

                    _buildCategoryFilter(),
                    const SizedBox(height: 24),

                    _buildGemstoneFilter(),
                    const SizedBox(height: 24),

                    _buildColorFilter(),
                    const SizedBox(height: 24),

                    _buildMetalFilter(),
                    const SizedBox(height: 24),

                    _buildStockFilter(),
                    const SizedBox(height: 24),

                    _buildRatingFilter(),
                    const SizedBox(height: 24),

                    _buildSizeFilter(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // Bottom buttons
              _buildBottomButtons(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.filter_list, size: 24),
          const SizedBox(width: 8),
          const Text(
            'Filters',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.attach_money, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Price Range',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Text(
              '\$${_priceRange.start.toInt()} - \$${_priceRange.end.toInt()}',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 8),
        RangeSlider(
          values: _priceRange,
          min: 0,
          max: 5000,
          divisions: 50,
          labels: RangeLabels(
            '\$${_priceRange.start.toInt()}',
            '\$${_priceRange.end.toInt()}',
          ),
          onChanged: (RangeValues values) {
            setState(() {
              _priceRange = values;
              _filters = _filters.copyWith(
                minPrice: values.start,
                maxPrice: values.end,
              );
            });
          },
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.category, size: 20),
            SizedBox(width: 8),
            Text(
              'Category',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories.map((category) {
            final isSelected = _filters.categories?.contains(category) ?? false;
            return FilterChip(
              label: Text(_formatLabel(category)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  List<String> newCategories = List.from(
                    _filters.categories ?? [],
                  );
                  if (selected) {
                    if (!newCategories.contains(category)) {
                      newCategories.add(category);
                    }
                  } else {
                    newCategories.remove(category);
                  }
                  _filters = _filters.copyWith(
                    categories: newCategories.isEmpty ? null : newCategories,
                  );
                });
              },
              selectedColor: Colors.amber.shade100,
              checkmarkColor: Colors.amber.shade900,
              labelStyle: TextStyle(
                color: isSelected ? Colors.black87 : Colors.black54,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGemstoneFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.diamond, size: 20),
            SizedBox(width: 8),
            Text(
              'Gemstone Type',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _gemstones.map((gemstone) {
            final isSelected =
                _filters.gemstoneTypes?.contains(gemstone) ?? false;
            return FilterChip(
              label: Text(_formatLabel(gemstone)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  List<String> newGemstones = List.from(
                    _filters.gemstoneTypes ?? [],
                  );
                  if (selected) {
                    if (!newGemstones.contains(gemstone)) {
                      newGemstones.add(gemstone);
                    }
                  } else {
                    newGemstones.remove(gemstone);
                  }
                  _filters = _filters.copyWith(
                    gemstoneTypes: newGemstones.isEmpty ? null : newGemstones,
                  );
                });
              },
              selectedColor: Colors.amber.shade100,
              checkmarkColor: Colors.amber.shade900,
              labelStyle: TextStyle(
                color: isSelected ? Colors.black87 : Colors.black54,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.palette, size: 20),
            SizedBox(width: 8),
            Text(
              'Color',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _colors.map((color) {
            final isSelected = _filters.colors?.contains(color) ?? false;
            return FilterChip(
              avatar: CircleAvatar(
                backgroundColor: _getColorFromName(color),
                radius: 10,
              ),
              label: Text(_formatLabel(color)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  List<String> newColors = List.from(_filters.colors ?? []);
                  if (selected) {
                    if (!newColors.contains(color)) {
                      newColors.add(color);
                    }
                  } else {
                    newColors.remove(color);
                  }
                  _filters = _filters.copyWith(
                    colors: newColors.isEmpty ? null : newColors,
                  );
                });
              },
              selectedColor: Colors.amber.shade100,
              checkmarkColor: Colors.amber.shade900,
              labelStyle: TextStyle(
                color: isSelected ? Colors.black87 : Colors.black54,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMetalFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.stars, size: 20),
            SizedBox(width: 8),
            Text(
              'Metal Type',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _metals.map((metal) {
            final isSelected = _filters.metalTypes?.contains(metal) ?? false;
            return FilterChip(
              label: Text(_formatLabel(metal)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  List<String> newMetals = List.from(_filters.metalTypes ?? []);
                  if (selected) {
                    if (!newMetals.contains(metal)) {
                      newMetals.add(metal);
                    }
                  } else {
                    newMetals.remove(metal);
                  }
                  _filters = _filters.copyWith(
                    metalTypes: newMetals.isEmpty ? null : newMetals,
                  );
                });
              },
              selectedColor: Colors.amber.shade100,
              checkmarkColor: Colors.amber.shade900,
              labelStyle: TextStyle(
                color: isSelected ? Colors.black87 : Colors.black54,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStockFilter() {
    return Row(
      children: [
        const Icon(Icons.inventory, size: 20),
        const SizedBox(width: 8),
        const Text(
          'In Stock Only',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        Switch(
          value: _filters.inStock ?? false,
          onChanged: (value) {
            setState(() {
              _filters = _filters.copyWith(inStock: value);
            });
          },
        ),
      ],
    );
  }

  Widget _buildRatingFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.star, size: 20),
            SizedBox(width: 8),
            Text(
              'Minimum Rating',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            RadioListTile<int?>(
              title: const Text('Any Rating'),
              value: null,
              groupValue: _selectedRating,
              onChanged: (value) {
                setState(() {
                  _selectedRating = value;
                  _filters = _filters.copyWith(minRating: value?.toDouble());
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
            RadioListTile<int>(
              title: Row(
                children: [
                  const Text('5 Stars'),
                  const SizedBox(width: 8),
                  ...List.generate(
                    5,
                    (index) =>
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                  ),
                ],
              ),
              value: 5,
              groupValue: _selectedRating,
              onChanged: (value) {
                setState(() {
                  _selectedRating = value;
                  _filters = _filters.copyWith(minRating: value?.toDouble());
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
            RadioListTile<int>(
              title: Row(
                children: [
                  const Text('4+ Stars'),
                  const SizedBox(width: 8),
                  ...List.generate(
                    4,
                    (index) =>
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                  ),
                ],
              ),
              value: 4,
              groupValue: _selectedRating,
              onChanged: (value) {
                setState(() {
                  _selectedRating = value;
                  _filters = _filters.copyWith(minRating: value?.toDouble());
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
            RadioListTile<int>(
              title: Row(
                children: [
                  const Text('3+ Stars'),
                  const SizedBox(width: 8),
                  ...List.generate(
                    3,
                    (index) =>
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                  ),
                ],
              ),
              value: 3,
              groupValue: _selectedRating,
              onChanged: (value) {
                setState(() {
                  _selectedRating = value;
                  _filters = _filters.copyWith(minRating: value?.toDouble());
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSizeFilter() {
    // Determine available sizes based on category
    List<String> availableSizes = [];
    String? selectedCategoryForSize;

    if (_filters.categories?.contains('ring') ?? false) {
      availableSizes = _ringSizes;
      selectedCategoryForSize = 'ring';
    } else if (_filters.categories?.any(
          (cat) => cat == 'necklace' || cat == 'bracelet',
        ) ??
        false) {
      availableSizes = _necklaceSizes;
      selectedCategoryForSize = _filters.categories?.firstWhere(
        (cat) => cat == 'necklace' || cat == 'bracelet',
        orElse: () => 'necklace',
      );
    }

    if (availableSizes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.straighten, size: 20),
            const SizedBox(width: 8),
            Text(
              'Size (${_formatLabel(selectedCategoryForSize ?? '')})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _filters.size,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Select size',
          ),
          items: [
            const DropdownMenuItem(value: null, child: Text('All Sizes')),
            ...availableSizes.map((size) {
              return DropdownMenuItem(value: size, child: Text(size));
            }),
          ],
          onChanged: (value) {
            setState(() {
              _filters = _filters.copyWith(size: value);
            });
          },
        ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _filters = ProductFilters();
                  _priceRange = const RangeValues(0, 5000);
                  _selectedRating = null;
                });
              },
              child: const Text('Clear All'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(_filters);
                Navigator.pop(context);
              },
              child: Text(
                'Apply${_filters.hasFilters ? ' (${_filters.activeFilterCount})' : ''}',
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatLabel(String text) {
    return text
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  Color _getColorFromName(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'brown':
        return Colors.brown;
      case 'yellow':
        return Colors.yellow;
      case 'orange':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
