# Database Setup Guide - Al-Baqer Gemstone E-commerce

## 📊 Current Database Architecture

Your project uses a **dual database architecture**:

### 1. **Local SQLite Database** (Flutter App)
- **Location**: Local on mobile device/emulator
- **Technology**: SQLite via `sqflite` package
- **Database File**: `albaqer_gemstone.db`
- **Purpose**: Offline-first mobile data storage
- **Tables**: users, products, stones, metals, carts, cart_items, orders, order_items, addresses, wishlists, reviews

### 2. **Backend PostgreSQL Database** (Node.js Server)
- **Location**: PostgreSQL server (localhost or remote)
- **Technology**: PostgreSQL via `pg` package
- **Database Name**: `albaqer_gemstone_ecommerce_db` (configurable)
- **Purpose**: Centralized server-side data management and API serving
- **Port**: 5432 (default PostgreSQL port)

---

## 🔍 Project Structure Overview

```
ecommerce_albaqer/
├── albaqer_gemstone_backend/       # Node.js + Express + PostgreSQL
│   ├── server.js                   # Main server file (Port 3000)
│   ├── db/
│   │   └── connection.js          # PostgreSQL connection pool
│   ├── controllers/               # Business logic
│   ├── routes/                    # API routes
│   └── middleware/                # Auth, validation, error handling
│
└── albaqer_gemstone_flutter/      # Flutter Mobile App
    ├── lib/
    │   ├── database/              # Local SQLite operations
    │   │   ├── database.dart      # SQLite database setup
    │   │   ├── init_sample_data.dart  # Sample data initializer
    │   │   └── *_operations.dart  # CRUD operations for local DB
    │   └── services/              # API calls to backend
    │       ├── product_service.dart   # HTTP requests to backend
    │       ├── user_service.dart
    │       └── order_service.dart
```

---

## ✅ Current Status

### Local SQLite Database (Flutter)
- ✅ **Working**: Database is initialized on app startup
- ✅ **Sample Data**: Automatically populated in `main.dart` via `initializeSampleData()`
- ✅ **CRUD Operations**: Available in `lib/database/*_operations.dart`
- ✅ **Schema Version**: 2 (includes metal and stone specifications)

### Backend PostgreSQL Database
- ⚠️ **Not Configured**: Missing `.env` file with database credentials
- ⚠️ **Not Running**: PostgreSQL database needs to be set up
- ✅ **Code Ready**: Connection pool configured in `db/connection.js`
- ✅ **API Endpoints**: RESTful API ready in backend

---

## 🚀 How to Set Up Backend PostgreSQL Database

### Step 1: Install PostgreSQL

**Windows:**
```powershell
# Download from: https://www.postgresql.org/download/windows/
# Or use Chocolatey:
choco install postgresql
```

**Verify Installation:**
```powershell
psql --version
```

### Step 2: Create Database

Open PostgreSQL command line (psql) or pgAdmin:

```sql
-- Connect as postgres superuser
CREATE DATABASE albaqer_gemstone_ecommerce_db;

-- Connect to the database
\c albaqer_gemstone_ecommerce_db

-- Create tables (schema)
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    is_admin BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    type VARCHAR(50) NOT NULL,
    description TEXT,
    base_price DECIMAL(10,2) NOT NULL,
    rating DECIMAL(3,2) DEFAULT 0,
    total_reviews INTEGER DEFAULT 0,
    quantity_in_stock INTEGER NOT NULL DEFAULT 0,
    image_url TEXT,
    is_available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    metal_type VARCHAR(50),
    metal_color VARCHAR(50),
    metal_purity VARCHAR(20),
    metal_weight_grams DECIMAL(10,2),
    stone_type VARCHAR(50),
    stone_color VARCHAR(50),
    stone_carat DECIMAL(10,2),
    stone_cut VARCHAR(50),
    stone_clarity VARCHAR(20)
);

CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    tax_amount DECIMAL(10,2) DEFAULT 0,
    shipping_cost DECIMAL(10,2) DEFAULT 0,
    discount_amount DECIMAL(10,2) DEFAULT 0,
    status VARCHAR(50) DEFAULT 'pending',
    shipping_address_id INTEGER,
    billing_address_id INTEGER,
    tracking_number VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products(id) ON DELETE SET NULL,
    quantity INTEGER NOT NULL,
    price_at_purchase DECIMAL(10,2) NOT NULL
);

CREATE TABLE addresses (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    address_type VARCHAR(20) NOT NULL,
    street_address TEXT NOT NULL,
    city VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    is_default BOOLEAN DEFAULT FALSE
);

-- Add indexes for performance
CREATE INDEX idx_products_type ON products(type);
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
```

### Step 3: Create `.env` File

Create a file named `.env` in `albaqer_gemstone_backend/` directory:

```env
# Server Configuration
PORT=3000
NODE_ENV=development

# PostgreSQL Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=your_postgres_password_here
DB_NAME=albaqer_gemstone_ecommerce_db

# JWT Secret (generate a random string)
JWT_SECRET=your_super_secret_jwt_key_change_this_in_production
JWT_EXPIRES_IN=7d
```

**Important**: Replace `your_postgres_password_here` with your actual PostgreSQL password!

### Step 4: Install Backend Dependencies

```powershell
cd "C:\Users\hp 15\Desktop\flutter_university\ecommerce_albaqer\albaqer_gemstone_backend"
npm install
```

### Step 5: Start the Backend Server

```powershell
node server.js
```

You should see:
```
✅ Connected to PostgreSQL database
🚀 Server running on port 3000
📊 Environment: development
🌐 Accessible at: http://localhost:3000 and http://10.0.2.2:3000
```

### Step 6: Test Database Connection

Open a browser or use PowerShell:

