# Fix: NOT NULL Constraint Error on shipping_address_id

## Problem
When creating orders from the Flutter app, you get:
```
❌ Failed to create order: 500
Response: {
  "success": false,
  "message": "Failed to create order",
  "error": "null value in column \"shipping_address_id\" of relation \"orders\" violates not-null constraint"
}
```

## Root Cause
Your actual PostgreSQL database has a NOT NULL constraint on the `shipping_address_id` column, but the documentation schema shows it as nullable. When orders are created WITHOUT a shipping address, the backend tries to insert NULL, which violates the constraint.

## Solution

### Step 1: Run Database Migration
The migration file `fix_address_nullable.sql` has been created for you.

Execute it:
```bash
cd albaqer_gemstone_backend
psql -U postgres -d albaqer_gemstone_ecommerce_db -f fix_address_nullable.sql
```

**Or manually in pgAdmin/DBeaver:**
```sql
ALTER TABLE orders ALTER COLUMN shipping_address_id DROP NOT NULL;
ALTER TABLE orders ALTER COLUMN billing_address_id DROP NOT NULL;
```

### Step 2: Restart Backend Server
After applying the migration:
```bash
npm start
```

### Step 3: Test Order Creation
Try creating an order again from the Flutter app. It should now work without requiring a shipping address.

---

## Order Creation Flow

**Before (Current):**
```
Customer → Creates Order WITHOUT address → Backend tries to insert NULL → ❌ ERROR
```

**After (Fixed):**
```
Customer → Creates Order WITHOUT address → Backend inserts NULL → ✅ SUCCESS
     ↓
Customer → Can add shipping address later
     ↓
Admin/Manager → Can assign address when processing order
```

---

## Optional: If You Want to Require Addresses

If you prefer to REQUIRE shipping addresses before creating orders, you can:

1. **Keep the NOT NULL constraint** (don't apply migration)
2. **Update the order creation flow** to:
   - Require user to add shipping address first
   - Validate shipping_address_id in middleware
   - Show error if address not provided

### Example Validation (optional):
```javascript
const validateOrder = [
    body('shipping_address_id')
        .notEmpty().withMessage('Shipping address is required')
        .isInt({ min: 1 }).withMessage('Invalid shipping address ID'),
    body('total_amount')
        .notEmpty().withMessage('Total amount is required')
        .isFloat({ min: 0 }).withMessage('Total amount must be positive'),
    validate
];
```

Then in Flutter:
```dart
// Require address before checkout
if (shippingAddressId == null) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Shipping Address Required'),
      content: const Text('Please add a shipping address before placing an order'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Add Address'),
        ),
      ],
    ),
  );
  return;
}
```

---

## Database Schema After Fix

```sql
-- Before (Error):
shipping_address_id INTEGER NOT NULL,  -- ❌ No NULL allowed
billing_address_id INTEGER NOT NULL,   -- ❌ No NULL allowed

-- After (Fixed):
shipping_address_id INTEGER,           -- ✅ NULL allowed
billing_address_id INTEGER,            -- ✅ NULL allowed
```

---

## Files Created/Modified

1. **fix_address_nullable.sql** - Migration file (NEW)
   - Removes NOT NULL constraint from both address fields

## Status

✅ Ready to implement - Apply the migration and restart your backend!
