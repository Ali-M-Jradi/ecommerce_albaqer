import 'package:flutter/material.dart';
import 'package:albaqer_gemstone_flutter/services/order_service.dart';
import 'package:albaqer_gemstone_flutter/config/app_theme.dart';
import 'package:albaqer_gemstone_flutter/screens/manager_orders_screen.dart';
import 'package:albaqer_gemstone_flutter/screens/delivery_people_screen.dart';

/// ========================================================================
/// MANAGER DASHBOARD SCREEN
/// ========================================================================
/// Overview dashboard for manager role with quick actions and statistics
/// Only visible to manager users

class ManagerDashboardScreen extends StatefulWidget {
  const ManagerDashboardScreen({super.key});

  @override
  State<ManagerDashboardScreen> createState() => _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends State<ManagerDashboardScreen> {
  final OrderService _orderService = OrderService();
  bool _isLoading = true;
  int _pendingOrdersCount = 0;
  int _deliveryPeopleCount = 0;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final pendingOrders = await _orderService.getPendingOrdersManager();
      final deliveryPeople = await _orderService.getDeliveryPeople();

      setState(() {
        _pendingOrdersCount = pendingOrders.length;
        _deliveryPeopleCount = deliveryPeople.length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manager Dashboard'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _loadDashboardData),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              Text(
                'Welcome, Manager',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Overview of pending orders and delivery personnel',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),

              SizedBox(height: 24),

              // Statistics Cards
              if (_isLoading)
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_error.isNotEmpty)
                Card(
                  color: Colors.red[50],
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Error loading data: $_error',
                            style: TextStyle(color: Colors.red[900]),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'Pending Orders',
                        value: _pendingOrdersCount.toString(),
                        icon: Icons.pending_actions,
                        color: Colors.orange,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ManagerOrdersScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        title: 'Delivery Staff',
                        value: _deliveryPeopleCount.toString(),
                        icon: Icons.delivery_dining,
                        color: Colors.purple,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DeliveryPeopleScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 24),

                // Quick Actions Section
                Text(
                  'Quick Actions',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),

                _buildActionCard(
                  title: 'Manage Orders',
                  subtitle: 'View and assign orders to delivery personnel',
                  icon: Icons.receipt_long,
                  color: Colors.blue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ManagerOrdersScreen(),
                      ),
                    );
                  },
                ),

                SizedBox(height: 12),

                _buildActionCard(
                  title: 'Delivery People',
                  subtitle: 'View delivery staff and their assigned orders',
                  icon: Icons.people,
                  color: Colors.green,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DeliveryPeopleScreen(),
                      ),
                    );
                  },
                ),

                SizedBox(height: 24),

                // Info Section
                Card(
                  color: AppColors.primary.withOpacity(0.1),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: AppColors.primary),
                            SizedBox(width: 12),
                            Text(
                              'Manager Responsibilities',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        _buildInfoItem('• Review and confirm pending orders'),
                        _buildInfoItem('• Assign orders to delivery personnel'),
                        _buildInfoItem('• Monitor delivery progress'),
                        _buildInfoItem('• Manage delivery staff assignments'),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              SizedBox(height: 12),
              Text(
                value,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              SizedBox(height: 4),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
      ),
    );
  }
}
