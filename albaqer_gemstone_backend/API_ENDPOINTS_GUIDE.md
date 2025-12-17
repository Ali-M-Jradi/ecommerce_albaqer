# API Endpoints Testing Guide

Server is running on: **http://localhost:3000**

---

## 🔓 PUBLIC ENDPOINTS (No Authentication Required)

### 1. Health Check
```
GET http://localhost:3000/api/health
```

### 2. Database Test
```
GET http://localhost:3000/api/test-db
```

### 3. Get All Products
```
GET http://localhost:3000/api/products
```

### 4. Search Products
```
GET http://localhost:3000/api/products/search?query=ruby&gemstone_type=ruby&minPrice=100&maxPrice=1000
```

### 5. Get Single Product
```
GET http://localhost:3000/api/products/1
```
Replace `1` with actual product ID.

### 6. Register New User
```
POST http://localhost:3000/api/users/register
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "password123",
  "full_name": "John Doe",
  "phone": "1234567890"
}
```

### 7. Login User
```
POST http://localhost:3000/api/users/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "password123"
}
```
**Response includes JWT token** - save this token for protected routes!

---

## 🔐 PROTECTED ENDPOINTS (Require Authentication)

**Add this header to all requests:**
```
Authorization: Bearer YOUR_JWT_TOKEN_HERE
```

### 8. Get My Profile
```
GET http://localhost:3000/api/users/profile
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### 9. Update My Profile
```
PUT http://localhost:3000/api/users/profile
Authorization: Bearer YOUR_JWT_TOKEN
Content-Type: application/json

{
  "full_name": "John Updated",
  "phone": "9876543210",
  "address": "123 Main St"
}
```

### 10. Get My Orders
```
GET http://localhost:3000/api/orders/my-orders
Authorization: Bearer YOUR_JWT_TOKEN
```

### 11. Get Single Order
```
GET http://localhost:3000/api/orders/1
Authorization: Bearer YOUR_JWT_TOKEN
```
You can only see your own orders unless you're an admin.

### 12. Create New Order
```
POST http://localhost:3000/api/orders
Authorization: Bearer YOUR_JWT_TOKEN
Content-Type: application/json

{
  "total_amount": 599.99,
  "shipping_address": "123 Main St, City",
  "payment_method": "credit_card",
  "status": "pending"
}
```

---

## 👑 ADMIN-ONLY ENDPOINTS (Require Admin Role)

**Must be logged in as admin user (role = 'admin')**

### 13. Get All Users
```
GET http://localhost:3000/api/users/all
Authorization: Bearer ADMIN_JWT_TOKEN
```

### 14. Get All Orders
```
GET http://localhost:3000/api/orders/all
Authorization: Bearer ADMIN_JWT_TOKEN
```

### 15. Create Product
```
POST http://localhost:3000/api/products
Authorization: Bearer ADMIN_JWT_TOKEN
Content-Type: application/json

{
  "name": "Ruby Gemstone",
  "description": "Beautiful natural ruby",
  "price": 299.99,
  "gemstone_type": "ruby",
  "color": "red",
  "weight": 2.5,
  "origin": "Myanmar",
  "clarity": "VVS",
  "cut": "oval",
  "stock_quantity": 10,
  "is_available": true
}
```

### 16. Update Product
```
PUT http://localhost:3000/api/products/1
Authorization: Bearer ADMIN_JWT_TOKEN
Content-Type: application/json

{
  "name": "Updated Ruby",
  "price": 349.99,
  "stock_quantity": 8
}
```

### 17. Delete Product
```
DELETE http://localhost:3000/api/products/1
Authorization: Bearer ADMIN_JWT_TOKEN
```

### 18. Update Order Status
```
PUT http://localhost:3000/api/orders/1/status
Authorization: Bearer ADMIN_JWT_TOKEN
Content-Type: application/json

{
  "status": "shipped"
}
```
Valid statuses: `pending`, `processing`, `shipped`, `delivered`, `cancelled`

### 19. Delete Order
```
DELETE http://localhost:3000/api/orders/1
Authorization: Bearer ADMIN_JWT_TOKEN
```

---

## 📝 Testing Workflow

### Step 1: Register & Login
1. Register: `POST /api/users/register`
2. Login: `POST /api/users/login`
3. Copy the `token` from login response

### Step 2: Test Protected Routes
Use the token in Authorization header:
```
Authorization: Bearer YOUR_TOKEN_HERE
```

### Step 3: Test Admin Routes
1. Manually change a user's role to 'admin' in database:
   ```sql
   UPDATE users SET role = 'admin' WHERE email = 'admin@example.com';
   ```
2. Login as that user
3. Use the admin token for admin endpoints

---

## 🎯 Quick Test with cURL

### Register:
```bash
curl -X POST http://localhost:3000/api/users/register \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"test@example.com\",\"password\":\"pass123\",\"full_name\":\"Test User\",\"phone\":\"1234567890\"}"
```

### Login:
```bash
curl -X POST http://localhost:3000/api/users/login \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"test@example.com\",\"password\":\"pass123\"}"
```

### Get Products (Public):
```bash
curl http://localhost:3000/api/products
```

### Get Profile (Protected):
```bash
curl http://localhost:3000/api/users/profile \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

---

## ❌ Common Errors

### 401 Unauthorized
- Missing or invalid token
- Token expired (30 days)
- Not logged in

### 403 Forbidden
- Trying to access admin route without admin role
- Trying to access another user's order

### 400 Bad Request
- Missing required fields
- Invalid data format
- Validation errors

### 404 Not Found
- Invalid product/order/user ID
- Route doesn't exist

---

## 🔧 Recommendations

I suggest using **Thunder Client** (VS Code extension) or **Postman** to test these endpoints visually instead of cURL.

### Install Thunder Client:
1. Open VS Code Extensions (Ctrl+Shift+X)
2. Search "Thunder Client"
3. Click Install

Then you can easily test all endpoints with a nice GUI!
