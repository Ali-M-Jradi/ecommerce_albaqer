import 'package:flutter/material.dart';
import '../services/product_service.dart';
import 'products_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ProductService _productService = ProductService();
  List<String> categories = []; // Store categories from database

  @override
  void initState() {
    super.initState();
    _loadCategories(); // Load categories from database
  }

  // Load categories from database
  Future<void> _loadCategories() async {
    try {
      final result = await _productService.fetchCategories();
      setState(() {
        categories = result;
      });
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      spacing: 20,
      children: [
        SizedBox(height: 20),
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
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 10,
            children: [
              SizedBox(width: 2),
              // Dynamically build category buttons from database
              ...categories.map(
                (category) => GestureDetector(
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
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        category.toUpperCase(),
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 2),
            ],
          ),
        ),
      ],
    );
  }
}
