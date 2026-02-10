# Manager Role Implementation Guide

## Overview
A new **manager** role has been added to your ecommerce system. Managers can assign orders to delivery personnel and track delivery assignments.

## New Roles

Your system now supports these roles:
- **customer**: Regular user who purchases products
- **manager**: Manages order delivery assignments (NEW)
- **delivery_man**: Delivers orders to customers (NEW)
- **admin**: Full system access

## Database Changes

### Migration File
Run the migration to add new columns to the orders table:

```sql
-- File: add_manager_role.sql
-- This adds delivery_man_id and assigned_at columns to orders table
```

Execute this SQL to add the necessary columns:
```bash
psql -U postgres -d albaqer_gemstone_ecommerce_db -f add_manager_role.sql
```

### New Columns in `orders` table:
- `delivery_man_id` (INT, FK to users.id) - References the delivery person assigned to this order
- `assigned_at` (TIMESTAMP) - When the order was assigned to a delivery person

## API Endpoints

### User Management (Admin Only)

#### Assign Role to User
```
PUT /api/users/:id/assign-role
Headers: Authorization: Bearer <token>
Body: {
  "role": "manager" | "delivery_man" | "customer" | "admin"
}
Response: {
  "success": true,
  "message": "User role updated to manager successfully",
  "data": { user object with new role }
}
```

#### Get All Delivery Men
```
GET /api/users/role/delivery-men
Headers: Authorization: Bearer <token>
Response: {
  "success": true,
  "data": [{ id, email, full_name, phone, role, is_active, created_at }, ...],
  "count": number
}
```

#### Get All Managers
```
GET /api/users/role/managers
Headers: Authorization: Bearer <token>
Response: {
  "success": true,
  "data": [{ id, email, full_name, phone, role, is_active, created_at }, ...],
  "count": number
}
```

### Order Management (Manager Only)

#### Get All Pending/Unassigned Orders
```
GET /api/orders/manager/pending
Headers: Authorization: Bearer <manager_token>
Response: {
  "success": true,
  "data": [{ order objects }, ...],
  "count": number
}
```

#### Get All Delivery Men (For Assignment)
```
GET /api/orders/manager/delivery-men
Headers: Authorization: Bearer <manager_token>
Response: {
  "success": true,
  "data": [{ id, email, full_name, phone, role, created_at }, ...],
  "count": number
}
```

#### Assign Order to Delivery Man
```
PUT /api/orders/:id/assign-delivery
Headers: Authorization: Bearer <manager_token>
Body: {
  "delivery_man_id": 5
}
Response: {
  "success": true,
  "message": "Order assigned to delivery man successfully",
  "data": { updated order object with delivery_man_id, status: "assigned", assigned_at }
}
```

#### Get Orders For Specific Delivery Man
```
GET /api/orders/manager/delivery-man/:deliveryManId
Headers: Authorization: Bearer <manager_token>
Response: {
  "success": true,
  "data": [{ order objects assigned to this delivery man }, ...],
  "count": number
}
```

#### Unassign Order From Delivery Man
```
PUT /api/orders/:id/unassign-delivery
Headers: Authorization: Bearer <manager_token>
Response: {
  "success": true,
  "message": "Order unassigned from delivery man successfully",
  "data": { updated order object with delivery_man_id: null, status: "confirmed", assigned_at: null }
}
```

## Setup Instructions

### 1. Create Manager Users (via Admin Panel)
As an admin user, assign the manager role to users:

```bash
# Using curl:
curl -X PUT http://localhost:5000/api/users/2/assign-role \
  -H "Authorization: Bearer <admin_token>" \
  -H "Content-Type: application/json" \
  -d '{"role": "manager"}'
```

### 2. Create Delivery Men Users (via Admin Panel)
Assign the delivery_man role to courier/delivery personnel:

```bash
curl -X PUT http://localhost:5000/api/users/3/assign-role \
  -H "Authorization: Bearer <admin_token>" \
  -H "Content-Type: application/json" \
  -d '{"role": "delivery_man"}'
```

### 3. Manager Workflow

1. **View pending orders**: GET `/api/orders/manager/pending`
2. **Get list of delivery men**: GET `/api/orders/manager/delivery-men`
3. **Assign order to delivery man**: PUT `/api/orders/:id/assign-delivery`
4. **Track delivery man's orders**: GET `/api/orders/manager/delivery-man/:deliveryManId`
5. **Reassign if needed**: PUT `/api/orders/:id/unassign-delivery` then reassign

## Order Status Flow

Orders now follow this workflow:
- `pending` → (order placed)
- `confirmed` → (order confirmed, waiting for assignment)
- `assigned` → (assigned to delivery man, delivery_man_id set, assigned_at timestamp)
- `in_transit` → (delivery man picked up order - update by admin)
- `delivered` → (order delivered - update by admin)
- `cancelled` → (order cancelled - update by admin)

## File Changes Summary

### Backend Files Modified:
1. **middleware/auth.js** - Added manager, deliveryMan, managerOrAdmin middleware
2. **controllers/orderController.js** - Added 5 new manager functions
3. **routes/orderRoutes.js** - Added manager endpoints
4. **controllers/userController.js** - Added role assignment functions
5. **routes/userRoutes.js** - Added role management endpoints
6. **add_manager_role.sql** - Database migration (new file)

## Security Notes

- Only users with `manager` role can access manager endpoints
- Only `admin` can assign/update user roles
- Each order tracks who assigned it (implicitly via admin action)
- Managers cannot delete orders (only admins can)

## Next Steps (Optional)

You may want to:
1. Add delivery man routes to track their own orders
2. Add email notifications when orders are assigned
3. Add delivery status updates from delivery person
4. Create manager dashboard in Flutter app
5. Add filters for order status and date range

## Testing

Test the endpoints using Postman or curl with appropriate manager/admin tokens.