```powershell
# Test health endpoint
curl http://localhost:3000/api/health

# Test database connection
curl http://localhost:3000/api/test-db
```

Expected response:
```json
{
  "success": true,
  "message": "Database connection successful",
  "timestamp": "2025-12-28T..."
}
```

---

## 🔄 How Both Databases Work in Parallel

### Architecture Flow

```
┌─────────────────┐
│  Flutter App    │
│  (Mobile)       │
└────────┬────────┘
         │
         ├─────────────┐
         │             │
         ▼             ▼
┌─────────────┐  ┌──────────────┐
│  Local      │  │  Backend API │
│  SQLite DB  │  │  (HTTP)      │
│  (Offline)  │  │              │
└─────────────┘  └──────┬───────┘
                        │
                        ▼
                 ┌──────────────┐
                 │  PostgreSQL  │
                 │  Database    │
                 │  (Server)    │
                 └──────────────┘
```

### Current Implementation

#### 1. **Local SQLite Database** (`lib/database/`)
- **Used for**: Offline data persistence
- **Operations**: Direct SQL queries via `sqflite`
- **Files**: `product_operations.dart`, `user_operations.dart`, etc.
- **Example**:
  ```dart
  // Load products from local SQLite
  Future<List<Product>> loadProducts() async {
    GemstoneDatabase database = GemstoneDatabase();
    final db = await database.getDatabase();
    final result = await db.query('products');
    // ... map to Product objects
  }
  ```

#### 2. **Backend API Services** (`lib/services/`)
- **Used for**: Server-side operations, sync, multi-user data
- **Operations**: HTTP requests to Node.js backend
- **Files**: `product_service.dart`, `user_service.dart`, etc.
- **Base URL**: `http://10.0.2.2:3000/api` (Android Emulator)
- **Example**:
  ```dart
  // Fetch products from backend API
  Future<List<Product>> fetchAllProducts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/products')
    );
    // ... parse JSON response
  }
  ```

### Using DataManager for Parallel Operation

The `DataManager` class (created in `lib/services/data_manager.dart`) handles both databases intelligently:

**Key Features:**
- ✅ Offline-first strategy with smart caching
- ✅ Automatic backend sync when cache is stale
- ✅ Configurable data sources (local, backend, auto)
- ✅ Force refresh option for pull-to-refresh
- ✅ Seamless fallback on network errors

**Usage:**
```dart
import 'package:albaqer_gemstone_flutter/services/data_manager.dart';

DataManager manager = DataManager();

// Auto mode (offline-first with smart sync)
List<Product> products = await manager.getProducts();

// Force refresh from backend
List<Product> freshProducts = await manager.getProducts(forceRefresh: true);

// Explicit local-only mode
List<Product> cachedProducts = await manager.getProducts(source: DataSource.local);

// Manual sync (for pull-to-refresh)
bool synced = await manager.syncWithBackend();
```

See the complete implementation in [lib/services/data_manager.dart](albaqer_gemstone_flutter/lib/services/data_manager.dart).

---

## 🔧 Configuration Changes Needed

### DataManager is Already Created!

The `DataManager` class is already implemented at `lib/services/data_manager.dart` with:
      } catch (e) {
        print('Backend fetch failed, using cache: $e');
      }
    }
    
    // Fallback to local database
    return await loadProducts();
  }
  
  Future<void> _cacheProducts(List<Product> products) async {
    for (var product in products) {
      await insertProduct(product);
    }
  }
}
```

---

## 📝 Quick Start Checklist

- [ ] Install PostgreSQL on your machine
- [ ] Create `albaqer_gemstone_ecommerce_db` database
- [ ] Run SQL schema creation script
- [ ] Create `.env` file in backend folder
- [ ] Install backend dependencies (`npm install`)
- [ ] Start backend server (`node server.js`)
- [ ] Test backend connection (`curl http://localhost:3000/api/test-db`)
- [ ] Update Flutter app to use `DataManager` for smart data fetching
- [ ] Test Flutter app in emulator

---

## 🔍 Troubleshooting

### Backend won't connect to PostgreSQL

```powershell
# Check if PostgreSQL is running
Get-Service postgresql*

# Start PostgreSQL service
Start-Service postgresql-x64-16  # Version may vary
```

### Flutter can't reach backend

- ✅ Use `10.0.2.2:3000` for Android Emulator
- ✅ Use `localhost:3000` for iOS Simulator
- ✅ Use your computer's IP (e.g., `192.168.1.x:3000`) for physical devices

### Port 3000 already in use

```powershell
# Find process using port 3000
netstat -ano | findstr :3000

# Kill the process (replace PID)
taskkill /PID <PID> /F
```

---

## 🎯 Benefits of This Setup

1. **Offline Support**: App works without internet via SQLite
2. **Real-time Sync**: Backend provides live data updates
3. **Multi-user**: PostgreSQL handles concurrent users
4. **Scalability**: Backend can be deployed to cloud
5. **Data Security**: Centralized authentication and authorization
6. **Performance**: Local cache reduces API calls

---

## 📚 Next Steps

1. **Implement Sync Logic**: Create `DataManager` class
2. **Add Network Detection**: Use `connectivity_plus` package
3. **Handle Conflicts**: Implement conflict resolution for offline edits
4. **Add Authentication**: Use JWT tokens from backend
5. **Optimize Queries**: Add pagination and filtering
6. **Deploy Backend**: Use services like Railway, Render, or AWS

---

## 🔗 Additional Resources

- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Node.js pg Package](https://node-postgres.com/)
- [Flutter sqflite Package](https://pub.dev/packages/sqflite)
- [Backend API Endpoints Guide](./albaqer_gemstone_backend/API_ENDPOINTS_GUIDE.md)
- [Backend README](./albaqer_gemstone_backend/BACKEND_README.md)
