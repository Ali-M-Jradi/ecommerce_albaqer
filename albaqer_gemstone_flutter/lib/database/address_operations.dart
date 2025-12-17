import 'package:albaqer_gemstone_flutter/database/database.dart';
import 'package:albaqer_gemstone_flutter/models/address.dart';

// Insert an address into the database
void insertAddress(Address address) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  db.insert('addresses', address.addressMap);
}

// Load all addresses from the database
Future<List<Address>> loadAddresses() async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  final result = await db.query('addresses');
  List<Address> resultList = result.map((row) {
    return Address(
      id: row['id'] as int,
      userId: row['user_id'] as int,
      addressType: row['address_type'] as String,
      streetAddress: row['street_address'] as String,
      city: row['city'] as String,
      country: row['country'] as String,
      isDefault: (row['is_default'] as int) == 1,
    );
  }).toList();
  return resultList;
}

// Load addresses by user ID
Future<List<Address>> loadAddressesByUserId(int userId) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  final result = await db.query(
    'addresses',
    where: 'user_id = ?',
    whereArgs: [userId],
  );
  List<Address> resultList = result.map((row) {
    return Address(
      id: row['id'] as int,
      userId: row['user_id'] as int,
      addressType: row['address_type'] as String,
      streetAddress: row['street_address'] as String,
      city: row['city'] as String,
      country: row['country'] as String,
      isDefault: (row['is_default'] as int) == 1,
    );
  }).toList();
  return resultList;
}

// Load addresses by user ID and type
Future<List<Address>> loadAddressesByUserIdAndType(
  int userId,
  String addressType,
) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  final result = await db.query(
    'addresses',
    where: 'user_id = ? AND address_type = ?',
    whereArgs: [userId, addressType],
  );
  List<Address> resultList = result.map((row) {
    return Address(
      id: row['id'] as int,
      userId: row['user_id'] as int,
      addressType: row['address_type'] as String,
      streetAddress: row['street_address'] as String,
      city: row['city'] as String,
      country: row['country'] as String,
      isDefault: (row['is_default'] as int) == 1,
    );
  }).toList();
  return resultList;
}

// Get default address for a user
Future<Address?> getDefaultAddress(int userId, String addressType) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  final result = await db.query(
    'addresses',
    where: 'user_id = ? AND address_type = ? AND is_default = 1',
    whereArgs: [userId, addressType],
  );
  if (result.isEmpty) {
    return null;
  }
  final row = result.first;
  return Address(
    id: row['id'] as int,
    userId: row['user_id'] as int,
    addressType: row['address_type'] as String,
    streetAddress: row['street_address'] as String,
    city: row['city'] as String,
    country: row['country'] as String,
    isDefault: (row['is_default'] as int) == 1,
  );
}

// Get address by ID
Future<Address?> getAddressById(int id) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  final result = await db.query('addresses', where: 'id = ?', whereArgs: [id]);
  if (result.isEmpty) {
    return null;
  }
  final row = result.first;
  return Address(
    id: row['id'] as int,
    userId: row['user_id'] as int,
    addressType: row['address_type'] as String,
    streetAddress: row['street_address'] as String,
    city: row['city'] as String,
    country: row['country'] as String,
    isDefault: (row['is_default'] as int) == 1,
  );
}

// Update an address
void updateAddress(Address address) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  db.update(
    'addresses',
    address.addressMap,
    where: 'id = ?',
    whereArgs: [address.id],
  );
}

// Set address as default (and unset others)
void setDefaultAddress(int addressId, int userId, String addressType) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();

  // First, unset all default addresses for this user and type
  await db.update(
    'addresses',
    {'is_default': 0},
    where: 'user_id = ? AND address_type = ?',
    whereArgs: [userId, addressType],
  );

  // Then set the specified address as default
  await db.update(
    'addresses',
    {'is_default': 1},
    where: 'id = ?',
    whereArgs: [addressId],
  );
}

// Delete an address
void deleteAddress(Address address) async {
  GemstoneDatabase database = GemstoneDatabase();
  final db = await database.getDatabase();
  db.delete('addresses', where: 'id = ?', whereArgs: [address.id]);
}
