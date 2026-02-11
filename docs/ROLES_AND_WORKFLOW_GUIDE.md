# E-Commerce System Roles and Workflow

## Complete Order Lifecycle

```
Customer Places Order → PENDING
         ↓
Admin Reviews & Approves → CONFIRMED
         ↓
Manager Assigns to Delivery Person → ASSIGNED
         ↓
Delivery Person Ships → IN_TRANSIT (or SHIPPED)
         ↓
Delivery Person Completes → DELIVERED
```

**Alternative Paths:**
- Admin can CANCEL during review (pending → cancelled)
- Admin/Manager can CANCEL after confirmation (confirmed → cancelled)

---

## Role Responsibilities

### 👤 **CUSTOMER**
**Primary Functions:**
- Browse products and view details
- Add items to shopping cart
- Place new orders
- View order history
- Track order status in real-time
- Manage profile and shipping addresses
- Leave product reviews (if implemented)

**Access Level:** Own orders only

---

### 👨‍💼 **ADMIN** (Full System Control)
**Primary Functions:**
1. **Order Management:**
   - View ALL orders across all statuses
   - **Review pending orders** (confirm or cancel)
   - Approve order to move to "confirmed" status
   - Handle customer disputes
   - Cancel orders when needed

2. **Product Management:**
   - Add, edit, delete products
   - Manage product inventory/stock
   - Update product prices and descriptions
   - Upload product images

3. **User Management:**
   - Create users with specific roles
   - Update user roles (customer → manager → delivery_man)
   - Deactivate/activate accounts

4. **System Oversight:**
   - View business statistics and reports
   - Monitor system health
   - Handle customer support issues

**Access Level:** Full access to all features

**Key Workflow:**
- Customer places order → Admin sees it as "PENDING"
- Admin reviews order details (items, address, payment)
- Admin clicks "Confirm" → Order becomes "CONFIRMED" (ready for manager to assign)
- OR Admin clicks "Cancel" if there's an issue

---

### 👔 **MANAGER** (Operations Coordinator)
**Primary Functions:**
1. **Assignment Management:**
   - View **confirmed** orders (admin-approved, ready for assignment)
   - View list of available delivery personnel
   - Assign confirmed orders to delivery people
   - Monitor delivery person workload

2. **Order Tracking:**
   - Track assigned orders
   - View all order statuses
   - Reassign orders if delivery person unavailable
   - Unassign orders when needed

3. **Delivery Personnel Oversight:**
   - View all delivery personnel
   - See order assignments per delivery person
   - Monitor delivery performance

**Access Level:** View all orders, manage assignments

**Key Workflow:**
- Manager goes to "Ready to Assign" tab (shows confirmed unassigned orders)
- Manager selects an order
- Manager chooses a delivery person from list
- Manager clicks "Assign" → Order becomes "ASSIGNED" with delivery_man_id set

**Important:** Managers CANNOT see or assign "pending" orders - those must be confirmed by admin first!

---

### 🚚 **DELIVERY MAN** (Delivery Personnel)
**Primary Functions:**
1. **Delivery Execution:**
   - View orders assigned to them
   - Update delivery status (mark as shipped/in_transit)
   - Mark orders as delivered
   - Update location/tracking information

2. **Communication:**
   - Report delivery issues
   - Contact customers if needed
   - Update estimated delivery times

3. **History:**
   - View delivery history
   - Track performance metrics

**Access Level:** Only assigned orders

**Key Workflow:**
- Login and see list of assigned orders
- Select an order
- Update status to "In Transit" when starting delivery
- Update location while en route (if GPS tracking enabled)
- Mark as "Delivered" upon completion

---

## Status Definitions

| Status | Description | Who Can Set | Next Allowed Status |
|--------|-------------|-------------|-------------------|
| **pending** | Customer placed order, awaiting admin review | System (on order creation) | confirmed, cancelled (by admin) |
| **confirmed** | Admin approved, ready for assignment | Admin | assigned (by manager), cancelled |
| **assigned** | Assigned to delivery person | Manager | in_transit, cancelled |
| **in_transit** | Out for delivery | Delivery Man | delivered, cancelled |
| **delivered** | Successfully delivered | Delivery Man | (final state) |
| **cancelled** | Order cancelled | Admin or Manager | (final state) |

