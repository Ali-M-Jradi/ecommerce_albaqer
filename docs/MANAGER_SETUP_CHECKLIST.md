# Manager Role - Quick Setup Checklist

## ✅ Implementation Complete!

The manager role system has been fully implemented. Here's what was added:

### Backend Changes

#### 1. Authentication & Authorization
- [x] Added `manager` middleware for manager-only routes
- [x] Added `deliveryMan` middleware for delivery personnel routes
- [x] Added `managerOrAdmin` middleware for shared routes
- File: `middleware/auth.js`

#### 2. Database
- [x] Created migration file: `add_manager_role.sql`
- Added columns: `delivery_man_id`, `assigned_at`
- File: `add_manager_role.sql`

#### 3. User Management
- [x] Added role assignment function
- [x] Added delivery men listing
- [x] Added managers listing
- File: `controllers/userController.js`

#### 4. Order Management (Manager Features)
- [x] Get pending orders
- [x] Get available delivery men
- [x] Assign orders to delivery men
- [x] View delivery man's assigned orders
- [x] Unassign orders if needed
- File: `controllers/orderController.js`

---

## 🚀 Steps to Deploy

### Step 1: Run Database Migration
```bash
cd albaqer_gemstone_backend
psql -U postgres -d albaqer_gemstone_ecommerce_db -f add_manager_role.sql
```

**Or manually in pgAdmin/DBeaver:**
```sql
ALTER TABLE orders ADD COLUMN IF NOT EXISTS delivery_man_id INTEGER REFERENCES users(id) ON DELETE SET NULL;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS assigned_at TIMESTAMP;
CREATE INDEX IF NOT EXISTS idx_orders_delivery_man_id ON orders(delivery_man_id);
```

### Step 2: Start Backend Server
```bash
npm install  # if not already done
npm start    # or 'node server.js'
```

### Step 3: Create Manager & Delivery Users

**Via Admin Account**, assign roles to existing users:

```bash
# Make user ID 2 a manager (adjust ID as needed)
curl -X PUT http://localhost:5000/api/users/2/assign-role \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"role": "manager"}'

# Make user ID 3 a delivery man
curl -X PUT http://localhost:5000/api/users/3/assign-role \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"role": "delivery_man"}'
```

---

## 📱 For Flutter App (Recommended Features)

Add these screens to your Flutter app:

### Manager Dashboard
- [ ] View all pending orders
- [ ] See list of available delivery men
- [ ] Assign orders to delivery men with UI
- [ ] View delivery man performance/assigned orders
- [ ] Reassign orders if needed

### Delivery Man App
- [ ] View my assigned orders
- [ ] Update order status (picked up, in transit, delivered)
- [ ] Navigation/map integration
- [ ] Proof of delivery (photos)

### Sample Flutter Implementation
```dart
// Get pending orders
Future<List<Order>> getPendingOrders(String token) async {
  final response = await http.get(
    Uri.parse('http://YOUR_IP:5000/api/orders/manager/pending'),
    headers: {'Authorization': 'Bearer $token'},
  );
  // Parse response
}

// Assign order
Future<Order> assignOrder(int orderId, int deliveryManId, String token) async {
  final response = await http.put(
    Uri.parse('http://YOUR_IP:5000/api/orders/$orderId/assign-delivery'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({'delivery_man_id': deliveryManId}),
  );
  // Parse response
}
```

---

## 🧪 Test the Endpoints

### 1. Get List of Delivery Men (Manager)
```bash
curl -X GET http://localhost:5000/api/orders/manager/delivery-men \
  -H "Authorization: Bearer MANAGER_TOKEN"
```

### 2. Get Pending Orders (Manager)
```bash
curl -X GET http://localhost:5000/api/orders/manager/pending \
  -H "Authorization: Bearer MANAGER_TOKEN"
```

### 3. Assign Order to Delivery Man
```bash
curl -X PUT http://localhost:5000/api/orders/1/assign-delivery \
  -H "Authorization: Bearer MANAGER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"delivery_man_id": 5}'
```

### 4. Get Orders for Specific Delivery Man
```bash
curl -X GET http://localhost:5000/api/orders/manager/delivery-man/5 \
  -H "Authorization: Bearer MANAGER_TOKEN"
```

---

## 📋 Available Roles

```
role: "customer"      → Regular customer
role: "manager"       → Can manage order delivery
role: "delivery_man"  → Delivers orders
role: "admin"         → Full system access
```

---

## 🔒 Security Features

✅ Role-based access control  
✅ Only managers can assign orders  
✅ Only admins can change user roles  
✅ OrderID and UserID validation  
✅ JWT token verification on all endpoints  

---

## 📚 Documentation

Full documentation available at:
- `docs/MANAGER_ROLE_IMPLEMENTATION.md` - Complete API reference
- Backend files updated with comments

---

## Notes

- `status = "assigned"` when order is given to delivery man
- `assigned_at` timestamp tracks assignment time
- Managers can reassign orders anytime
- Future: Add delivery man app to track deliveries in real-time

---

**Status**: ✅ Ready for testing and deployment!
