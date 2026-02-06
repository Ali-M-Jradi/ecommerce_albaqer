import 'package:albaqer_gemstone_flutter/models/cart_item.dart';
import 'package:albaqer_gemstone_flutter/models/product.dart';
import 'package:albaqer_gemstone_flutter/models/order_item.dart';
import 'package:albaqer_gemstone_flutter/services/cart_service.dart';
import 'package:albaqer_gemstone_flutter/services/order_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';

/// ==================================================================================
/// CART SCREEN - Shopping Cart UI
/// ==================================================================================
///
/// PURPOSE: Displays user's shopping cart with full CRUD operations
///
/// KEY FEATURES FOR PRESENTATION:
/// 1. Real-time Cart Display - Shows all cart items with product details
/// 2. Quantity Management - Increment/Decrement with +/- buttons
/// 3. Remove Items - Swipe to delete functionality
/// 4. Empty Cart State - Friendly message when cart is empty
/// 5. Price Calculations - Subtotal, Tax, Shipping, Total
/// 6. Checkout Button - Proceed to order placement
/// 7. Responsive Design - Adapts to different screen sizes
/// 8. Loading States - Shows progress during operations
/// ==================================================================================

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Shopping Cart',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        actions: [
          // Clear cart button (only show if cart has items)
          Consumer<CartService>(
            builder: (context, cartService, child) {
              if (cartService.itemCount == 0) return SizedBox.shrink();
              return IconButton(
                icon: Icon(Icons.delete_sweep),
                tooltip: 'Clear Cart',
                onPressed: () => _showClearCartDialog(context, cartService),
              );
            },
          ),
        ],
      ),
      body: Consumer<CartService>(
        builder: (context, cartService, child) {
          // FEATURE 1: EMPTY CART STATE
          // Show friendly message when cart is empty
          if (cartService.itemCount == 0) {
            return _buildEmptyCart(context);
          }

          // FEATURE 2: CART ITEMS LIST WITH SUMMARY
          // Display cart items and price breakdown
          return Column(
            children: [
              // Cart Items List (scrollable)
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(8),
                  itemCount: cartService.cartItems.length,
                  itemBuilder: (context, index) {
                    final cartItem = cartService.cartItems[index];
                    final product = cartService.cartProducts[index];
                    return _buildCartItemCard(
                      context,
                      cartService,
                      cartItem,
                      product,
                    );
                  },
                ),
              ),

              // FEATURE 3: CART SUMMARY
              // Shows price breakdown and checkout button
              _buildCartSummary(context, cartService),
            ],
          );
        },
      ),
    );
  }

  /// ==================================================================================
  /// EMPTY CART STATE
  /// ==================================================================================
  /// Displays when cart has no items
  /// Provides navigation back to shopping
  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 120,
            color: AppColors.border,
          ),
          SizedBox(height: 24),
          Text(
            'Your Cart is Empty',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Add items to your cart to see them here',
            style: TextStyle(fontSize: 16, color: AppColors.textLight),
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.shopping_bag),
            label: Text('Continue Shopping'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ==================================================================================
  /// CART ITEM CARD
  /// ==================================================================================
  /// Displays individual cart item with:
  /// - Product image, name, price
  /// - Quantity controls (+/- buttons)
  /// - Remove button
  /// - Subtotal for this item
  Widget _buildCartItemCard(
    BuildContext context,
    CartService cartService,
    CartItem cartItem,
    Product product,
  ) {
    final itemSubtotal = cartItem.priceAtAdd * cartItem.quantity;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PRODUCT IMAGE
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.surface,
              ),
              child: product.fullImageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        product.fullImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.image,
                            size: 40,
                            color: AppColors.textLight,
                          );
                        },
                      ),
                    )
                  : Icon(Icons.image, size: 40, color: AppColors.textLight),
            ),
            SizedBox(width: 12),

            // PRODUCT DETAILS
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    product.name,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),

                  // Product Type
                  Text(
                    product.type,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4),

                  // Tracking ID (UUID)
                  if (cartItem.trackingId != null)
                    Text(
                      'Track ID: ${cartItem.trackingId!.substring(0, 8)}...',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.info,
                        fontFamily: 'monospace',
                      ),
                    ),
                  SizedBox(height: 8),

                  // Price per unit
                  Text(
                    '\$${cartItem.priceAtAdd.toStringAsFixed(2)} each',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 8),

                  // QUANTITY CONTROLS & SUBTOTAL
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Quantity controls
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // DECREMENT BUTTON
                            InkWell(
                              onTap: () =>
                                  _decrementQuantity(cartService, cartItem.id!),
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Icon(Icons.remove, size: 16),
                              ),
                            ),

                            // QUANTITY DISPLAY
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6),
                              child: Text(
                                '${cartItem.quantity}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            // INCREMENT BUTTON
                            InkWell(
                              onTap: () => _incrementQuantity(
                                cartService,
                                cartItem.id!,
                                product,
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Icon(Icons.add, size: 16),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(width: 8),

                      // ITEM SUBTOTAL
                      Text(
                        '\$${itemSubtotal.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // REMOVE BUTTON
            IconButton(
              icon: Icon(Icons.close, color: AppColors.error),
              onPressed: () =>
                  _removeItem(cartService, cartItem.id!, product.name),
              tooltip: 'Remove from cart',
            ),
          ],
        ),
      ),
    );
  }

  /// ==================================================================================
  /// CART SUMMARY
  /// ==================================================================================
  /// Shows price breakdown and checkout button
  /// Includes: Subtotal, Tax, Shipping, Total
  Widget _buildCartSummary(BuildContext context, CartService cartService) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // SUBTOTAL
            _buildPriceRow('Subtotal', cartService.subtotal, isSubtotal: true),
            SizedBox(height: 8),

            // TAX (10%)
            _buildPriceRow('Tax (10%)', cartService.tax),
            SizedBox(height: 8),

            // SHIPPING
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Shipping',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  cartService.shippingCost == 0
                      ? 'FREE'
                      : '\$${cartService.shippingCost.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: cartService.shippingCost == 0
                        ? AppColors.success
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            // Free shipping hint
            if (cartService.subtotal < 100)
              Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'Add \$${(100 - cartService.subtotal).toStringAsFixed(2)} more for free shipping!',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.secondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

            Divider(height: 24, thickness: 1),

            // TOTAL
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${cartService.total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // CHECKOUT BUTTON
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () => _proceedToCheckout(context, cartService),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: AppColors.textOnPrimary,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_bag_outlined, size: 24),
                          SizedBox(width: 8),
                          Text(
                            'Proceed to Checkout',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
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

  /// Helper widget for price rows
  Widget _buildPriceRow(
    String label,
    double amount, {
    bool isSubtotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
            fontWeight: isSubtotal ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  /// ==================================================================================
  /// CART OPERATIONS
  /// ==================================================================================

  /// INCREMENT QUANTITY
  /// Increases item quantity by 1 with stock validation
  Future<void> _incrementQuantity(
    CartService cartService,
    int cartItemId,
    Product product,
  ) async {
    final success = await cartService.incrementQuantity(cartItemId);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Only ${product.quantityInStock} available in stock'),
          backgroundColor: AppColors.warning,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// DECREMENT QUANTITY
  /// Decreases item quantity by 1, removes if quantity becomes 0
  Future<void> _decrementQuantity(
    CartService cartService,
    int cartItemId,
  ) async {
    await cartService.decrementQuantity(cartItemId);
  }

  /// REMOVE ITEM
  /// Removes item from cart with confirmation
  Future<void> _removeItem(
    CartService cartService,
    int cartItemId,
    String productName,
  ) async {
    final success = await cartService.removeItem(cartItemId);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$productName removed from cart'),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 2),
          action: SnackBarAction(
            label: 'OK',
            textColor: AppColors.textOnPrimary,
            onPressed: () {},
          ),
        ),
      );
    }
  }

  /// CLEAR CART DIALOG
  /// Asks for confirmation before clearing entire cart
  Future<void> _showClearCartDialog(
    BuildContext context,
    CartService cartService,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear Cart?'),
        content: Text(
          'Are you sure you want to remove all items from your cart?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await cartService.clearAllItems();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cart cleared'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// PROCEED TO CHECKOUT
  /// Creates order in database and shows confirmation
  Future<void> _proceedToCheckout(
    BuildContext context,
    CartService cartService,
  ) async {
    // Re-validate stock availability before proceeding
    for (var i = 0; i < cartService.cartItems.length; i++) {
      final cartItem = cartService.cartItems[i];
      final product = cartService.cartProducts[i];

      if (product.quantityInStock <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${product.name} is out of stock. Please remove it from cart.',
            ),
            duration: Duration(seconds: 3),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      if (cartItem.quantity > product.quantityInStock) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Only ${product.quantityInStock} of ${product.name} available. Please adjust quantity.',
            ),
            duration: Duration(seconds: 3),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final orderService = OrderService();

      // Convert cart items to order items
      final orderItems = cartService.cartItems.map((cartItem) {
        final product =
            cartService.cartProducts[cartService.cartItems.indexOf(cartItem)];
        return OrderItem(
          orderId: 0, // Will be set by backend
          productId: product.id!,
          quantity: cartItem.quantity,
          priceAtPurchase: cartItem.priceAtAdd,
        );
      }).toList();

      // Create order with cart totals and items
      final order = await orderService.createOrder(
        subtotal: cartService.subtotal,
        taxAmount: cartService.tax,
        shippingCost: cartService.shippingCost,
        orderItems: orderItems,
        notes: 'Order from mobile app - ${cartService.totalItemsCount} items',
      );

      setState(() => _isLoading = false);

      if (!mounted) return;

      if (order != null) {
        // Success - show confirmation
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 28),
                SizedBox(width: 8),
                Text('Order Placed!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your order has been placed successfully.'),
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Number:',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        order.orderNumber,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Items:', style: TextStyle(fontSize: 14)),
                          Text(
                            '${cartService.totalItemsCount}',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total:', style: TextStyle(fontSize: 14)),
                          Text(
                            '\$${order.totalAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'You can track your order in the Profile tab.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  cartService.clearAllItems(); // Clear cart
                  Navigator.pop(context); // Return to previous screen
                },
                child: Text('OK', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        );
      } else {
        // Failed to create order
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to place order. Please try again.'),
            backgroundColor: AppColors.error,
            action: SnackBarAction(
              label: 'Retry',
              textColor: AppColors.textOnPrimary,
              onPressed: () => _proceedToCheckout(context, cartService),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print('❌ Checkout error: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

/// ==================================================================================
/// PRESENTATION TALKING POINTS FOR CART UI:
/// ==================================================================================
/// 
/// 1. USER EXPERIENCE:
///    - Empty state guides users back to shopping
///    - Real-time quantity updates with immediate visual feedback
///    - Clear price breakdown builds trust
///    - Free shipping incentive encourages larger orders
/// 
/// 2. INTERACTION DESIGN:
///    - +/- buttons for easy quantity adjustment
///    - Swipe or tap to remove items
///    - Confirmation dialogs prevent accidental actions
///    - Loading states during operations
/// 
/// 3. RESPONSIVE LAYOUT:
///    - Card-based design adapts to different screen sizes
///    - Product images provide visual context
///    - Summary section stays at bottom (sticky)
/// 
/// 4. BUSINESS LOGIC:
///    - Stock validation prevents over-ordering
///    - Price calculations happen in service layer
///    - Tax and shipping rules clearly displayed
/// 
/// 5. STATE MANAGEMENT:
///    - Consumer widget listens to CartService changes
///    - UI rebuilds automatically when cart updates
///    - Single source of truth for cart state
/// 
/// ==================================================================================
