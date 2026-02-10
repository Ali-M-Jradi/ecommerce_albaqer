import 'package:flutter/material.dart';
import 'package:albaqer_gemstone_flutter/models/order.dart';
import 'package:albaqer_gemstone_flutter/services/order_service.dart';
import 'package:albaqer_gemstone_flutter/config/app_theme.dart';
import 'package:intl/intl.dart';

/// ========================================================================
/// ADMIN ORDERS MANAGEMENT SCREEN
/// ========================================================================
/// Display all orders with ability to accept/decline/manage status
/// Only visible to admin users

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final OrderService _orderService = OrderService();
  late Future<List<Order>> _ordersFuture;
  String _selectedFilter =
      'all'; // all, pending, confirmed, assigned, delivered

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    setState(() {
      _ordersFuture = _orderService.getAllOrdersAdmin();
    });
  }

  List<Order> _filterOrders(List<Order> orders) {
    if (_selectedFilter == 'all') {
      return orders;
    }
    return orders.where((order) => order.status == _selectedFilter).toList();
  }

  String _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return '#FF9800';
      case 'confirmed':
        return '#2196F3';
      case 'assigned':
        return '#9C27B0';
      case 'in_transit':
        return '#3F51B5';
      case 'delivered':
        return '#4CAF50';
      case 'cancelled':
        return '#F44336';
      default:
        return '#757575';
    }
  }

  Color _hexToColor(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse('0x$hexColor'));
  }

  Future<void> _updateOrderStatus(Order order, String newStatus) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Order Status'),
        content: Text(
          'Are you sure you want to change order ${order.orderNumber} status to "$newStatus"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _orderService.updateOrderStatusAdmin(
        order.id ?? 0,
        newStatus,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? '✅ Order status updated to $newStatus'
                  : '❌ Failed to update order status',
            ),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );

        if (success) {
          _loadOrders();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        backgroundColor: AppColors.primary,
        title: const Text(
          '📋 Admin Orders',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textOnPrimary,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textOnPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
            tooltip: 'Refresh orders',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _buildFilterChip('all', 'All Orders'),
                _buildFilterChip('pending', 'Pending'),
                _buildFilterChip('confirmed', 'Confirmed'),
                _buildFilterChip('assigned', 'Assigned'),
                _buildFilterChip('delivered', 'Delivered'),
                _buildFilterChip('cancelled', 'Cancelled'),
              ],
            ),
          ),
          // Orders list
          Expanded(
            child: FutureBuilder<List<Order>>(
              future: _ordersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading orders',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(snapshot.error.toString()),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadOrders,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.shopping_cart_outlined,
                          size: 64,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No orders found',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  );
                }

                final allOrders = snapshot.data!;
                final filteredOrders = _filterOrders(allOrders);

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    return _buildOrderCard(order);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = value;
          });
        },
        backgroundColor: AppColors.background,
        selectedColor: AppColors.primary.withOpacity(0.3),
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    final statusColor = _hexToColor(_getStatusColor(order.status));
    final dateFormatter = DateFormat('MMM dd, yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // Header with order number and status
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.divider, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.orderNumber}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateFormatter.format(order.createdAt ?? DateTime.now()),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    border: Border.all(color: statusColor),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Order details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Customer ID', '${order.userId}', Icons.person),
                const SizedBox(height: 8),
                _buildDetailRow(
                  'Total Amount',
                  '\$${order.totalAmount.toStringAsFixed(2)}',
                  Icons.attach_money,
                  isAmount: true,
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  'Tax',
                  '\$${order.taxAmount.toStringAsFixed(2)}',
                  Icons.percent,
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  'Shipping',
                  '\$${order.shippingCost.toStringAsFixed(2)}',
                  Icons.local_shipping,
                ),
                if (order.notes != null && order.notes!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Notes:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.notes!,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Action buttons
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Decline button (if still pending)
                if (order.status == 'pending') ...[
                  ElevatedButton.icon(
                    onPressed: () => _updateOrderStatus(order, 'cancelled'),
                    icon: const Icon(Icons.close),
                    label: const Text('Decline Order'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _updateOrderStatus(order, 'confirmed'),
                    icon: const Icon(Icons.check),
                    label: const Text('Accept Order'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ] else ...[
                  // Status progression buttons
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatusButton(
                          label: 'Previous',
                          onPressed: () => _showPreviousStatusOptions(order),
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatusButton(
                          label: 'Next',
                          onPressed: () => _showNextStatusOptions(order),
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon, {
    bool isAmount = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textLight),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textLight),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isAmount ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusButton({
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label),
    );
  }

  void _showNextStatusOptions(Order order) {
    final nextStatuses = _getNextStatuses(order.status);
    if (nextStatuses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No further actions available for this order'),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Move to next status',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ...nextStatuses.map((status) {
            return ListTile(
              title: Text(status),
              onTap: () {
                Navigator.pop(context);
                _updateOrderStatus(order, status);
              },
            );
          }),
        ],
      ),
    );
  }

  void _showPreviousStatusOptions(Order order) {
    final previousStatuses = _getPreviousStatuses(order.status);
    if (previousStatuses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot go back from this status')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Move to previous status',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ...previousStatuses.map((status) {
            return ListTile(
              title: Text(status),
              onTap: () {
                Navigator.pop(context);
                _updateOrderStatus(order, status);
              },
            );
          }),
        ],
      ),
    );
  }

  List<String> _getNextStatuses(String currentStatus) {
    switch (currentStatus.toLowerCase()) {
      case 'pending':
        return ['confirmed', 'cancelled'];
      case 'confirmed':
        return ['assigned', 'cancelled'];
      case 'assigned':
        return ['in_transit', 'cancelled'];
      case 'in_transit':
        return ['delivered', 'cancelled'];
      case 'delivered':
        return [];
      case 'cancelled':
        return [];
      default:
        return [];
    }
  }

  List<String> _getPreviousStatuses(String currentStatus) {
    switch (currentStatus.toLowerCase()) {
      case 'pending':
        return [];
      case 'confirmed':
        return ['pending'];
      case 'assigned':
        return ['confirmed', 'pending'];
      case 'in_transit':
        return ['assigned', 'confirmed'];
      case 'delivered':
        return ['in_transit', 'assigned'];
      case 'cancelled':
        return [];
      default:
        return [];
    }
  }
}
