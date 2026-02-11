import 'package:flutter/material.dart';
import 'package:albaqer_gemstone_flutter/services/order_service.dart';
import 'package:albaqer_gemstone_flutter/models/order.dart';
import 'delivery_orders_screen.dart';

/// Dashboard for delivery personnel to view their assignment statistics
/// Shows counts of assigned, in-transit, and completed deliveries
class DeliveryDashboardScreen extends StatefulWidget {
  const DeliveryDashboardScreen({Key? key}) : super(key: key);

  @override
  _DeliveryDashboardScreenState createState() =>
      _DeliveryDashboardScreenState();
}

class _DeliveryDashboardScreenState extends State<DeliveryDashboardScreen> {
  final OrderService _orderService = OrderService();
  bool _isLoading = true;
  int _assignedCount = 0;
  int _inTransitCount = 0;
  int _deliveredCount = 0;
  int _totalDeliveries = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final orders = await _orderService.getMyDeliveries();

      setState(() {
        _assignedCount = orders.where((o) => o.status == 'assigned').length;
        _inTransitCount = orders.where((o) => o.status == 'in_transit').length;
        _deliveredCount = orders.where((o) => o.status == 'delivered').length;
        _totalDeliveries = orders.length;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading delivery stats: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Delivery Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[700],
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadStats),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome card
                      Card(
                        elevation: 2,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.green[700]!, Colors.green[500]!],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.local_shipping,
                                color: Colors.white,
                                size: 40,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Delivery Operations',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '$_totalDeliveries total deliveries assigned',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Stats grid
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.1,
                        children: [
                          _buildStatCard(
                            title: 'Pending Pickup',
                            count: _assignedCount,
                            icon: Icons.assignment,
                            color: Colors.orange,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const DeliveryOrdersScreen(
                                        initialFilter: 'assigned',
                                      ),
                                ),
                              ).then((_) => _loadStats());
                            },
                          ),
                          _buildStatCard(
                            title: 'In Transit',
                            count: _inTransitCount,
                            icon: Icons.local_shipping,
                            color: Colors.blue,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const DeliveryOrdersScreen(
                                        initialFilter: 'in_transit',
                                      ),
                                ),
                              ).then((_) => _loadStats());
                            },
                          ),
                          _buildStatCard(
                            title: 'Delivered',
                            count: _deliveredCount,
                            icon: Icons.check_circle,
                            color: Colors.green,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const DeliveryOrdersScreen(
                                        initialFilter: 'delivered',
                                      ),
                                ),
                              ).then((_) => _loadStats());
                            },
                          ),
                          _buildStatCard(
                            title: 'All Deliveries',
                            count: _totalDeliveries,
                            icon: Icons.list_alt,
                            color: Colors.green[700]!,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const DeliveryOrdersScreen(
                                        initialFilter: 'all',
                                      ),
                                ),
                              ).then((_) => _loadStats());
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Quick actions
                      const Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildQuickActionButton(
                        icon: Icons.assignment,
                        label: 'View Pending Pickups',
                        color: Colors.orange,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DeliveryOrdersScreen(
                                initialFilter: 'assigned',
                              ),
                            ),
                          ).then((_) => _loadStats());
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildQuickActionButton(
                        icon: Icons.local_shipping,
                        label: 'Active Deliveries',
                        color: Colors.blue,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DeliveryOrdersScreen(
                                initialFilter: 'in_transit',
                              ),
                            ),
                          ).then((_) => _loadStats());
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
