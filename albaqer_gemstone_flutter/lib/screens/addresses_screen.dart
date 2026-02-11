import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/address.dart';
import '../services/address_service.dart';
import 'add_edit_address_screen.dart';

/// ==================================================================================
/// ADDRESSES SCREEN - Manage Shipping/Billing Addresses
/// ==================================================================================
///
/// PURPOSE: Display and manage user's saved addresses
///
/// KEY FEATURES:
/// 1. Dual Mode - View/manage OR select address during checkout
/// 2. Address List - Shows all saved addresses with default indicator
/// 3. Add/Edit - Navigate to form screen
/// 4. Delete - Remove address with confirmation
/// 5. Set Default - Mark address as default
/// 6. Empty State - Friendly message when no addresses
/// ==================================================================================

class AddressesScreen extends StatefulWidget {
  /// If true, enables selection mode for checkout
  final bool isSelectMode;

  /// Callback when address is selected (checkout flow)
  final Function(Address)? onAddressSelected;

  const AddressesScreen({
    super.key,
    this.isSelectMode = false,
    this.onAddressSelected,
  });

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  final AddressService _addressService = AddressService();
  List<Address> _addresses = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  /// Load all addresses from backend
  Future<void> _loadAddresses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final addresses = await _addressService.fetchAllAddresses();
      setState(() {
        _addresses = addresses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load addresses: $e';
        _isLoading = false;
      });
    }
  }

  /// Delete address with confirmation
  Future<void> _deleteAddress(Address address) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: AppColors.warning),
            SizedBox(width: 8),
            Text('Delete Address'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete this address?\n\n'
          '${address.streetAddress}\n${address.city}, ${address.country}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && address.id != null) {
      final result = await _addressService.deleteAddress(address.id!);
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Address deleted successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadAddresses(); // Reload list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to delete address'),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  /// Navigate to add/edit screen
  Future<void> _navigateToAddEditScreen({Address? address}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditAddressScreen(address: address),
      ),
    );

    // Reload addresses if changes were made
    if (result == true) {
      _loadAddresses();
    }
  }

  /// Handle address selection (checkout mode)
  void _selectAddress(Address address) {
    if (widget.isSelectMode && widget.onAddressSelected != null) {
      widget.onAddressSelected!(address);
      Navigator.pop(context, address);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isSelectMode ? 'Select Address' : 'My Addresses',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
      ),
      body: _buildBody(),
      // Only show FAB when there are addresses (empty state has its own button)
      floatingActionButton: _addresses.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _navigateToAddEditScreen(),
              icon: Icon(Icons.add),
              label: Text('Add Address'),
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading addresses...',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.error),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadAddresses,
              icon: Icon(Icons.refresh),
              label: Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
              ),
            ),
          ],
        ),
      );
    }

    if (_addresses.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadAddresses,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _addresses.length,
        itemBuilder: (context, index) {
          return _buildAddressCard(_addresses[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off, size: 100, color: AppColors.textSecondary),
          SizedBox(height: 24),
          Text(
            'No Addresses Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            widget.isSelectMode
                ? 'Add a shipping address to continue checkout'
                : 'Add your first address to save time during checkout',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _navigateToAddEditScreen(),
            icon: Icon(Icons.add),
            label: Text('Add Address'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(Address address) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: widget.isSelectMode ? () => _selectAddress(address) : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with type and default badge
              Row(
                children: [
                  // Address type icon
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      address.addressType == 'shipping'
                          ? Icons.local_shipping
                          : Icons.payment,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  // Address type label
                  Text(
                    address.addressType.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                      letterSpacing: 1,
                    ),
                  ),
                  Spacer(),
                  // Default badge
                  if (address.isDefault)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'DEFAULT',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 16),

              // Address details
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          address.streetAddress,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${address.city}, ${address.country}',
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

              // Action buttons (only in manage mode)
              if (!widget.isSelectMode) ...[
                SizedBox(height: 16),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Set as default button
                    if (!address.isDefault)
                      TextButton.icon(
                        onPressed: () async {
                          // TODO: Add setDefault API call
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Set as default feature coming soon',
                              ),
                            ),
                          );
                        },
                        icon: Icon(Icons.star_outline, size: 18),
                        label: Text('Set Default'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                    SizedBox(width: 8),
                    // Edit button
                    TextButton.icon(
                      onPressed: () =>
                          _navigateToAddEditScreen(address: address),
                      icon: Icon(Icons.edit, size: 18),
                      label: Text('Edit'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.info,
                      ),
                    ),
                    SizedBox(width: 8),
                    // Delete button
                    TextButton.icon(
                      onPressed: () => _deleteAddress(address),
                      icon: Icon(Icons.delete, size: 18),
                      label: Text('Delete'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
