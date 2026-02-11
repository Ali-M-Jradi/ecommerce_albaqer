# 🚚 Delivery Man Role - Complete Guide

**Status:** ✅ Production Ready  
**Last Updated:** February 11, 2026  
**Version:** 1.0

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Features](#features)
3. [Setup Guide](#setup-guide)
4. [User Management](#user-management)
5. [Order Workflow](#order-workflow)
6. [Authorization & Security](#authorization--security)
7. [Troubleshooting](#troubleshooting)
8. [Technical Details](#technical-details)

---

## 🎯 Overview

The Delivery Man role completes the order fulfillment workflow, allowing delivery personnel to:
- View orders assigned to them
- Contact customers via phone or SMS
- Navigate to delivery addresses using Google Maps
- View order items and product details
- Update order status (Start Delivery, Mark Delivered)

The delivery role integrates seamlessly with the admin and manager roles, providing a complete end-to-end order management system.

---

## ✨ Features

### 📊 Delivery Dashboard
- **Order Statistics**: View assigned orders, in-transit orders, and deliveries completed today
- **Quick Actions**: Navigate to My Deliveries, Profile, and Logout
- **Green Theme**: Consistent branding with `Colors.green[700]`

### 📦 My Deliveries
- **Filtered Order List**: Only shows orders assigned to the logged-in delivery person
- **Order Cards**: Display order number, customer name, status, amount, and date
- **Status-Based Styling**: Visual indicators for different order states
- **Tap to View Details**: Navigate to detailed order view

### 📋 Order Detail Screen
Comprehensive order information including:

#### 👤 Customer Information
- Full name, phone number, and email address
- **Tap-to-Call**: Opens phone dialer with customer number
- **Tap-to-SMS**: Opens messaging app with customer number
- Conditional rendering (only shows available contact methods)

#### 📍 Shipping Address
- Complete address display (street, city, state, postal code, country)
- **"Open in Maps" Button**: Launches Google Maps with address coordinates
- Automatic navigation to external maps application

#### 🛍️ Order Items
- Product image with fallback for missing images
- Product name and details
- Quantity and individual price
- Calculated total per item
- Full order item list

#### 🔄 Status Actions
- **Start Delivery**: Changes status from `assigned` to `in_transit`
- **Mark Delivered**: Changes status from `in_transit` to `delivered`
- Status workflow validation prevents backwards transitions

---

## 🛠️ Setup Guide

### 1. Database Setup

The delivery role uses existing database tables with these fields:

**Orders Table:**
```sql
-- Already includes:
delivery_man_id INTEGER REFERENCES users(id)
assigned_at TIMESTAMP
status VARCHAR (pending, confirmed, assigned, in_transit, delivered, cancelled)
```

**Users Table:**
```sql
-- Supports role:
role VARCHAR (customer, admin, manager, delivery_man)
```

No additional migrations needed - the schema supports delivery features.

### 2. Backend Configuration

The backend endpoints are ready to use:

**Delivery Endpoints:**
- `GET /api/orders/delivery/my-deliveries` - Get orders assigned to logged-in delivery person
- `GET /api/orders/:id/items` - Get order items with product details (requires authorization)
- `PUT /api/orders/:id/status` - Update order status (adminOrDelivery middleware)

**Address Endpoint:**
- `GET /api/addresses/:id` - Get shipping address (extended for delivery_man role)

**Authorization:**
- JWT token required for all endpoints
- Role-based access control enforced
- Entity-level authorization (delivery person must be assigned to order)

### 3. Flutter App Update

Hot reload or restart the app after pulling the latest code:

```bash
cd albaqer_gemstone_flutter
flutter pub get
flutter run
```

**New Screens:**
- `lib/screens/delivery_dashboard_screen.dart`
- `lib/screens/delivery_orders_screen.dart`
- `lib/screens/delivery_order_detail_screen.dart`

**Updated Services:**
- `lib/services/order_service.dart` - Added `getOrderItems()`
- `lib/services/address_service.dart` - Added `getAddressById()`

**Updated Models:**
- `lib/models/order.dart` - Added `customerName`, `customerPhone`, `customerEmail`
- `lib/models/order_item.dart` - Fixed price parsing (PostgreSQL numeric to double)

---

## 👥 User Management

### Creating a New Delivery User

**Method 1: Using Node.js Script**

```bash
cd albaqer_gemstone_backend
node create_test_user.js delivery@test.com password123 delivery_man "John Delivery"
```

**Method 2: Database Direct Insert**

```sql
INSERT INTO users (name, email, password, role)
VALUES ('John Delivery', 'delivery@test.com', '$hashed_password', 'delivery_man');
```

**Method 3: Update Existing User Role**

```bash
cd albaqer_gemstone_backend
node update_user_role.js existing@user.com delivery_man
```

### Important Notes

⚠️ **Re-login Required**: After changing a user's role, they MUST logout and login again to receive a new JWT token with the updated role.

✅ **Verify Role Update**:
```sql
SELECT id, name, email, role FROM users WHERE email = 'delivery@test.com';
```

---

## 🔄 Order Workflow

### Complete Order Lifecycle

```
1. PENDING     → Customer creates order
2. CONFIRMED   → Admin/Manager confirms order
3. ASSIGNED    → Manager assigns to delivery person
4. IN_TRANSIT  → Delivery person starts delivery
5. DELIVERED   → Delivery person completes delivery
```

```
CANCELLED      → Can be set from any status (except delivered)
```

### Delivery Person Actions

#### Step 1: View Assigned Orders
1. Login as delivery person
2. Navigate to "My Deliveries" from dashboard or drawer
3. See list of orders with status `assigned` or `in_transit`

#### Step 2: View Order Details
1. Tap on an order card
2. View customer contact information
3. View shipping address
4. View order items (products being delivered)

#### Step 3: Contact Customer (Optional)
- Tap phone icon to call customer
- Tap SMS icon to send text message

#### Step 4: Navigate to Address
- Tap "Open in Maps" button
- Google Maps opens with address location
- Follow navigation to customer

#### Step 5: Start Delivery
1. Tap "Start Delivery" button
2. Order status changes to `in_transit`
3. Manager can see delivery is in progress

#### Step 6: Complete Delivery
1. Deliver order to customer
2. Tap "Mark Delivered" button
3. Order status changes to `delivered`
4. Order completion recorded with timestamp

### Status Workflow Validation

The backend enforces status hierarchy to prevent invalid transitions:

**Status Hierarchy:**
```
pending (1) → confirmed (2) → assigned (3) → in_transit (4) → delivered (5)
```

**Allowed Transitions:**
- ✅ Any status → Next status in hierarchy
- ✅ Any status → `cancelled`
- ❌ Higher status → Lower status (e.g., `delivered` → `in_transit`)

**Backend Validation:**
```javascript
// In orderController.js updateOrderStatus()
const statusHierarchy = {
  'pending': 1,
  'confirmed': 2,
  'assigned': 3,
  'in_transit': 4,
  'delivered': 5
};

// Prevents backwards transitions
if (newStatus !== 'cancelled' && 
    statusHierarchy[newStatus] < statusHierarchy[currentStatus]) {
  return res.status(400).json({
    message: `Cannot change status backwards from ${currentStatus} to ${newStatus}`
  });
}
```

---

## 🔒 Authorization & Security

### Role-Based Access Control

**Delivery Person Can:**
- ✅ View orders assigned to them (`delivery_man_id` matches user ID)
- ✅ View customer contact information for assigned orders
- ✅ View shipping addresses for assigned orders
- ✅ View order items for assigned orders
- ✅ Update status of assigned orders (only forward transitions)

**Delivery Person Cannot:**
- ❌ View orders assigned to other delivery persons
- ❌ View all orders (manager/admin privilege)
- ❌ Assign orders to themselves or others
- ❌ Cancel orders
- ❌ Change order backwards in workflow

### Authorization Implementation

**Backend Authorization Check:**
```javascript
// In orderController.js getOrderItems()
const isAuthorized = 
  order.user_id === req.user.id ||           // Customer owns order
  req.user.role === 'admin' ||               // Admin access
  req.user.role === 'manager' ||             // Manager access
  (req.user.role === 'delivery_man' &&       // Delivery assigned
   order.delivery_man_id === req.user.id);

if (!isAuthorized) {
  return res.status(403).json({
    message: 'Not authorized to view these order items'
  });
}
```

**Flutter Error Handling:**
```dart
// In order_service.dart getOrderItems()
if (response.statusCode == 403) {
  throw Exception('Not authorized to view order items');
}
```

### Security Best Practices

1. **JWT Token Required**: All endpoints require valid authentication token
2. **Entity-Level Checks**: Authorization validated at order level, not just role
3. **Explicit Denials**: Unauthorized requests return 403 with clear message
4. **No Data Leakage**: Failed authorization doesn't reveal if order exists
5. **Token Expiration**: Tokens expire and require re-login

---

## 🐛 Troubleshooting

### Issue: "No items found" or Empty Order List

**Possible Causes:**
1. No orders assigned to this delivery person
2. Logged in as wrong user
3. Token expired or invalid

**Solution:**
1. Check which delivery person you're logged in as:
   ```sql
   -- Get user ID from JWT token, then:
   SELECT id, name, email, role FROM users WHERE id = <user_id>;
   ```

2. Check if orders are assigned to this user:
   ```sql
   SELECT id, order_number, status, delivery_man_id 
   FROM orders 
   WHERE delivery_man_id = <user_id>;
   ```

3. If no orders, ask manager to assign orders from Manager Dashboard

4. If token expired, logout and login again

### Issue: "Not authorized to view order items"

**Cause:** Viewing an order not assigned to you

**Solution:**
- Only view orders in "My Deliveries" (filtered to your assignments)
- Don't try to access orders by direct ID that aren't yours
- This is correct security behavior, not a bug

### Issue: Phone/SMS buttons don't work

**Possible Causes:**
1. No phone app installed (emulators)
2. Customer phone number not in database
3. URL launcher permission denied

**Solution:**
1. Test on physical device, not emulator
2. Verify customer has phone number:
   ```sql
   SELECT u.phone FROM orders o 
   JOIN users u ON o.user_id = u.id 
   WHERE o.id = <order_id>;
   ```
3. Check Flutter permissions in AndroidManifest.xml

### Issue: "Open in Maps" doesn't work

**Possible Causes:**
1. No maps app installed
2. Invalid address coordinates
3. URL scheme not supported

**Solution:**
1. Install Google Maps on device
2. Check address has lat/long:
   ```sql
   SELECT * FROM addresses WHERE id = <address_id>;
   ```
3. Test URL manually: `geo:latitude,longitude`

### Issue: Order items showing "No items found"

**Cause (Fixed in v1.0):** PostgreSQL returns numeric fields as strings, but Flutter was calling `.toDouble()` on string

**Solution:** Already fixed in `order_item.dart`:
```dart
// Fixed:
priceAtPurchase: double.tryParse(json['price_at_purchase'].toString()) ?? 0.0,
```

Ensure you have the latest code with this fix.

### Issue: Can't update order status

**Possible Causes:**
1. Trying to go backwards in workflow (e.g., delivered → in_transit)
2. Not assigned to this order
3. Backend server not running

**Solution:**
1. Check current status - only forward transitions allowed
2. Verify logged in as assigned delivery person
3. Check backend server: `curl http://192.168.0.106:3000/api/health`

---

## 🔧 Technical Details

### Backend Implementation

**Key Controller Functions:**

1. **getMyDeliveries** (orderController.js, lines 34-70)
   ```javascript
   // Returns orders assigned to logged-in delivery person
   // Includes customer info: name, phone, email
   // Filtered: WHERE delivery_man_id = req.user.id
   ```

2. **getOrderItems** (orderController.js, lines 108-175)
   ```javascript
   // Returns order items with product details
   // JOIN with products table for name, description, image
   // Authorization: owner, admin, manager, or assigned delivery_man
   // Image URLs: Prepends server URL (http://192.168.0.106:3000)
   ```

3. **updateOrderStatus** (orderController.js, lines 306-332)
   ```javascript
   // Updates order status with workflow validation
   // Prevents backwards transitions using statusHierarchy
   // Middleware: adminOrDelivery (admin, manager, delivery_man)
   ```

4. **getAddress** (addressController.js, lines 47-67)
   ```javascript
   // Extended authorization for delivery_man
   // Checks if delivery person has order with this shipping_address_id
   // Returns full address with coordinates for maps
   ```

**Route Configuration (orderRoutes.js):**

⚠️ **Important**: Route order matters in Express!

```javascript
// CORRECT ORDER:
router.get('/:id/items', authenticate, getOrderItems);  // More specific
router.get('/:id', authenticate, getOrderById);         // Generic

// WRONG ORDER (will match /:id before /:id/items):
router.get('/:id', authenticate, getOrderById);         // Would catch all
router.get('/:id/items', authenticate, getOrderItems);  // Never reached
```

### Frontend Implementation

**Screen Flow:**

```
DeliveryDashboardScreen
  ↓ (tap "My Deliveries")
DeliveryOrdersScreen (filtered list)
  ↓ (tap order card)
DeliveryOrderDetailScreen
  ├─ Customer Contact Card (call/SMS)
  ├─ Shipping Address Card (maps)
  ├─ Order Items Card (products)
  └─ Status Actions (buttons)
```

**Key Services:**

1. **OrderService.getOrderItems()** (order_service.dart, lines 777-818)
   ```dart
   // Fetches order items from API
   // Error handling: 403 (unauthorized), 404 (not found), 401 (no token)
   // Returns List<OrderItem> or throws Exception
   ```

2. **AddressService.getAddressById()** (address_service.dart, lines 230-260)
   ```dart
   // Fetches single address by ID
   // Authorization checked by backend
   // Returns Address or null
   ```

**Models:**

1. **Order** (order.dart)
   ```dart
   // Extended with customer fields:
   final String? customerName;
   final String? customerPhone;
   final String? customerEmail;
   // Populated by backend JOIN query
   ```

2. **OrderItem** (order_item.dart)
   ```dart
   // Includes product fields:
   final String? productName;
   final String? productDescription;
   final String? productImage;
   // Price parsing fixed: double.tryParse()
   ```

### Database Schema

**Relevant Tables:**

```sql
-- Users table
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  phone VARCHAR(20),
  password VARCHAR(255) NOT NULL,
  role VARCHAR(20) DEFAULT 'customer',
  -- role values: customer, admin, manager, delivery_man
);

-- Orders table
CREATE TABLE orders (
  id SERIAL PRIMARY KEY,
  order_number VARCHAR(50) UNIQUE NOT NULL,
  user_id INTEGER REFERENCES users(id),
  delivery_man_id INTEGER REFERENCES users(id),  -- Delivery assignment
  assigned_at TIMESTAMP,                         -- Assignment timestamp
  status VARCHAR(20) DEFAULT 'pending',
  -- status: pending, confirmed, assigned, in_transit, delivered, cancelled
  shipping_address_id INTEGER REFERENCES addresses(id),
  total_amount NUMERIC(10,2) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Order Items table
CREATE TABLE order_items (
  id SERIAL PRIMARY KEY,
  order_id INTEGER REFERENCES orders(id),
  product_id INTEGER REFERENCES products(id),
  quantity INTEGER NOT NULL,
  price_at_purchase NUMERIC(10,2) NOT NULL,  -- PostgreSQL NUMERIC (string in JS)
);

-- Addresses table
CREATE TABLE addresses (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  address_line1 VARCHAR(255) NOT NULL,
  city VARCHAR(100) NOT NULL,
  state VARCHAR(100),
  postal_code VARCHAR(20),
  country VARCHAR(100) DEFAULT 'Yemen',
  latitude NUMERIC(10,6),   -- For Google Maps
  longitude NUMERIC(10,6),  -- For Google Maps
  is_default BOOLEAN DEFAULT false
);
```

**Key Indexes:**
```sql
-- For delivery person queries
CREATE INDEX idx_orders_delivery_man_id ON orders(delivery_man_id);

-- For order items lookup
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
```

### Dependencies

**Flutter Packages:**
```yaml
dependencies:
  http: ^1.1.0              # API requests
  url_launcher: ^6.2.1      # Phone/SMS/Maps
  provider: ^6.1.0          # State management
  shared_preferences: ^2.2.2 # Token storage
```

**Backend Packages:**
```json
{
  "express": "^4.18.2",
  "pg": "^8.11.3",          // PostgreSQL client
  "jsonwebtoken": "^9.0.2", // JWT authentication
  "bcrypt": "^5.1.1"        // Password hashing
}
```

---

## 📱 Mobile Integration Notes

### Android Permissions

**Required in AndroidManifest.xml:**
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CALL_PHONE" />
<uses-permission android:name="android.permission.SEND_SMS" />
```

### URL Schemes

**Phone Call:**
```
tel:+967123456789
```

**SMS:**
```
sms:+967123456789
```

**Google Maps:**
```
geo:latitude,longitude?q=latitude,longitude
```

### Testing on Emulator vs Device

**Emulator Limitations:**
- Phone calls: Opens dialer but can't actually call
- SMS: Opens messaging but can't send
- Maps: May not have Google Maps installed

**Physical Device:**
- All features work as expected
- Best for testing delivery role functionality

---

## 🎓 Best Practices

### For Delivery Personnel

1. **Check "My Deliveries" regularly** for new assignments
2. **Contact customer before delivery** to confirm availability
3. **Use maps navigation** for accurate directions
4. **Verify order items** before leaving for delivery
5. **Update status promptly** (Start Delivery when leaving, Mark Delivered on completion)
6. **Never share login credentials** - each delivery person has unique account

### For Managers

1. **Assign orders to available delivery persons** based on location/workload
2. **Monitor "In Transit" status** to track active deliveries
3. **Check delivery completion rates** to optimize assignments
4. **Provide delivery persons with customer contact** when assigning
5. **Ensure addresses have accurate coordinates** for maps integration

### For Developers

1. **Always check user role** before showing delivery screens
2. **Handle authorization errors gracefully** (403, 404)
3. **Validate JWT token freshness** before API calls
4. **Log errors with context** for debugging
5. **Test with multiple delivery users** to verify isolation
6. **Respect route ordering** in Express (specific before generic)
7. **Parse PostgreSQL numeric types** carefully (string → double)

---

## 📚 Related Documentation

- [IMPLEMENTATION_ROADMAP.md](./IMPLEMENTATION_ROADMAP.md) - Complete project roadmap
- [MANAGER_ROLE_GUIDE.md](./MANAGER_ROLE_GUIDE.md) - Manager role documentation
- [ROLES_AND_WORKFLOW_GUIDE.md](./ROLES_AND_WORKFLOW_GUIDE.md) - All roles overview
- [DATABASE_SUMMARY.md](./DATABASE_SUMMARY.md) - Database schema details
- [QUICK_SETUP.md](./QUICK_SETUP.md) - Project setup guide

---

## 🚀 Next Steps

With the delivery role complete, the core order management system is fully functional. Suggested next priorities:

1. **P2-1: Advanced Search & Filters** - Improve product discovery
2. **P2-5: Real-time Notifications** - Push notifications for delivery updates
3. **P2-7: Delivery History** - Track delivery person performance
4. **P3-3: Delivery Route Optimization** - Optimize multiple deliveries

---

## 📧 Support

For issues or questions:
1. Check [Troubleshooting](#troubleshooting) section
2. Review backend logs: `albaqer_gemstone_backend/server.js` output
3. Check Flutter console for error messages
4. Verify database state with SQL queries

---

**Delivery Role v1.0** - Production Ready ✅
