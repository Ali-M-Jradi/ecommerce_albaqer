# E-Commerce Albaqer

A complete e-commerce platform with Node.js backend and Flutter mobile app.

## ✅ Project Status

- **Backend**: ✅ Fully configured and operational
- **Database**: ✅ PostgreSQL backend + SQLite local storage
- **Flutter App**: ✅ Fully functional with 10 screens
- **API**: ✅ Core endpoints (Products, Users, Orders) with JWT authentication
- **Environment**: ⚠️ Requires .env configuration

## 📊 System Architecture

```
┌──────────────────────────┐
│   Flutter Mobile App     │
│  (Android/iOS/Web)       │
└────────────┬─────────────┘
             │
      ┌──────┴──────┐
      ▼             ▼
┌──────────┐  ┌─────────────┐
│  Local   │  │  Backend    │
│  SQLite  │  │  API        │
│  (Cache) │  │  (Node.js)  │
└──────────┘  └──────┬──────┘
                     │
                     ▼
              ┌─────────────┐
              │ PostgreSQL  │
              │  Database   │
              │  (12 Tables)│
              └─────────────┘
```

## Project Structure

```
ecommerce_albaqer/
├── albaqer_gemstone_backend/     # Node.js + Express + PostgreSQL
│   ├── controllers/              # API business logic
│   ├── routes/                   # API route definitions
│   ├── middleware/               # Auth, validation, error handling
│   ├── db/                       # Database connection
│   ├── server.js                 # Main server file
│   └── .env                      # ✅ Configuration (already set up)
│
├── albaqer_gemstone_flutter/     # Flutter mobile app
│   ├── lib/
│   │   ├── main.dart            # App entry point
│   │   ├── models/              # Data models
│   │   ├── screens/             # UI screens
│   │   ├── services/            # Backend API services
│   │   │   └── data_manager.dart # ⭐ Smart data sync
│   │   └── database/            # Local SQLite operations
│   └── pubspec.yaml
│
└── Documentation/
    ├── QUICK_REFERENCE.md        # 🎯 Start here!
    ├── INTEGRATION_GUIDE.md      # Detailed integration steps
    ├── DATABASE_SUMMARY.md       # Database overview
    └── DATABASE_SETUP_GUIDE.md   # Complete setup documentation
```

## 🚀 Quick Start

### Start Backend Server

```bash
cd albaqer_gemstone_backend
npm install  # First time only
node server.js
```

Server will run on: http://localhost:3000

### Run Flutter App

```bash
cd albaqer_gemstone_flutter
flutter pub get  # First time only
flutter run
```

## 📱 Flutter App Features

### ✅ Implemented
- Local SQLite database for offline operation
- Backend API integration with smart caching (DataManager)
- Product catalog with metal/stone specifications
- Shopping cart functionality (local only)
- User authentication (register/login with JWT)
- Order management (create and view orders)
- Admin panel (add/edit/delete products)
- Product search functionality
- Product detail views
- Home screen with featured products

### 📦 Models Ready (Backend API Not Yet Implemented)
- Product reviews and ratings
- Wishlist functionality
- Multiple addresses support

## 🔧 Backend API Features

### Database
- **Backend**: PostgreSQL database (12+ tables)
- **Frontend**: Local SQLite database (mirrors backend structure)

### ✅ Implemented API Endpoints

#### Products (`/api/products`)
- `GET /api/products` - Get all products
- `GET /api/products/categories` - Get product categories
- `GET /api/products/search` - Search products
- `GET /api/products/:id` - Get product by ID
- `POST /api/products` - Create product (admin only)
- `PUT /api/products/:id` - Update product (admin only)
- `DELETE /api/products/:id` - Delete product (admin only)

#### Users (`/api/users`)
- `POST /api/users/register` - User registration
- `POST /api/users/login` - User login (returns JWT)
- `GET /api/users/profile` - Get user profile (protected)
- `PUT /api/users/profile` - Update user profile (protected)
- `GET /api/users/all` - Get all users (admin only)

#### Orders (`/api/orders`)
- `GET /api/orders/my-orders` - Get user's orders (protected)
- `GET /api/orders/all` - Get all orders (admin only)
- `GET /api/orders/:id` - Get order by ID (protected)
- `POST /api/orders` - Create new order (protected)
- `PUT /api/orders/:id/status` - Update order status (admin only)
- `DELETE /api/orders/:id` - Delete order (admin only)

#### Health & Testing
- `GET /api/health` - Server health check
- `GET /api/test-db` - Database connection test

## 📚 Documentation

- **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** - Quick commands and setup verification
- **[INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md)** - Detailed Flutter-Backend integration
- **[DATABASE_SUMMARY.md](DATABASE_SUMMARY.md)** - Database architecture overview
- **[DATABASE_SETUP_GUIDE.md](DATABASE_SETUP_GUIDE.md)** - Complete setup documentation
- **[Backend API Guide](albaqer_gemstone_backend/API_ENDPOINTS_GUIDE.md)** - API endpoints reference
- **[Backend README](albaqer_gemstone_backend/BACKEND_README.md)** - Backend documentation

## 🧪 Testing

### Backend API Tests
```bash
# Test health
curl http://localhost:3000/api/health

# Test database connection
curl http://localhost:3000/api/test-db

# Get all products
curl http://localhost:3000/api/products

# Use provided test script
cd albaqer_gemstone_backend
.\test-api.ps1
```

### Flutter App Tests
```bash
cd albaqer_gemstone_flutter
flutter test
```

## 🔐 Environment Configuration

### Backend (.env)
**⚠️ Required**: Create a `.env` file in the `albaqer_gemstone_backend/` directory:

```env
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=your_password
DB_NAME=albaqer_gemstone_ecommerce_db
PORT=3000
JWT_SECRET=your_jwt_secret_here
NODE_ENV=development
```

### Flutter (lib/services/)
```dart
// For Android Emulator
final String baseUrl = 'http://10.0.2.2:3000/api';

// For iOS Simulator
final String baseUrl = 'http://localhost:3000/api';

// For Physical Device
final String baseUrl = 'http://YOUR_COMPUTER_IP:3000/api';
```

## 💻 Technologies

### Backend
- **Runtime:** Node.js 
- **Framework:** Express.js
- **Database:** PostgreSQL
- **Authentication:** JWT (JSON Web Tokens)
- **Validation:** express-validator
- **Security:** bcryptjs for password hashing

### Flutter App
- **Framework:** Flutter/Dart
- **Local Database:** SQLite (sqflite package)
- **HTTP Client:** http package
- **State Management:** Built-in StatefulWidget
- **Offline Support:** Local SQLite caching

### Development Tools
- **API Testing:** PowerShell scripts, curl
- **Database Tool:** pgAdmin, psql
- **Version Control:** Git

## 🤝 Contributing

This is an educational project. Feel free to:
- Report bugs
- Suggest features
- Submit pull requests
- Use it as a learning reference

## Authors

- Ali-M-Jradi

## License

ISC
