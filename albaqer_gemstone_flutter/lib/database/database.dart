import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class GemstoneDatabase {
  // this method returns a Future<Database> object, so it should be an async method
  Future<Database> getDatabase() async {
    // get the default databases location
    String dbPath = await getDatabasesPath();
    // If the database is already created, get an instance of it.
    // If it is not there, onCreate is executed
    Database db = await openDatabase(
      // to avoid errors in the database path use join method
      // the database name should always end with .db
      join(dbPath, 'albaqer_gemstone.db'),
      // executed only when the database is not there or when the version is incremented
      onCreate: (db, version) async {
        // Users Table
        await db.execute(
          'CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT, email TEXT UNIQUE NOT NULL, password_hash TEXT NOT NULL, full_name TEXT NOT NULL, phone TEXT, created_at TEXT, updated_at TEXT, is_active INTEGER DEFAULT 1)',
        );

        // Products Table
        await db.execute(
          'CREATE TABLE products(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, type TEXT NOT NULL, description TEXT, base_price REAL NOT NULL, rating REAL DEFAULT 0, total_reviews INTEGER DEFAULT 0, quantity_in_stock INTEGER NOT NULL DEFAULT 0, image_url TEXT, is_available INTEGER DEFAULT 1, created_at TEXT, updated_at TEXT)',
        );

        // Stones Table
        await db.execute(
          'CREATE TABLE stones(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, color TEXT, cut TEXT, origin TEXT, carat_weight REAL, size_mm TEXT, clarity TEXT, price REAL NOT NULL, image_url TEXT, rating REAL DEFAULT 0)',
        );

        // Metals Table
        await db.execute(
          'CREATE TABLE metals(id INTEGER PRIMARY KEY AUTOINCREMENT, type TEXT NOT NULL, purity TEXT, color TEXT, weight_grams REAL, price_per_gram REAL, total_price REAL)',
        );

        // Cart Table
        await db.execute(
          'CREATE TABLE carts(id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL, created_at TEXT, updated_at TEXT)',
        );

        // Cart Items Table
        await db.execute(
          'CREATE TABLE cart_items(id INTEGER PRIMARY KEY AUTOINCREMENT, cart_id INTEGER NOT NULL, product_id INTEGER NOT NULL, quantity INTEGER NOT NULL DEFAULT 1, price_at_add REAL NOT NULL)',
        );

        // Orders Table
        await db.execute(
          'CREATE TABLE orders(id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL, order_number TEXT UNIQUE NOT NULL, total_amount REAL NOT NULL, tax_amount REAL DEFAULT 0, shipping_cost REAL DEFAULT 0, discount_amount REAL DEFAULT 0, status TEXT DEFAULT "pending", shipping_address_id INTEGER, billing_address_id INTEGER, tracking_number TEXT, notes TEXT, created_at TEXT, updated_at TEXT)',
        );

        // Order Items Table
        await db.execute(
          'CREATE TABLE order_items(id INTEGER PRIMARY KEY AUTOINCREMENT, order_id INTEGER NOT NULL, product_id INTEGER NOT NULL, quantity INTEGER NOT NULL, price_at_purchase REAL NOT NULL)',
        );

        // Addresses Table
        await db.execute(
          'CREATE TABLE addresses(id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL, address_type TEXT NOT NULL, street_address TEXT NOT NULL, city TEXT NOT NULL, country TEXT NOT NULL, is_default INTEGER DEFAULT 0)',
        );

        // Wishlist Table
        await db.execute(
          'CREATE TABLE wishlists(id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL, product_id INTEGER NOT NULL, added_at TEXT)',
        );

        // Reviews Table
        await db.execute(
          'CREATE TABLE reviews(id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL, product_id INTEGER NOT NULL, order_id INTEGER, rating INTEGER NOT NULL, title TEXT, comment TEXT, is_verified_purchase INTEGER DEFAULT 0, helpful_count INTEGER DEFAULT 0, created_at TEXT, updated_at TEXT)',
        );
      },
      // increment version number only when the database scheme changes
      version: 1,
    );
    return db;
  }
}
