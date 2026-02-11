import 'package:flutter/material.dart';
import 'package:albaqer_gemstone_flutter/models/order.dart';
import 'package:albaqer_gemstone_flutter/models/order_item.dart';
import 'package:albaqer_gemstone_flutter/models/address.dart';
import 'package:albaqer_gemstone_flutter/services/order_service.dart';
import 'package:albaqer_gemstone_flutter/services/address_service.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

/// Detailed view of a single order for delivery personnel
/// Shows customer information, delivery address, and order items
class DeliveryOrderDetailScreen extends StatefulWidget {
  final Order order;

  const DeliveryOrderDetailScreen({super.key, required this.order});

  @override
  _DeliveryOrderDetailScreenState createState() =>
      _DeliveryOrderDetailScreenState();
}

class _DeliveryOrderDetailScreenState extends State<DeliveryOrderDetailScreen> {
  final OrderService _orderService = OrderService();
  final AddressService _addressService = AddressService();
  late Order _order;
  Address? _shippingAddress;
  List<OrderItem> _orderItems = [];
  bool _isLoadingAddress = false;
  bool _isLoadingItems = false;
  String? _itemsError;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    if (_order.shippingAddressId != null) {
      _loadShippingAddress();
    }
    if (_order.id != null) {
      _loadOrderItems();
    }
  }

  Future<void> _loadShippingAddress() async {
    if (_order.shippingAddressId == null) return;
    
    setState(() {
      _isLoadingAddress = true;
    });

    try {
      final address = await _addressService.getAddressById(_order.shippingAddressId!);
      if (mounted) {
        setState(() {
          _shippingAddress = address;
          _isLoadingAddress = false;
        });
      }
    } catch (e) {
      print('Error loading address: $e');
      if (mounted) {
        setState(() {
          _isLoadingAddress = false;
        });
      }
    }
  }

  Future<void> _loadOrderItems() async {
    if (_order.id == null) return;
    
    setState(() {
      _isLoadingItems = true;
      _itemsError = null;
    });

    try {
      final items = await _orderService.getOrderItems(_order.id!);
      print('📦 Loaded ${items.length} items for order ${_order.id}');
      if (mounted) {
        setState(() {
          _orderItems = items;
          _isLoadingItems = false;
          if (items.isEmpty) {
            _itemsError = 'No items found for this order';
          }
        });
      }
    } catch (e) {
      print('❌ Error loading order items: $e');
      if (mounted) {
        setState(() {
          _isLoadingItems = false;
          _itemsError = 'Failed to load order items: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    if (!mounted) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Delivery Status'),
        content: Text('Change status to ${_getStatusLabel(newStatus)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final success = await _orderService.updateDeliveryStatus(
        _order.id!,
        newStatus,
      );

      if (!mounted) return;
      Navigator.pop(context); // Close loading

      if (success) {
        setState(() {
          _order = _order.copyWith(status: newStatus);
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Status updated to ${_getStatusLabel(newStatus)}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Failed to update status'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Error: $e')));
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'assigned':
        return 'Pending Pickup';
      case 'in_transit':
        return 'In Transit';
      case 'delivered':
        return 'Delivered';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'assigned':
        return Colors.orange;
      case 'in_transit':
        return Colors.blue;
      case 'delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch phone dialer')),
      );
    }
  }

  Future<void> _sendSMS(String phoneNumber) async {
    final Uri smsUri = Uri(scheme: 'sms', path: phoneNumber);
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch SMS')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Order #${_order.orderNumber}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[700],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _getStatusColor(_order.status),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    _order.status == 'assigned'
                        ? Icons.assignment
                        : _order.status == 'in_transit'
                        ? Icons.local_shipping
                        : Icons.check_circle,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getStatusLabel(_order.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Order info card
            _buildInfoCard(
              title: 'Order Information',
              icon: Icons.receipt_long,
              children: [
                _buildInfoRow('Order Number', '#${_order.orderNumber}'),
                _buildInfoRow(
                  'Order Date',
                  _order.createdAt != null
                      ? DateFormat(
                          'MMM d, yyyy • h:mm a',
                        ).format(_order.createdAt!)
                      : 'N/A',
                ),
                _buildInfoRow(
                  'Total Amount',
                  '\$${_order.totalAmount.toStringAsFixed(2)}',
                ),
                if (_order.trackingNumber != null)
                  _buildInfoRow('Tracking Number', _order.trackingNumber!),
              ],
            ),

            // Customer contact card
            _buildInfoCard(
              title: 'Customer Contact',
              icon: Icons.person,
              children: [
                if (_order.customerName != null)
                  ListTile(
                    leading: const Icon(
                      Icons.account_circle,
                      color: Colors.green,
                    ),
                    title: Text(_order.customerName!),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_order.customerPhone != null)
                          Text('📱 ${_order.customerPhone!}'),
                        if (_order.customerEmail != null)
                          Text('📧 ${_order.customerEmail!}'),
                      ],
                    ),
                  )
                else
                  const ListTile(
                    leading: Icon(
                      Icons.account_circle,
                      color: Colors.grey,
                    ),
                    title: Text('Customer Information'),
                    subtitle: Text('Not available'),
                  ),
                if (_order.customerPhone != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _makePhoneCall(_order.customerPhone!),
                          icon: const Icon(Icons.phone, size: 18),
                          label: const Text('Call'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _sendSMS(_order.customerPhone!),
                          icon: const Icon(Icons.message, size: 18),
                          label: const Text('Message'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
              ],
            ),

            // Delivery address card (if available)
            if (_order.shippingAddressId != null)
              _buildInfoCard(
                title: 'Delivery Address',
                icon: Icons.location_on,
                children: [
                  if (_isLoadingAddress)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_shippingAddress != null)
                    ListTile(
                      leading: const Icon(Icons.location_on, color: Colors.red),
                      title: Text(_shippingAddress!.addressType.toUpperCase()),
                      subtitle: Text(
                        '${_shippingAddress!.streetAddress}\n${_shippingAddress!.city}, ${_shippingAddress!.country}',
                      ),
                      isThreeLine: true,
                    )
                  else
                    const ListTile(
                      leading: Icon(Icons.location_on, color: Colors.grey),
                      title: Text('Shipping Address'),
                      subtitle: Text('Could not load address'),
                    ),
                  if (_shippingAddress != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final address = '${_shippingAddress!.streetAddress}, ${_shippingAddress!.city}, ${_shippingAddress!.country}';
                          final encodedAddress = Uri.encodeComponent(address);
                          final Uri mapsUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedAddress');
                          
                          if (await canLaunchUrl(mapsUri)) {
                            await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
                          } else {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Could not open maps')),
                            );
                          }
                        },
                        icon: const Icon(Icons.map, size: 18),
                        label: const Text('Open in Maps'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                ],
              ),

            // Order items card
            _buildInfoCard(
              title: 'Order Items (${_orderItems.length})',
              icon: Icons.shopping_bag,
              children: [
                if (_isLoadingItems)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_itemsError != null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 8),
                        Text(
                          _itemsError!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _loadOrderItems,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                else if (_orderItems.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No items found',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  ...List.generate(
                    _orderItems.length,
                    (index) {
                      final item = _orderItems[index];
                      return ListTile(
                        leading: item.productImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  item.productImage!,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 50,
                                      height: 50,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.image_not_supported),
                                    );
                                  },
                                ),
                              )
                            : Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.shopping_bag),
                              ),
                        title: Text(
                          item.productName ?? 'Product #${item.productId}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          'Qty: ${item.quantity} × \$${item.priceAtPurchase.toStringAsFixed(2)}',
                        ),
                        trailing: Text(
                          '\$${(item.quantity * item.priceAtPurchase).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),

            // Notes card (if any)
            if (_order.notes != null && _order.notes!.isNotEmpty)
              _buildInfoCard(
                title: 'Special Instructions',
                icon: Icons.note,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _order.notes!,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (_order.status == 'assigned')
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () => _updateStatus('in_transit'),
                        icon: const Icon(Icons.local_shipping),
                        label: const Text('Start Delivery'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (_order.status == 'in_transit')
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () => _updateStatus('delivered'),
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Mark as Delivered'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (_order.status == 'delivered')
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            'Delivery Completed',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: Colors.green[700]),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
