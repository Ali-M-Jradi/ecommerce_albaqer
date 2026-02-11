import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/cart_service.dart';
import 'cart_screen.dart';
import '../config/app_theme.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;

  void _incrementQuantity(int availableStock) {
    if (quantity < availableStock) {
      setState(() {
        quantity++;
      });
    }
  }

  void _decrementQuantity() {
    if (quantity > 1) {
      setState(() {
        quantity--;
      });
    }
  }

  Future<void> _addToCart() async {
    // Get the cart service from Provider
    final cartService = Provider.of<CartService>(context, listen: false);
    final availableStock = cartService.getAvailableStock(widget.product);

    // Validate stock before adding to cart
    if (availableStock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${widget.product.name} is currently out of stock or all items are in your cart',
          ),
          duration: Duration(seconds: 2),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (quantity > availableStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Only $availableStock items available (${cartService.getProductQuantity(widget.product.id ?? 0)} already in cart)',
          ),
          duration: Duration(seconds: 2),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // Add product to cart with selected quantity
    final success = await cartService.addToCart(
      product: widget.product,
      quantity: quantity,
    );

    // Show feedback to user
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added ${widget.product.name} (x$quantity) to cart'),
            duration: Duration(seconds: 2),
            backgroundColor: AppColors.success,
            action: SnackBarAction(
              label: 'VIEW CART',
              textColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartScreen()),
                );
              },
            ),
          ),
        );
        // Reset quantity after successful add
        setState(() {
          quantity = 1;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not add to cart. Check stock availability.'),
            duration: Duration(seconds: 2),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartService = Provider.of<CartService>(context);
    final availableStock = cartService.getAvailableStock(widget.product);
    final quantityInCart = cartService.getProductQuantity(
      widget.product.id ?? 0,
    );

    return Scaffold(
      appBar: AppBar(title: Text('Product Details')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              height: 300,
              width: double.infinity,
              color: AppColors.surface,
              child: widget.product.fullImageUrl != null
                  ? Image.network(
                      widget.product.fullImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print('Image load error: $error');
                        return Center(
                          child: Icon(
                            Icons.diamond,
                            size: 100,
                            color: AppColors.textSecondary,
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Icon(
                        Icons.diamond,
                        size: 100,
                        color: AppColors.textSecondary,
                      ),
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    widget.product.name,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),

                  // Type/Category
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue[100] ?? Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.product.type.toUpperCase(),
                      style: TextStyle(
                        color: Colors.blue[900] ?? Colors.blue.shade900,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Rating and Reviews
                  Row(
                    children: [
                      Icon(Icons.star, color: AppColors.rating, size: 24),
                      SizedBox(width: 4),
                      Text(
                        widget.product.rating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '(${widget.product.totalReviews} reviews)',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Price
                  Text(
                    '\$${widget.product.basePrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                  SizedBox(height: 8),

                  // Stock Status
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            availableStock > 0
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: availableStock > 0
                                ? AppColors.success
                                : AppColors.error,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            availableStock > 0
                                ? 'Available: $availableStock'
                                : 'Out of Stock',
                            style: TextStyle(
                              fontSize: 14,
                              color: availableStock > 0
                                  ? AppColors.success
                                  : AppColors.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      if (quantityInCart > 0)
                        Padding(
                          padding: const EdgeInsets.only(left: 28, top: 4),
                          child: Text(
                            '$quantityInCart in your cart',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Divider
                  Divider(),
                  SizedBox(height: 16),

                  // Description
                  Text(
                    'Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.product.description != null &&
                            widget.product.description!.isNotEmpty
                        ? widget.product.description!
                        : 'No description available',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 24),

                  // Divider
                  Divider(),
                  SizedBox(height: 16),

                  // Specifications Section
                  if (_hasSpecifications())
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Specifications',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),

                        // Metal Specifications
                        if (widget.product.metalType != null ||
                            widget.product.metalColor != null ||
                            widget.product.metalPurity != null ||
                            widget.product.metalWeightGrams != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Metal Details',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.secondary,
                                ),
                              ),
                              SizedBox(height: 8),
                              if (widget.product.metalType != null)
                                _buildSpecRow(
                                  'Type',
                                  widget.product.metalType!,
                                ),
                              if (widget.product.metalColor != null)
                                _buildSpecRow(
                                  'Color',
                                  widget.product.metalColor!,
                                ),
                              if (widget.product.metalPurity != null)
                                _buildSpecRow(
                                  'Purity',
                                  widget.product.metalPurity!,
                                ),
                              if (widget.product.metalWeightGrams != null)
                                _buildSpecRow(
                                  'Weight',
                                  '${widget.product.metalWeightGrams!.toStringAsFixed(2)}g',
                                ),
                              SizedBox(height: 12),
                            ],
                          ),

                        // Stone Specifications
                        if (widget.product.stoneType != null ||
                            widget.product.stoneColor != null ||
                            widget.product.stoneCarat != null ||
                            widget.product.stoneCut != null ||
                            widget.product.stoneClarity != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Gemstone Details',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.secondary,
                                ),
                              ),
                              SizedBox(height: 8),
                              if (widget.product.stoneType != null)
                                _buildSpecRow(
                                  'Stone',
                                  widget.product.stoneType!,
                                ),
                              if (widget.product.stoneColor != null)
                                _buildSpecRow(
                                  'Color',
                                  widget.product.stoneColor!,
                                ),
                              if (widget.product.stoneCarat != null)
                                _buildSpecRow(
                                  'Carat',
                                  '${widget.product.stoneCarat!.toStringAsFixed(2)} ct',
                                ),
                              if (widget.product.stoneCut != null)
                                _buildSpecRow('Cut', widget.product.stoneCut!),
                              if (widget.product.stoneClarity != null)
                                _buildSpecRow(
                                  'Clarity',
                                  widget.product.stoneClarity!,
                                ),
                            ],
                          ),
                        SizedBox(height: 24),
                        Divider(),
                        SizedBox(height: 16),
                      ],
                    ),

                  // Quantity Selector
                  Text(
                    'Quantity',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _decrementQuantity,
                        icon: Icon(Icons.remove_circle_outline),
                        iconSize: 32,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 16),
                      Text(
                        quantity.toString(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 16),
                      IconButton(
                        onPressed: () => _incrementQuantity(availableStock),
                        icon: Icon(Icons.add_circle_outline),
                        iconSize: 32,
                        color: AppColors.secondary,
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Created/Updated Dates (optional info)
                  if (widget.product.createdAt != null)
                    Text(
                      'Listed on: ${widget.product.createdAt!.day}/${widget.product.createdAt!.month}/${widget.product.createdAt!.year}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  SizedBox(height: 80), // Space for bottom button
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: availableStock > 0 ? _addToCart : null,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              availableStock > 0
                  ? 'Add to Cart'
                  : quantityInCart > 0
                  ? 'All Items in Cart'
                  : 'Out of Stock',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to check if product has any specifications
  bool _hasSpecifications() {
    return widget.product.metalType != null ||
        widget.product.metalColor != null ||
        widget.product.metalPurity != null ||
        widget.product.metalWeightGrams != null ||
        widget.product.stoneType != null ||
        widget.product.stoneColor != null ||
        widget.product.stoneCarat != null ||
        widget.product.stoneCut != null ||
        widget.product.stoneClarity != null;
  }

  // Helper method to build specification rows
  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
