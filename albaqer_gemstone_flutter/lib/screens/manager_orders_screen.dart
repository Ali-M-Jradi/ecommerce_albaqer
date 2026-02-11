import 'package:flutter/material.dart';
import 'package:albaqer_gemstone_flutter/models/order.dart';
import 'package:albaqer_gemstone_flutter/services/order_service.dart';
import 'package:albaqer_gemstone_flutter/config/app_theme.dart';
import 'package:intl/intl.dart';

/// ========================================================================
/// MANAGER ORDERS MANAGEMENT SCREEN
/// ========================================================================
/// Display all orders with ability to assign to delivery personnel
/// Only visible to manager users

class ManagerOrdersScreen extends StatefulWidget {
  const ManagerOrdersScreen({super.key});

  @override
  State<ManagerOrdersScreen> createState() => _ManagerOrdersScreenState();
}

class _ManagerOrdersScreenState extends State<ManagerOrdersScreen> {
  final OrderService _orderService = OrderService();
  late Future<List<Order>> _ordersFuture;
  // Filter: 'pending' = Ready to Assign (confirmed by admin, unassigned)
  //         'assigned' = Orders assigned to delivery personnel
  //         'all' = All orders manager can see
  String _selectedFilter = 'pending';

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    setState(() {
      // 'pending' filter gets confirmed unassigned orders from backend
      if (_selectedFilter == 'pending') {
        _ordersFuture = _orderService.getPendingOrdersManager();
      } else {
        _ordersFuture = _orderService.getAllOrdersAdmin();
      }
    });
  }

  List<Order> _filterOrders(List<Order> orders) {
    if (_selectedFilter == 'all') {
      return orders;
    }
    return orders.where((order) => order.status == _selectedFilter).toList();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'assigned':
        return Colors.purple;
      case 'in_transit':
        return Colors.indigo;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _showAssignDialog(Order order) async {
    // Get list of delivery people
    final deliveryPeople = await _orderService.getDeliveryPeople();

    if (!mounted) return;

    if (deliveryPeople.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No delivery personnel available'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final selectedId = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.assignment_ind, color: Colors.deepPurple),
            SizedBox(width: 8),
            Text('Assign Delivery Person'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order: ${order.orderNumber}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Amount: \$${order.totalAmount.toStringAsFixed(2)}',
                    style: TextStyle(color: Colors.blue.shade900, fontSize: 13),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Select delivery person:',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
            SizedBox(height: 8),
            Container(
              constraints: BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: deliveryPeople.map((person) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.deepPurple,
                        child: Icon(Icons.delivery_dining, color: Colors.white),
                      ),
                      title: Text(
                        person['full_name'] ?? 'Unknown',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        'ID: ${person['id']} • ${person['email'] ?? ''}',
                        style: TextStyle(fontSize: 12),
                      ),
                      onTap: () {
                        Navigator.pop(context, person['id'] as int);
                      },
                      hoverColor: Colors.deepPurple.shade50,
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );

    if (selectedId != null) {
      _assignOrder(order.id!, selectedId);
    }
  }

  Future<void> _assignOrder(int orderId, int deliveryManId) async {
    try {
      final success = await _orderService.assignOrderToDelivery(
        orderId,
        deliveryManId,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order assigned successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadOrders(); // Refresh the list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to assign order'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _unassignOrder(Order order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Unassign Delivery Person'),
        content: Text(
          'Are you sure you want to unassign the delivery person from order ${order.orderNumber}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Unassign'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _orderService.unassignOrderFromDelivery(order.id!);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Delivery person unassigned'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadOrders();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to unassign delivery person'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.assignment_turned_in, size: 24),
            SizedBox(width: 8),
            Text('Order Assignment'),
          ],
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadOrders,
            tooltip: 'Refresh orders',
          ),
        ],
      ),
      body: Column(
        children: [
          // Info Banner
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            color: Colors.deepPurple.shade50,
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 20, color: Colors.deepPurple),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Assign confirmed orders to delivery personnel',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.deepPurple.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filter Chips
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Ready to Assign', 'pending'),
                  SizedBox(width: 8),
                  _buildFilterChip('Assigned', 'assigned'),
                  SizedBox(width: 8),
                  _buildFilterChip('All', 'all'),
                ],
              ),
            ),
          ),

          // Orders List
          Expanded(
            child: FutureBuilder<List<Order>>(
              future: _ordersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red),
                        SizedBox(height: 16),
                        Text('Error loading orders'),
                        Text(
                          '${snapshot.error}',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                final orders = _filterOrders(snapshot.data ?? []);

                if (orders.isEmpty) {
                  String emptyMessage = 'No orders found';
                  String emptyHint = '';

                  if (_selectedFilter == 'pending') {
                    emptyMessage = 'No orders ready to assign';
                    emptyHint = 'Orders appear here after admin confirmation';
                  } else if (_selectedFilter == 'confirmed') {
                    emptyMessage = 'No confirmed orders';
                    emptyHint = 'Waiting for admin to confirm pending orders';
                  } else if (_selectedFilter == 'assigned') {
                    emptyMessage = 'No assigned orders';
                    emptyHint = 'Assign confirmed orders to delivery personnel';
                  }

                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_late,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          emptyMessage,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (emptyHint.isNotEmpty) ...[
                          SizedBox(height: 8),
                          Text(
                            emptyHint,
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    _loadOrders();
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return _buildOrderCard(order);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
          _loadOrders();
        });
      },
      selectedColor: Colors.deepPurple.withOpacity(0.3),
      checkmarkColor: Colors.deepPurple,
      backgroundColor: Colors.grey.shade100,
      elevation: isSelected ? 2 : 0,
    );
  }

  Widget _buildOrderCard(Order order) {
    final statusColor = _getStatusColor(order.status);
    final hasDeliveryPerson = order.deliveryManId != null;

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _showOrderDetails(order),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.orderNumber,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          DateFormat(
                            'MMM dd, yyyy',
                          ).format(order.createdAt ?? DateTime.now()),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      order.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),

              Divider(height: 24),

              // Order Details
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: AppColors.textSecondary),
                  SizedBox(width: 8),
                  Text('User ID: ${order.userId}'),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.attach_money,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 8),
                  Text(
                    '\$${order.totalAmount.toStringAsFixed(2)}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),

              // Delivery Person Info
              if (hasDeliveryPerson) ...[
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.delivery_dining,
                            size: 18,
                            color: Colors.green.shade700,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Delivery Person #${order.deliveryManId}',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.green.shade900,
                            ),
                          ),
                        ],
                      ),
                      if (order.assignedAt != null) ...[
                        SizedBox(height: 4),
                        Text(
                          'Assigned: ${DateFormat('MMM dd, yyyy HH:mm').format(order.assignedAt!)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              SizedBox(height: 12),

              // Action Buttons
              Row(
                children: [
                  // Only allow assignment of CONFIRMED orders (not pending)
                  if (!hasDeliveryPerson && order.status == 'confirmed')
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showAssignDialog(order),
                        icon: Icon(Icons.delivery_dining, size: 18),
                        label: Text('Assign Delivery'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          elevation: 2,
                        ),
                      ),
                    ),
                  // Show info for pending orders (need admin confirmation)
                  if (!hasDeliveryPerson && order.status == 'pending')
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.hourglass_empty,
                              size: 16,
                              color: Colors.orange,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Awaiting admin confirmation',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange.shade900,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (hasDeliveryPerson) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _unassignOrder(order),
                        icon: Icon(Icons.person_remove, size: 18),
                        label: Text('Unassign'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showAssignDialog(order),
                        icon: Icon(Icons.swap_horiz, size: 18),
                        label: Text('Reassign'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOrderDetails(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Order Number', order.orderNumber),
              _buildDetailRow('Status', order.status.toUpperCase()),
              _buildDetailRow('User ID', order.userId.toString()),
              _buildDetailRow(
                'Total',
                '\$${order.totalAmount.toStringAsFixed(2)}',
              ),
              if (order.deliveryManId != null)
                _buildDetailRow('Delivery Person', '#${order.deliveryManId}'),
              _buildDetailRow(
                'Created',
                DateFormat(
                  'MMM dd, yyyy hh:mm a',
                ).format(order.createdAt ?? DateTime.now()),
              ),
              if (order.assignedAt != null)
                _buildDetailRow(
                  'Assigned',
                  DateFormat('MMM dd, yyyy hh:mm a').format(order.assignedAt!),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
