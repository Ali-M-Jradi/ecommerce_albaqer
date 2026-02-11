# Manager Role - Quick Start Guide

## 📱 How to Access Manager Screens

### Method 1: Using the Drawer Menu (Recommended)
1. **Login** as a manager user
2. **Tap the hamburger menu** (≡) icon in the top-left corner
3. Under **"Manager Tools"** section, you'll see:
   - 🎯 **Manager Dashboard** - Overview and statistics
   - 📋 **Manage Orders** - Assign orders to delivery people
   - 👥 **Delivery People** - View delivery staff

### Method 2: Direct Navigation
Manager screens are located at:
- `lib/screens/manager_dashboard_screen.dart`
- `lib/screens/manager_orders_screen.dart`
- `lib/screens/delivery_people_screen.dart`

---

## 🔐 Creating Manager & Delivery Users

### Problem
The app registration only creates **"customer"** role users. To test manager features, you need users with **"manager"** or **"delivery_man"** roles.

### Solution Options

#### ✅ **Option 1: Update Existing User (Easiest)**

**Step 1:** Register a user normally through the app

**Step 2:** Run the update script:
```powershell
cd albaqer_gemstone_backend
node update_user_role.js user@example.com manager
```

This changes the user's role from `customer` to `manager`.

---

#### ✅ **Option 2: Create New User with Role**

Create a new user with specific role directly:
```powershell
cd albaqer_gemstone_backend
node create_test_user.js manager manager@test.com "Test Manager" password123
node create_test_user.js delivery_man delivery@test.com "Test Delivery" password123
```

---

#### ✅ **Option 3: Using SQL (Manual)**

Connect to PostgreSQL and run:
```sql
-- Update existing user
UPDATE users 
SET role = 'manager' 
WHERE email = 'user@example.com';

-- Or use the provided SQL file
\i migrations/create_test_users.sql
```

---

## 🧪 Testing the Manager Workflow

### Test Scenario: Complete Order Assignment

**1. Create Test Users**
```powershell
# Create manager
node update_user_role.js manager@test.com manager

# Create delivery person
node update_user_role.js delivery@test.com delivery_man

# Create customer (or use existing)
node update_user_role.js customer@test.com customer
```

**2. Customer Places Order**
- Login as customer
- Add products to cart
- Place order
- Order status: **pending**

**3. Manager Assigns Order**
- Login as manager (logout and login again)
- Open drawer → **Manager Dashboard**
- Tap **Manage Orders**
- See pending orders
- Tap **Assign Delivery** button
- Select delivery person
- Order status changes to: **assigned**

**4. View in Delivery People Screen**
- Go to **Delivery People** screen
- See the delivery person
- Tap on them
- See their assigned orders

---

## 📊 Features Available to Manager

### Manager Dashboard
- ✅ View count of pending orders
- ✅ View count of delivery staff
- ✅ Quick action buttons
- ✅ Manager responsibilities guide

### Manage Orders Screen
- ✅ Filter orders by status (pending, confirmed, assigned, all)
- ✅ View order details
- ✅ Assign orders to delivery people
- ✅ Reassign orders to different delivery people
- ✅ Unassign delivery people from orders
- ✅ Pull to refresh

### Delivery People Screen
- ✅ View all delivery personnel
- ✅ See delivery person details
- ✅ View orders assigned to each delivery person
- ✅ Filter by delivery status

---

## 🚨 Common Issues

### "No delivery personnel available"
**Cause:** No users with `delivery_man` role exist

**Fix:** Create delivery users using Option 1 or 2 above

---

### "Manager Tools not showing in drawer"
**Cause:** User role is not `manager`

**Fix:** 
```powershell
node update_user_role.js your@email.com manager
# Then logout and login again
```

---

### "Cannot see orders in manager screen"
**Cause:** No orders exist in the system

**Fix:** 
1. Login as customer
2. Place some test orders
3. Login as manager
4. Orders will appear in pending

---

## 🔄 User Role Hierarchy

| Role | Can Do |
|------|--------|
| **customer** | Browse, order, view own orders |
| **delivery_man** | View assigned orders, mark delivered (coming soon) |
| **manager** | Assign orders to delivery, view all orders, manage staff |
| **admin** | Everything (full system access) |

---

## 🎯 Next Steps

After testing manager features, you can implement:

1. **Delivery Man Features** (P0 - Critical)
   - View my assigned orders
   - Mark orders as in_transit
   - Mark orders as delivered

2. **Admin User Management UI** (P1 - Nice to have)
   - Create users from admin panel
   - Change user roles
   - Deactivate users

---

## 📝 Scripts Reference

All scripts are in `albaqer_gemstone_backend/`:

| Script | Purpose | Example |
|--------|---------|---------|
| `create_test_user.js` | Create new user with role | `node create_test_user.js manager m@test.com "Manager" pass` |
| `update_user_role.js` | Change existing user role | `node update_user_role.js user@email.com manager` |
| `migrations/create_test_users.sql` | Batch create test users | `psql -d dbname -f migrations/create_test_users.sql` |

---

## ✅ Verification Checklist

- [ ] Manager user created
- [ ] Delivery person user created
- [ ] Customer orders placed
- [ ] Manager can see pending orders
- [ ] Manager can assign orders to delivery
- [ ] Delivery people screen shows staff
- [ ] Can view orders per delivery person

---

**🎉 Manager features are complete and ready to use!**

For delivery man implementation, let me know when you're ready.