---

## Permission Matrix

| Action | Customer | Admin | Manager | Delivery Man |
|--------|----------|-------|---------|--------------|
| Place Order | ✅ | ✅ | ✅ | ✅ |
| View Own Orders | ✅ | ✅ | ✅ | ✅ |
| View All Orders | ❌ | ✅ | ✅ | ❌ |
| Confirm/Cancel Pending Orders | ❌ | ✅ | ❌ | ❌ |
| Assign to Delivery Person | ❌ | ❌ | ✅ | ❌ |
| Update Delivery Status | ❌ | ❌ | ❌ | ✅ |
| Manage Products | ❌ | ✅ | ❌ | ❌ |
| Manage Users/Roles | ❌ | ✅ | ❌ | ❌ |

---

## Example Workflow

### Scenario: Customer Orders Yemeni Agate Ring

**Step 1: Customer** (Ali)
- Browses products
- Adds "Yemeni Agate Silver Ring" to cart
- Places order
- **Status: PENDING**

**Step 2: Admin** (Sara)
- Logs into admin panel
- Sees new order in "Pending Orders" tab
- Reviews order details:
  - Customer: Ali
  - Product: Yemeni Agate Silver Ring ($150)
  - Address: Sana'a, Yemen
  - Payment: Cash on Delivery
- Clicks "Confirm Order"
- **Status: CONFIRMED**

**Step 3: Manager** (Ahmed)
- Logs into manager dashboard
- Goes to "Ready to Assign" tab
- Sees Ali's confirmed order
- Clicks "Assign Delivery Person"
- Selects "Mohammed" (has capacity, near Sana'a area)
- Clicks "Assign"
- **Status: ASSIGNED**

**Step 4: Delivery Man** (Mohammed)
- Logs into app
- Sees new assigned order
- Reviews delivery address
- Clicks "Start Delivery"
- **Status: IN_TRANSIT**
- Delivers to Ali's address
- Clicks "Mark as Delivered"
- **Status: DELIVERED**

**Step 5: Customer** (Ali)
- Receives order
- Sees "Delivered" status in order history
- Leaves product review (optional)

---

## Key Design Principles

1. **Separation of Concerns:**
   - Admins handle approval/rejection
   - Managers handle logistics/assignment
   - Delivery personnel handle execution

2. **Status Progression:**
   - Each role can only advance to next logical status
   - No skipping stages (can't assign pending orders)

3. **Accountability:**
   - Each status change is logged with timestamp
   - Assignments track who assigned and when
   - Clear audit trail

4. **Scalability:**
   - Manager can view workload per delivery person
   - Reassignment capability for flexibility
   - Prevents overwhelming any single delivery person

---

## Testing Users

Create test users for each role:

```bash
# Create Manager
node create_test_user.js manager manager@test.com "Ahmed Manager" password123

# Create Delivery Man
node create_test_user.js delivery_man delivery@test.com "Mohammed Delivery" password123

# Update existing user to Manager
node update_user_role.js existing@email.com manager
```

---

## Common Issues

### "Why can't manager see pending orders?"
**Answer:** By design! Pending orders need admin approval first. Only confirmed orders can be assigned.

### "Can admin assign orders directly?"
**Answer:** Not recommended. Admins should confirm, then let managers handle assignment (separation of duties).

### "Can delivery person cancel orders?"
**Answer:** No. Only admin/manager can cancel. Delivery person should report issues to manager.

### "What if delivery person is sick?"
**Answer:** Manager can reassign order to another delivery person using the "Reassign" option.

---

## Database Schema Changes

The manager role implementation added two columns to the `orders` table:

```sql
ALTER TABLE orders 
ADD COLUMN delivery_man_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
ADD COLUMN assigned_at TIMESTAMP;
```

These track:
- **delivery_man_id**: Which delivery person is assigned
- **assigned_at**: When the assignment was made

---

## Next Steps (Priority Order)

1. ✅ **Manager Role** - COMPLETE
2. ⏳ **Delivery Man Role** - IN PROGRESS (backend routes exist, Flutter screens needed)
3. ⏳ **Reviews System** - PENDING (P1 Priority)
4. ⏳ **GPS Tracking** - PENDING (Enhancement)
5. ⏳ **Push Notifications** - PENDING (Enhancement)
