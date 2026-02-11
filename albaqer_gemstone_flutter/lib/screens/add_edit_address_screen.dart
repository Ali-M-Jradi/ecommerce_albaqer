import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/address.dart';
import '../services/address_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ==================================================================================
/// ADD/EDIT ADDRESS SCREEN - Create or Update Address
/// ==================================================================================
///
/// PURPOSE: Form for creating new address or editing existing one
///
/// KEY FEATURES:
/// 1. Dual Mode - Add new OR edit existing address
/// 2. Form Validation - Ensures all required fields are filled
/// 3. Address Type - Shipping or Billing selector
/// 4. Default Address - Toggle to set as default
/// 5. Save - Creates or updates address in backend
/// ==================================================================================

class AddEditAddressScreen extends StatefulWidget {
  /// If provided, screen is in edit mode. Otherwise, add mode.
  final Address? address;

  const AddEditAddressScreen({super.key, this.address});

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final AddressService _addressService = AddressService();

  // Form controllers
  late TextEditingController _streetController;
  late TextEditingController _cityController;
  late TextEditingController _countryController;

  // Form values
  String _addressType = 'shipping';
  bool _isDefault = false;
  bool _isLoading = false;

  // Edit mode check
  bool get _isEditMode => widget.address != null;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing data if in edit mode
    if (_isEditMode) {
      _streetController = TextEditingController(
        text: widget.address!.streetAddress,
      );
      _cityController = TextEditingController(text: widget.address!.city);
      _countryController = TextEditingController(text: widget.address!.country);
      _addressType = widget.address!.addressType;
      _isDefault = widget.address!.isDefault;
    } else {
      _streetController = TextEditingController();
      _cityController = TextEditingController();
      _countryController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  /// Save address (create or update)
  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get user ID from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Create address object
      final address = Address(
        id: _isEditMode ? widget.address!.id : null,
        userId: userId,
        addressType: _addressType,
        streetAddress: _streetController.text.trim(),
        city: _cityController.text.trim(),
        country: _countryController.text.trim(),
        isDefault: _isDefault,
      );

      // Call API
      Address? result;
      if (_isEditMode) {
        result = await _addressService.updateAddress(address);
      } else {
        result = await _addressService.createAddress(address);
      }

      setState(() => _isLoading = false);

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode
                  ? 'Address updated successfully'
                  : 'Address added successfully',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        // Return true to indicate success
        Navigator.pop(context, true);
      } else {
        _showError('Failed to save address. Please try again.');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Error: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit Address' : 'Add New Address',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info card
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.info.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.info),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Fill in your address details for shipping and billing',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Address Type Selector
              Text(
                'Address Type',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildTypeButton(
                      'shipping',
                      'Shipping',
                      Icons.local_shipping,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildTypeButton(
                      'billing',
                      'Billing',
                      Icons.payment,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),

              // Street Address Field
              Text(
                'Street Address',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _streetController,
                decoration: InputDecoration(
                  hintText: 'e.g., 123 Main Street, Apt 4B',
                  prefixIcon: Icon(Icons.home),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Street address is required';
                  }
                  if (value.trim().length < 5) {
                    return 'Street address must be at least 5 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // City Field
              Text(
                'City',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(
                  hintText: 'e.g., Sana\'a',
                  prefixIcon: Icon(Icons.location_city),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'City is required';
                  }
                  if (value.trim().length < 2) {
                    return 'City must be at least 2 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Country Field
              Text(
                'Country',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _countryController,
                decoration: InputDecoration(
                  hintText: 'e.g., Yemen',
                  prefixIcon: Icon(Icons.public),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Country is required';
                  }
                  if (value.trim().length < 2) {
                    return 'Country must be at least 2 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),

              // Default Address Toggle
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: _isDefault
                          ? AppColors.rating
                          : AppColors.textSecondary,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Set as Default Address',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Use this address for future orders',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isDefault,
                      onChanged: (value) {
                        setState(() => _isDefault = value);
                      },
                      activeColor: AppColors.success,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),

              // Save Button
              ElevatedButton(
                onPressed: _isLoading ? null : _saveAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        _isEditMode ? 'Update Address' : 'Save Address',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              SizedBox(height: 16),

              // Cancel Button
              OutlinedButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: AppColors.border),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeButton(String type, String label, IconData icon) {
    final isSelected = _addressType == type;
    return GestureDetector(
      onTap: () {
        setState(() => _addressType = type);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.textOnPrimary
                  : AppColors.textSecondary,
              size: 32,
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? AppColors.textOnPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
