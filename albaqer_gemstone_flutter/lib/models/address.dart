class Address {
  final int? id;
  final int userId;
  final String addressType; // 'shipping' or 'billing'
  final String streetAddress;
  final String city;
  final String country;
  final bool isDefault;

  Address({
    this.id,
    required this.userId,
    required this.addressType,
    required this.streetAddress,
    required this.city,
    required this.country,
    this.isDefault = false,
  });

  Map<String, dynamic> get addressMap {
    return {
      'id': id,
      'user_id': userId,
      'address_type': addressType,
      'street_address': streetAddress,
      'city': city,
      'country': country,
      'is_default': isDefault ? 1 : 0,
    };
  }
}
