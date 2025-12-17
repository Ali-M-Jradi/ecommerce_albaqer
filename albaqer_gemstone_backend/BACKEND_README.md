# Backend API - Al-Baqer Gemstone E-commerce

## ✅ Completed Backend Improvements

### 1. **Organized Project Structure**
```
albaqer_gemstone_backend/
├── controllers/          # Business logic
│   ├── productController.js
│   ├── userController.js
│   └── orderController.js
├── routes/              # Route definitions
│   ├── productRoutes.js
│   ├── userRoutes.js
│   └── orderRoutes.js
├── middleware/          # Middleware functions
│   ├── auth.js         # Authentication & authorization
│   ├── validation.js   # Input validation rules
│   └── errorHandler.js # Error handling
├── db/                  # Database configuration
│   └── connection.js
└── server.js           # Main server file
```

### 2. **Authentication & Authorization**
- ✅ JWT token-based authentication
- ✅ Password hashing with bcryptjs
- ✅ Protected routes (require authentication)
- ✅ Admin-only routes
- ✅ Token generation and verification

### 3. **Input Validation**
- ✅ express-validator integration
- ✅ Product validation rules
- ✅ User registration/login validation
- ✅ Order validation
- ✅ ID parameter validation
- ✅ Custom validation error responses

### 4. **Error Handling**
- ✅ Global error handler middleware
- ✅ Async error handling wrapper
- ✅ 404 not found handler
- ✅ PostgreSQL-specific error handling
- ✅ Development vs production error responses

## 📋 API Endpoints

### **Products** (`/api/products`)
- `GET /` - Get all products (Public)
- `GET /search` - Search products (Public)
- `GET /:id` - Get single product (Public)
- `POST /` - Create product (Admin only)
- `PUT /:id` - Update product (Admin only)
- `DELETE /:id` - Delete product (Admin only)

### **Users** (`/api/users`)
- `POST /register` - Register new user (Public)
- `POST /login` - Login user (Public)
- `GET /profile` - Get user profile (Private)
- `PUT /profile` - Update profile (Private)
- `GET /` - Get all users (Admin only)

### **Orders** (`/api/orders`)
- `GET /my-orders` - Get user's orders (Private)
- `GET /:id` - Get single order (Private)
- `POST /` - Create order (Private)
- `GET /` - Get all orders (Admin only)
- `PUT /:id/status` - Update order status (Admin only)
- `DELETE /:id` - Delete order (Admin only)

## 🔐 Authentication Flow

### Register:
```bash
POST /api/users/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123",
  "full_name": "John Doe",
  "phone": "1234567890"
}
```

### Login:
```bash
POST /api/users/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}

Response:
{
  "success": true,
  "message": "Login successful",
  "data": {
    "id": 1,
    "email": "user@example.com",
    "full_name": "John Doe",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

### Using Protected Routes:
```bash
GET /api/users/profile
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

## 🛡️ Security Features

1. **JWT Tokens** - 30-day expiration
2. **Password Hashing** - bcrypt with 10 salt rounds
3. **Input Validation** - All inputs validated before processing
4. **Role-based Access** - Admin vs customer permissions
5. **Error Masking** - Sensitive errors hidden in production

## 🚀 Running the Server

```bash
# Install dependencies
npm install

# Start server
node server.js

# Or with nodemon (recommended for development)
npm install -g nodemon
nodemon server.js
```

## 📝 Environment Variables

Add to `.env` file:
```
DB_USER=postgres
DB_HOST=localhost
DB_NAME=albaqer_gemstone_ecommerce_db
DB_PASSWORD=your_password
DB_PORT=5432
PORT=3000
NODE_ENV=development
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
```

## 📦 Dependencies

- **express** - Web framework
- **pg** - PostgreSQL client
- **cors** - Cross-origin resource sharing
- **dotenv** - Environment variables
- **bcryptjs** - Password hashing
- **jsonwebtoken** - JWT authentication
- **express-validator** - Input validation

## ✨ Next Steps

- [ ] Add refresh tokens for better security
- [ ] Implement rate limiting
- [ ] Add request logging
- [ ] Create API documentation with Swagger
- [ ] Add unit and integration tests
- [ ] Implement caching with Redis
- [ ] Add file upload for product images
