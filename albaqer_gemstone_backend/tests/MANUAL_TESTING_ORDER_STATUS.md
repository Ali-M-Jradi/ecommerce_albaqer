# Manual Testing Guide: Order Status Updates

## Prerequisites
1. Backend server running on `http://localhost:3000`
2. PostgreSQL database with updated status constraint
3. Admin user credentials
4. At least one test order in the system

## Test Steps

### 1. Verify Database Constraint

```powershell
cd "C:\Users\hp 15\Desktop\flutter_university\ecommerce_albaqer\albaqer_gemstone_backend"
$env:PGPASSWORD='po$7Gr@s$'
psql -U postgres -d albaqer_gemstone_ecommerce_db -c "\d orders" | Select-String -Pattern "status_check"
```

**Expected Result:**
```
"orders_status_check" CHECK (status::text = ANY 
(ARRAY['pending'::character varying, 'confirmed'::character varying,
'assigned'::character varying, 'in_transit'::character varying,
'delivered'::character varying, 'cancelled'::character varying]::text[]))
```

### 2. Start Backend Server

```powershell
cd "C:\Users\hp 15\Desktop\flutter_university\ecommerce_albaqer\albaqer_gemstone_backend"
node server.js
```

### 3. Test Valid Status Updates

#### A. Get Authentication Token

```powershell
# Login as admin
$response = Invoke-RestMethod -Uri "http://localhost:3000/api/users/login" `
    -Method POST `
    -ContentType "application/json" `
    -Body '{"email":"admin@test.com","password":"admin123"}'
    
$token = $response.token
Write-Host "Token: $token"
```

#### B. Get Orders List

```powershell
$headers = @{
    "Authorization" = "Bearer $token"
}

$orders = Invoke-RestMethod -Uri "http://localhost:3000/api/orders/all" `
    -Method GET `
    -Headers $headers

# Display orders
$orders.data | Format-Table id, order_number, status, total_amount
```

#### C. Test Status Update - Valid Status

```powershell
# Update order to "confirmed" (valid status)
$orderId = 1  # Replace with actual order ID
$body = @{
    status = "confirmed"
    tracking_number = $null
} | ConvertTo-Json

$result = Invoke-RestMethod -Uri "http://localhost:3000/api/orders/$orderId/status" `
    -Method PUT `
    -ContentType "application/json" `
    -Headers $headers `
    -Body $body

Write-Host "✅ Status updated successfully"
$result.data | Format-List id, order_number, status
```

#### D. Test All Valid Status Transitions

```powershell
# Test each valid status
$validStatuses = @('pending', 'confirmed', 'assigned', 'in_transit', 'delivered', 'cancelled')

foreach ($status in $validStatuses) {
    Write-Host "`nTesting status: $status"
    
    $body = @{
        status = $status
        tracking_number = $null
    } | ConvertTo-Json
    
    try {
        $result = Invoke-RestMethod -Uri "http://localhost:3000/api/orders/$orderId/status" `
            -Method PUT `
            -ContentType "application/json" `
            -Headers $headers `
            -Body $body
        
        Write-Host "✅ SUCCESS: Updated to $status"
    }
    catch {
        Write-Host "❌ FAILED: Could not update to $status"
        Write-Host "   Error: $($_.Exception.Message)"
    }
    
    Start-Sleep -Milliseconds 500
}
```

### 4. Test Invalid Status Updates

```powershell
# Test invalid statuses (should fail)
$invalidStatuses = @('processing', 'shipped', 'refunded', 'invalid')

foreach ($status in $invalidStatuses) {
    Write-Host "`nTesting invalid status: $status"
    
    $body = @{
        status = $status
        tracking_number = $null
    } | ConvertTo-Json
    
    try {
        $result = Invoke-RestMethod -Uri "http://localhost:3000/api/orders/$orderId/status" `
            -Method PUT `
            -ContentType "application/json" `
            -Headers $headers `
            -Body $body
        
        Write-Host "❌ UNEXPECTED: Status '$status' was accepted (should have failed)"
    }
    catch {
        $errorResponse = $_.ErrorDetails.Message | ConvertFrom-Json
        Write-Host "✅ EXPECTED: Status '$status' was rejected"
        Write-Host "   Message: $($errorResponse.message)"
    }
    
    Start-Sleep -Milliseconds 500
}
```

### 5. Test with Flutter App

1. Open the Flutter app
2. Login as admin
3. Navigate to Admin Orders screen
4. Try updating an order status:
   - Click on "Accept Order" (should update to "confirmed")
   - Click "Next" and select "assigned"
   - Click "Next" and select "in_transit"
   - Click "Next" and select "delivered"

**Expected Result:** All transitions should work smoothly with success messages

### 6. Check Backend Logs

Monitor the backend console for detailed logs:
```
📝 Updating order #1 status to: confirmed
✅ Order #1 status updated to: confirmed
```

For invalid statuses:
```
❌ Invalid status attempted: "processing". Valid statuses: pending, confirmed, assigned, in_transit, delivered, cancelled
```

## Verification Checklist

- [ ] Database constraint updated successfully
- [ ] Backend server starts without errors
- [ ] Authentication works
- [ ] Can retrieve orders list
- [ ] Valid status updates work (pending → confirmed → assigned → in_transit → delivered)
- [ ] Invalid status updates are rejected with proper error messages
- [ ] Error messages include list of valid statuses
- [ ] Flutter app can update order statuses
- [ ] Backend logs show detailed information

## Troubleshooting

### Issue: "Invalid status value"
**Solution:** Ensure database constraint was updated. Re-run `fix_status_constraint.sql`

### Issue: "Not authorized"
**Solution:** Ensure you're logged in as admin user

### Issue: "Order not found"
**Solution:** Verify order ID exists in database

### Issue: Backend not responding
**Solution:** Check if backend server is running on port 3000

## Success Criteria

✅ All valid status transitions work
✅ Invalid statuses are rejected
✅ Error messages are clear and helpful
✅ Backend logs provide detailed information
✅ Flutter app can update statuses successfully
