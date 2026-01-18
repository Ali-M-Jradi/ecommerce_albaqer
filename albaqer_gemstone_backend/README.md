# AlBaqer Gemstone Backend API

Node.js backend server for the AlBaqer Islamic Gemstone E-commerce platform.

## 🚀 Quick Start

```bash
npm install
node server.js
```

Server runs on `http://localhost:3000`

## 📚 API Documentation

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - User login

### Products
- `GET /api/products` - Get all products
- `GET /api/products/:id` - Get product by ID
- `POST /api/products` - Create product (Admin)
- `PUT /api/products/:id` - Update product (Admin)
- `DELETE /api/products/:id` - Delete product (Admin)

### Orders
- `GET /api/orders` - Get user orders
- `GET /api/orders/:id` - Get order by ID
- `POST /api/orders` - Create new order

### Users
- `GET /api/users/profile` - Get user profile
- `PUT /api/users/profile` - Update profile

## 🗄️ Database

PostgreSQL database: `albaqer_gemstone_ecommerce_db`

## 🔧 Environment Variables

Create `.env` file:
```
DB_HOST=localhost
DB_NAME=albaqer_gemstone_ecommerce_db
DB_USER=postgres
DB_PASSWORD=your_password
JWT_SECRET=your_jwt_secret
PORT=3000
```

## 📖 Full Documentation

See the [docs](./docs) folder for detailed documentation.
