import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../services/data_manager.dart';
import 'product_detail_screen.dart';

/// =======================================================================
/// ADMIN PRODUCTS SCREEN - Simple Product Management
/// =======================================================================
/// Allows admin users to:
/// - View all products
/// - Add new products
/// - Delete products

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  List<Product> products = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  /// Load all products from backend/database
  Future<void> _loadProducts() async {
    setState(() => isLoading = true);

    try {
      final dataManager = DataManager();
      // Force refresh from backend to get latest data
      final result = await dataManager.getProducts(
        source: DataSource.backend,
        forceRefresh: true,
      );

      setState(() {
        products = result;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading products: $e');
      setState(() => isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading products: $e')));
      }
    }
  }

  /// Delete a product
  Future<void> _deleteProduct(Product product) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Product?'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // 1. Delete from backend
      final productService = ProductService();
      final deleted = await productService.deleteProduct(product.id!);

      if (!deleted) {
        throw Exception('Failed to delete from backend');
      }

      // 2. Reload products from backend to ensure consistency
      await _loadProducts();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.name} deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting product: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Show add product dialog
  void _showAddProductDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProductScreen(onProductAdded: _loadProducts),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Products'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : products.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No products yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _showAddProductDialog,
                    icon: Icon(Icons.add),
                    label: Text('Add First Product'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadProducts,
              child: ListView.builder(
                padding: EdgeInsets.all(8),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductDetailScreen(product: product),
                          ),
                        );
                      },
                      leading: product.imageUrl != null
                          ? Image.network(
                              product.imageUrl!,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.image, size: 50),
                            )
                          : Icon(Icons.image, size: 50),
                      title: Text(
                        product.name,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product.type),
                          Text(
                            '\$${product.basePrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Stock: ${product.quantityInStock}',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteProduct(product),
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProductDialog,
        backgroundColor: Colors.black,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

/// =======================================================================
/// ADD PRODUCT SCREEN - Simple Form to Add New Product
/// =======================================================================
class AddProductScreen extends StatefulWidget {
  final VoidCallback onProductAdded;

  const AddProductScreen({super.key, required this.onProductAdded});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  // Basic form fields
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();
  final descriptionController = TextEditingController();
  final imageUrlController = TextEditingController();

  // Metal specification fields
  final metalTypeController = TextEditingController();
  final metalColorController = TextEditingController();
  final metalPurityController = TextEditingController();
  final metalWeightController = TextEditingController();

  // Stone specification fields
  final stoneTypeController = TextEditingController();
  final stoneColorController = TextEditingController();
  final stoneCaratController = TextEditingController();
  final stoneCutController = TextEditingController();
  final stoneClarityController = TextEditingController();

  String selectedType = 'ring';
  final List<String> productTypes = [
    'ring',
    'necklace',
    'bracelet',
    'earring',
    'pendant',
    'other',
  ];

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    stockController.dispose();
    descriptionController.dispose();
    imageUrlController.dispose();
    metalTypeController.dispose();
    metalColorController.dispose();
    metalPurityController.dispose();
    metalWeightController.dispose();
    stoneTypeController.dispose();
    stoneColorController.dispose();
    stoneCaratController.dispose();
    stoneCutController.dispose();
    stoneClarityController.dispose();
    super.dispose();
  }

  /// Submit form and add product
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final productService = ProductService();

      // Create product data (only include fields with values)
      final productData = <String, dynamic>{
        'name': nameController.text.trim(),
        'type': selectedType.toLowerCase(),
        'base_price': double.parse(priceController.text),
        'quantity_in_stock': int.parse(stockController.text),
      };

      // Add optional fields only if they have values
      if (descriptionController.text.trim().isNotEmpty) {
        productData['description'] = descriptionController.text.trim();
      }
      if (imageUrlController.text.trim().isNotEmpty) {
        productData['image_url'] = imageUrlController.text.trim();
      }

      // Metal specifications
      if (metalTypeController.text.trim().isNotEmpty) {
        productData['metal_type'] = metalTypeController.text.trim();
      }
      if (metalColorController.text.trim().isNotEmpty) {
        productData['metal_color'] = metalColorController.text.trim();
      }
      if (metalPurityController.text.trim().isNotEmpty) {
        productData['metal_purity'] = metalPurityController.text.trim();
      }
      if (metalWeightController.text.trim().isNotEmpty) {
        final weight = double.tryParse(metalWeightController.text);
        if (weight != null) {
          productData['metal_weight_grams'] = weight;
        }
      }

      // Stone specifications
      if (stoneTypeController.text.trim().isNotEmpty) {
        productData['stone_type'] = stoneTypeController.text.trim();
      }
      if (stoneColorController.text.trim().isNotEmpty) {
        productData['stone_color'] = stoneColorController.text.trim();
      }
      if (stoneCaratController.text.trim().isNotEmpty) {
        final carat = double.tryParse(stoneCaratController.text);
        if (carat != null) {
          productData['stone_carat'] = carat;
        }
      }
      if (stoneCutController.text.trim().isNotEmpty) {
        productData['stone_cut'] = stoneCutController.text.trim();
      }
      if (stoneClarityController.text.trim().isNotEmpty) {
        productData['stone_clarity'] = stoneClarityController.text.trim();
      }

      final newProduct = await productService.createProduct(productData);

      setState(() => isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${newProduct.name} added successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Reload products list and close dialog
        widget.onProductAdded();
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding product: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Product'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Name
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Product Name *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shopping_bag),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter product name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Product Type (Dropdown)
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: InputDecoration(
                  labelText: 'Product Type *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: productTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type[0].toUpperCase() + type.substring(1)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => selectedType = value!);
                },
              ),
              SizedBox(height: 16),

              // Price
              TextFormField(
                controller: priceController,
                decoration: InputDecoration(
                  labelText: 'Price *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter valid price';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Stock Quantity
              TextFormField(
                controller: stockController,
                decoration: InputDecoration(
                  labelText: 'Stock Quantity *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter stock quantity';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Description
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),

              // Image URL
              TextFormField(
                controller: imageUrlController,
                decoration: InputDecoration(
                  labelText: 'Image URL (optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.image),
                  hintText: 'https://example.com/image.jpg',
                ),
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final urlPattern = RegExp(
                      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
                    );
                    if (!urlPattern.hasMatch(value.trim())) {
                      return 'Please enter a valid URL (starting with http:// or https://)';
                    }
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),

              // Metal Specifications Section
              Text(
                'Metal Specifications (Optional)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: metalTypeController,
                decoration: InputDecoration(
                  labelText: 'Metal Type',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Gold, Silver, Platinum',
                ),
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: metalColorController,
                decoration: InputDecoration(
                  labelText: 'Metal Color',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Yellow, White, Rose',
                ),
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: metalPurityController,
                decoration: InputDecoration(
                  labelText: 'Metal Purity',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., 18K, 22K, 925',
                ),
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: metalWeightController,
                decoration: InputDecoration(
                  labelText: 'Metal Weight (grams)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              SizedBox(height: 24),

              // Stone Specifications Section
              Text(
                'Stone Specifications (Optional)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: stoneTypeController,
                decoration: InputDecoration(
                  labelText: 'Stone Type',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Ruby, Emerald, Diamond',
                ),
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: stoneColorController,
                decoration: InputDecoration(
                  labelText: 'Stone Color',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Red, Green, Blue',
                ),
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: stoneCaratController,
                decoration: InputDecoration(
                  labelText: 'Stone Carat',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: stoneCutController,
                decoration: InputDecoration(
                  labelText: 'Stone Cut',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Round, Princess, Emerald',
                ),
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: stoneClarityController,
                decoration: InputDecoration(
                  labelText: 'Stone Clarity',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., VVS1, VS1, SI1',
                ),
              ),
              SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                child: isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Add Product',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
