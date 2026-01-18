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
          'CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT, email TEXT UNIQUE NOT NULL, password_hash TEXT NOT NULL, full_name TEXT NOT NULL, phone TEXT, role TEXT DEFAULT "user", created_at TEXT, updated_at TEXT, is_active INTEGER DEFAULT 1)',
        );

        // Products Table
        await db.execute(
          'CREATE TABLE products(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, type TEXT NOT NULL, description TEXT, base_price REAL NOT NULL, rating REAL DEFAULT 0, total_reviews INTEGER DEFAULT 0, quantity_in_stock INTEGER NOT NULL DEFAULT 0, image_url TEXT, is_available INTEGER DEFAULT 1, created_at TEXT, updated_at TEXT, metal_type TEXT, metal_color TEXT, metal_purity TEXT, metal_weight_grams REAL, stone_type TEXT, stone_color TEXT, stone_carat REAL, stone_cut TEXT, stone_clarity TEXT)',
        );

        // Cart Table
        await db.execute(
          'CREATE TABLE carts(id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL, created_at TEXT, updated_at TEXT)',
        );

        // Cart Items Table
        await db.execute(
          'CREATE TABLE cart_items(id INTEGER PRIMARY KEY AUTOINCREMENT, cart_id INTEGER NOT NULL, product_id INTEGER NOT NULL, quantity INTEGER NOT NULL DEFAULT 1, price_at_add REAL NOT NULL, tracking_id TEXT)',
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

        // Categories Table
        await db.execute(
          'CREATE TABLE categories(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, description TEXT, parent_id INTEGER)',
        );

        // Product Categories Table (Many-to-Many)
        await db.execute(
          'CREATE TABLE product_categories(product_id INTEGER NOT NULL, category_id INTEGER NOT NULL, PRIMARY KEY(product_id, category_id))',
        );

        // Payments Table
        await db.execute(
          'CREATE TABLE payments(id INTEGER PRIMARY KEY AUTOINCREMENT, order_id INTEGER NOT NULL, payment_method TEXT NOT NULL, transaction_id TEXT, amount REAL NOT NULL, currency TEXT DEFAULT "USD", status TEXT DEFAULT "pending", payment_gateway TEXT, card_last_four TEXT, created_at TEXT)',
        );

        // Insert default categories
        await db.insert('categories', {
          'name': 'Ring',
          'description': 'Rings and bands',
        });
        await db.insert('categories', {
          'name': 'Necklace',
          'description': 'Necklaces and pendants',
        });
        await db.insert('categories', {
          'name': 'Bracelet',
          'description': 'Bracelets and bangles',
        });
        await db.insert('categories', {
          'name': 'Earring',
          'description': 'Earrings and studs',
        });

        print('✅ Default categories inserted');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Add new columns for metal and stone specifications
          await db.execute('ALTER TABLE products ADD COLUMN metal_type TEXT');
          await db.execute('ALTER TABLE products ADD COLUMN metal_color TEXT');
          await db.execute('ALTER TABLE products ADD COLUMN metal_purity TEXT');
          await db.execute(
            'ALTER TABLE products ADD COLUMN metal_weight_grams REAL',
          );
          await db.execute('ALTER TABLE products ADD COLUMN stone_type TEXT');
          await db.execute('ALTER TABLE products ADD COLUMN stone_color TEXT');
          await db.execute('ALTER TABLE products ADD COLUMN stone_carat REAL');
          await db.execute('ALTER TABLE products ADD COLUMN stone_cut TEXT');
          await db.execute(
            'ALTER TABLE products ADD COLUMN stone_clarity TEXT',
          );
        }
        if (oldVersion < 3) {
          // Add new tables to match backend schema
          await db.execute(
            'CREATE TABLE IF NOT EXISTS categories(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, description TEXT, parent_id INTEGER)',
          );
          await db.execute(
            'CREATE TABLE IF NOT EXISTS product_categories(product_id INTEGER NOT NULL, category_id INTEGER NOT NULL, PRIMARY KEY(product_id, category_id))',
          );
          await db.execute(
            'CREATE TABLE IF NOT EXISTS payments(id INTEGER PRIMARY KEY AUTOINCREMENT, order_id INTEGER NOT NULL, payment_method TEXT NOT NULL, transaction_id TEXT, amount REAL NOT NULL, currency TEXT DEFAULT "USD", status TEXT DEFAULT "pending", payment_gateway TEXT, card_last_four TEXT, created_at TEXT)',
          );
        }
        if (oldVersion < 4) {
          // Add role column to users table
          await db.execute(
            'ALTER TABLE users ADD COLUMN role TEXT DEFAULT "user"',
          );
        }
        if (oldVersion < 5) {
          // Add tracking_id column to cart_items table for UUID
          await db.execute(
            'ALTER TABLE cart_items ADD COLUMN tracking_id TEXT',
          );
        }
        if (oldVersion < 6) {
          // Insert default categories if they don't exist
          var categoriesCount = await db.rawQuery(
            'SELECT COUNT(*) FROM categories',
          );
          if (categoriesCount.first.values.first == 0) {
            await db.insert('categories', {
              'name': 'Ring',
              'description': 'Rings and bands',
            });
            await db.insert('categories', {
              'name': 'Necklace',
              'description': 'Necklaces and pendants',
            });
            await db.insert('categories', {
              'name': 'Bracelet',
              'description': 'Bracelets and bangles',
            });
            await db.insert('categories', {
              'name': 'Earring',
              'description': 'Earrings and studs',
            });
            print('✅ Default categories inserted during upgrade');
          }
        }
      },
      // increment version number only when the database scheme changes
      version: 6,
    );
    return db;
  }
}
