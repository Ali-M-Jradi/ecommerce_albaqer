# Backend API Documentation

## Setup Instructions

1. Install dependencies:
```bash
npm install
```

2. Configure database in `.env` file

3. Start server:
```bash
node server.js
```

## Database Schema

The backend uses PostgreSQL with the following tables:
- `users` - User accounts
- `products` - Product catalog
- `orders` - Customer orders
- `order_items` - Order line items
- `carts` - Shopping carts
- `reviews` - Product reviews
- `payments` - Payment transactions

## API Endpoints

See main README.md for endpoint details.

## Middleware

- **Authentication**: JWT-based auth middleware
- **Validation**: Request validation middleware
- **Error Handling**: Global error handler

## Controllers

- `userController.js` - User management
- `productController.js` - Product operations
- `orderController.js` - Order processing
