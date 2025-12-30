import 'package:flutter/material.dart';
import '../services/product_service.dart';
import '../database/product_operations.dart';
import 'products_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ProductService _productService = ProductService();
  List<String> categories = []; // Store categories from database
  RangeValues _priceRange = RangeValues(0, 1000);
  @override
  void initState() {
    super.initState();
    _loadCategories(); // Load categories from database
  }

  // Load categories with offline-first fallback
  Future<void> _loadCategories() async {
    try {
      // Try backend first
      final result = await _productService.fetchCategories();
      if (result.isNotEmpty) {
        setState(() {
          categories = result;
        });
        print('✅ Loaded ${result.length} categories from backend');
      } else {
        // Fallback to local database
        await _loadLocalCategories();
      }
    } catch (e) {
      print('Backend unavailable, using local categories: $e');
      // Fallback to local database
      await _loadLocalCategories();
    }
  }

  // Load categories from local SQLite database
  Future<void> _loadLocalCategories() async {
    try {
      final result = await loadCategories();
      setState(() {
        categories = result;
      });
      print('✅ Loaded ${result.length} categories from local database');
    } catch (e) {
      print('Error loading local categories: $e');
    }
  }

  Widget _buildCategoryCard(String category, int index) {
    bool isLastItem = (index == categories.length - 1);
    bool isOddTotal = (categories.length % 2 != 0);
    bool shouldSpanTwoColumns = isLastItem && isOddTotal;

    // Return different widgets based on shouldSpanTwoColumns
    if (shouldSpanTwoColumns) {
      // Return a Container that takes full width
      return SizedBox(
        width: double.infinity,
        child: GestureDetector(
          onTap: () {
            /* navigate */
          },
          child: Card(
            elevation: 6, // shadow depth
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16), // rounded corners
            ),
            color: Colors.blue[100], // background color
            child: Container(
              padding: EdgeInsets.all(20), // internal padding
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.category,
                      size: 40,
                      color: Colors.blue[800],
                    ), // optional icon
                    SizedBox(height: 8),
                    Text(
                      category.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      // Return normal card
      return GestureDetector(
        onTap: () {
          /* navigate */
        },
        child: Card(
          elevation: 4,
          child: Center(
            child: Text(
              category.toUpperCase(),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 40),
        Row(
          spacing: 10,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            Expanded(
              child: TextField(
                decoration: InputDecoration(hintText: 'Search...'),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                // Navigate to cart screen
              },
            ),
          ],
        ),
        SizedBox(height: 20),
        SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(width: 10),
                  Text(
                    "Search by Categories",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Expanded(
                // Takes remaining space
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: GridView.builder(
                    padding: EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      String category = categories[index];
                      bool isOddTotal = categories.length % 2 != 0;
                      bool isLastItem = index == categories.length - 1;
                      bool makeWide = isOddTotal && isLastItem;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductsScreen(category: category),
                            ),
                          );
                        },
                        child: Card(
                          elevation: makeWide
                              ? 6
                              : 4, // more shadow for wide card
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Container(
                            padding: EdgeInsets.all(makeWide ? 24 : 16),
                            decoration: BoxDecoration(
                              gradient: makeWide
                                  ? LinearGradient(
                                      colors: [
                                        Colors.blue[300]!,
                                        Colors.blue[600]!,
                                      ],
                                    )
                                  : null,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                category.toUpperCase(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: makeWide ? 22 : 18,
                                  fontWeight: FontWeight.bold,
                                  color: makeWide
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              Text(
                "Search by price",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              RangeSlider(
                values: _priceRange,
                min: 0,
                max: 2000,
                divisions: 40,
                labels: RangeLabels(
                  '\$${_priceRange.start.round()}',
                  '\$${_priceRange.end.round()}',
                ),
                onChanged: (RangeValues values) {
                  setState(() {
                    _priceRange = values;
                  });
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('\$${_priceRange.start.round()}'),
                  Text('\$${_priceRange.end.round()}'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
