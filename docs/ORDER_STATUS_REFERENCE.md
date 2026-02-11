# Quick Reference: Order Status Values

## Valid Order Status Values

| Status | Description | Usage |
|--------|-------------|-------|
| `pending` | Order placed, awaiting admin confirmation | Initial state when customer places order |
| `confirmed` | Order accepted by admin | Admin confirms order is valid |
| `assigned` | Assigned to delivery person | Manager assigns to delivery personnel |
| `in_transit` | Out for delivery | Delivery person has picked up order |
| `delivered` | Successfully delivered to customer | Final successful state |
| `cancelled` | Order cancelled | Can be set from any status before delivery |

## Status Flow Diagram

```
┌─────────┐
│ pending │
└────┬────┘
     │
     ▼
┌───────────┐
│ confirmed │
└────┬──────┘
     │
     ▼
┌──────────┐
│ assigned │
└────┬─────┘
     │
     ▼
┌────────────┐
│ in_transit │
└────┬───────┘
     │
     ▼
┌───────────┐
│ delivered │
└───────────┘

Note: Any status (except delivered) can transition to cancelled
```

## Common Transitions

### Normal Order Flow
```
pending → confirmed → assigned → in_transit → delivered
```

### Cancellation Flow
```
pending → cancelled
confirmed → cancelled
assigned → cancelled
in_transit → cancelled
```

### Invalid Transitions (will be rejected)
```
delivered → any other status
cancelled → any other status
```

## Old Status Values (No Longer Valid)

These statuses were used in the old system and are **NO LONGER VALID**:

| Old Status | New Equivalent | Migration |
|------------|----------------|-----------|
| `processing` | `confirmed` | Update all references |
| `shipped` | `in_transit` | Update all references |
| `refunded` | Not implemented | Future feature |

## Code Examples

### Backend (Node.js)

```javascript
// Valid statuses constant
const VALID_STATUSES = [
    'pending', 
    'confirmed', 
    'assigned', 
    'in_transit', 
    'delivered', 
    'cancelled'
];

// Validate status
if (!VALID_STATUSES.includes(status)) {
    return res.status(400).json({
        success: false,
        message: `Invalid status. Must be one of: ${VALID_STATUSES.join(', ')}`,
        validStatuses: VALID_STATUSES
    });
}
```

### Flutter (Dart)

```dart
// Valid statuses constant
const validStatuses = [
  'pending',
  'confirmed',
  'assigned',
  'in_transit',
  'delivered',
  'cancelled'
];

// Validate status
if (!validStatuses.contains(newStatus)) {
  print('❌ Invalid status value: $newStatus');
  print('   Valid statuses: ${validStatuses.join(', ')}');
  return false;
}
```

### Database Constraint

```sql
ALTER TABLE orders 
ADD CONSTRAINT orders_status_check 
CHECK (status IN (
    'pending', 
    'confirmed', 
    'assigned', 
    'in_transit', 
    'delivered', 
    'cancelled'
));
```

## UI Status Colors

```dart
Color getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return Colors.orange;  // Warning - needs attention
    case 'confirmed':
      return Colors.blue;    // Info - being processed
    case 'assigned':
      return Colors.purple;  // Info - assigned
    case 'in_transit':
      return Colors.amber;   // Warning - in progress
    case 'delivered':
      return Colors.green;   // Success - completed
    case 'cancelled':
      return Colors.red;     // Error - cancelled
    default:
      return Colors.grey;    // Unknown
  }
}
```

## Testing Status Updates

### Using PowerShell

```powershell
# Update to valid status
$body = @{
    status = "confirmed"
    tracking_number = $null
} | ConvertTo-Json

$result = Invoke-RestMethod `
    -Uri "http://localhost:3000/api/orders/1/status" `
    -Method PUT `
    -ContentType "application/json" `
    -Headers @{ "Authorization" = "Bearer $token" } `
    -Body $body
```

### Using curl

```bash
curl -X PUT http://localhost:3000/api/orders/1/status \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $token" \
  -d '{"status":"confirmed","tracking_number":null}'
```

## Error Messages

### Invalid Status
```json
{
  "success": false,
  "message": "Invalid status value. Must be one of: pending, confirmed, assigned, in_transit, delivered, cancelled",
  "validStatuses": ["pending", "confirmed", "assigned", "in_transit", "delivered", "cancelled"]
}
```

### Order Not Found
```json
{
  "success": false,
  "message": "Order not found"
}
```

### Not Authorized
```json
{
  "success": false,
  "message": "Not authorized to update order status"
}
```

## Admin Panel Actions

### Pending Orders
- ✅ **Accept** → Changes status to `confirmed`
- ❌ **Decline** → Changes status to `cancelled`

### Confirmed Orders
- ⏭️ **Next** → Move to `assigned` (when ready for delivery assignment)
- ❌ **Cancel** → Change to `cancelled`

### Assigned Orders
- ⏭️ **Next** → Move to `in_transit` (when picked up by delivery)
- ❌ **Cancel** → Change to `cancelled`

### In Transit Orders
- ⏭️ **Next** → Move to `delivered` (when successfully delivered)
- ❌ **Cancel** → Change to `cancelled` (only if needed)

### Delivered Orders
- 🔒 **Final State** → Cannot be changed

### Cancelled Orders
- 🔒 **Final State** → Cannot be changed

## Troubleshooting

### Issue: "Invalid status value"
**Cause:** Trying to use old status values (`processing`, `shipped`, etc.)  
**Solution:** Use new status values from the valid list above

### Issue: "Status constraint violation"
**Cause:** Database constraint not updated  
**Solution:** Run `fix_status_constraint.sql`

### Issue: Order status not updating
**Cause:** Authorization issue or order not found  
**Solution:** 
1. Verify user has admin role
2. Check order ID exists
3. Check auth token is valid

---

**Last Updated:** February 11, 2026  
**Version:** 2.0 (New Status System)
