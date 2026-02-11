import 'package:flutter/material.dart';
import 'package:albaqer_gemstone_flutter/models/order.dart';
import 'package:albaqer_gemstone_flutter/services/order_service.dart';
import 'package:albaqer_gemstone_flutter/config/app_theme.dart';
import 'package:intl/intl.dart';

/// ========================================================================
/// DELIVERY PEOPLE MANAGEMENT SCREEN
/// ========================================================================
/// View all delivery personnel and their assigned orders
/// Only visible to manager users

class DeliveryPeopleScreen extends StatefulWidget {
  const DeliveryPeopleScreen({super.key});

  @override
  State<DeliveryPeopleScreen> createState() => _DeliveryPeopleScreenState();
}

class _DeliveryPeopleScreenState extends State<DeliveryPeopleScreen> {
  final OrderService _orderService = OrderService();
  late Future<List<Map<String, dynamic>>> _deliveryPeopleFuture;

  @override
  void initState() {
    super.initState();
    _loadDeliveryPeople();
  }

  void _loadDeliveryPeople() {
    setState(() {
      _deliveryPeopleFuture = _orderService.getDeliveryPeople();
    });
  }

  Future<void> _viewDeliveryPersonOrders(
    Map<String, dynamic> deliveryPerson,
  ) async {
    final orders = await _orderService.getDeliveryPersonOrders(
      deliveryPerson['id'],
    );

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Icon(
                        Icons.delivery_dining,
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            deliveryPerson['full_name'] ?? 'Unknown',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${orders.length} assigned orders',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                Divider(height: 24),

                // Orders list
                Expanded(
                  child: orders.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inbox,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No orders assigned',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: orders.length,
                          itemBuilder: (context, index) {
                            final order = orders[index];
                            return _buildOrderCard(order);
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'assigned':
        return Colors.purple;
      case 'in_transit':
        return Colors.indigo;
      case 'delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delivery People'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _loadDeliveryPeople),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _deliveryPeopleFuture,
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
                  Text('Error loading delivery people'),
                  Text(
                    '${snapshot.error}',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadDeliveryPeople,
                    icon: Icon(Icons.refresh),
                    label: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final deliveryPeople = snapshot.data ?? [];

          if (deliveryPeople.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No delivery people found',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add delivery personnel to see them here',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _loadDeliveryPeople();
            },
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: deliveryPeople.length,
              itemBuilder: (context, index) {
                final person = deliveryPeople[index];
                return _buildDeliveryPersonCard(person);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildDeliveryPersonCard(Map<String, dynamic> person) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _viewDeliveryPersonOrders(person),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Icon(
                  Icons.delivery_dining,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),

              SizedBox(width: 16),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      person['full_name'] ?? 'Unknown',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.badge,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'ID: ${person['id']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.email,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          person['email'] ?? 'No email',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow icon
              Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    final statusColor = _getStatusColor(order.status);

    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.orderNumber,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    order.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${order.totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
                Text(
                  DateFormat(
                    'MMM dd, hh:mm a',
                  ).format(order.createdAt ?? DateTime.now()),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
