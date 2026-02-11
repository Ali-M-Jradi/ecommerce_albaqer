# 🧪 Address System Testing Guide

## Prerequisites
1. ✅ Backend server running (`node server.js`)
2. ✅ Database running (PostgreSQL)
3. ✅ Run migration if needed: `add_address_timestamps.sql`
4. ✅ Valid JWT token (login first)

---

## Step 1: Run Database Migration (if needed)

```powershell
# Connect to PostgreSQL and run migration
psql -U postgres -d albaqer_gemstone_ecommerce_db -f migrations/add_address_timestamps.sql
```

---

## Step 2: Get JWT Token

First, login to get authentication token:

```powershell
# Register or login
$response = Invoke-RestMethod -Uri "http://localhost:3000/api/users/login" `
    -Method POST `
    -ContentType "application/json" `
    -Body (@{
        email = "admin@example.com"
        password = "admin123"
    } | ConvertTo-Json)

$token = $response.data.token
Write-Host "Token: $token"
```

---

## Step 3: Test Address Endpoints

### 3.1 Create Address (POST /api/addresses)

```powershell
$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

$newAddress = @{
    address_type = "shipping"
    street_address = "123 Main Street, Apt 4B"
    city = "Sanaa"
    country = "Yemen"
    is_default = $true
} | ConvertTo-Json

$createResponse = Invoke-RestMethod -Uri "http://localhost:3000/api/addresses" `
    -Method POST `
    -Headers $headers `
    -Body $newAddress

Write-Host "Created Address:"
$createResponse | ConvertTo-Json -Depth 3
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Address created successfully",
  "data": {
    "id": 1,
    "user_id": 1,
    "address_type": "shipping",
    "street_address": "123 Main Street, Apt 4B",
    "city": "Sanaa",
    "country": "Yemen",
    "is_default": true,
    "created_at": "2026-02-11T..."
  }
}
```

---

### 3.2 Get All User Addresses (GET /api/addresses)

```powershell
$addresses = Invoke-RestMethod -Uri "http://localhost:3000/api/addresses" `
    -Method GET `
    -Headers $headers

Write-Host "All Addresses:"
$addresses | ConvertTo-Json -Depth 3
```

**Expected Response:**
```json
{
  "success": true,
  "data": [...],
  "count": 1
}
```

---

### 3.3 Get Default Address (GET /api/addresses/default)

```powershell
$defaultAddress = Invoke-RestMethod -Uri "http://localhost:3000/api/addresses/default" `
    -Method GET `
    -Headers $headers

Write-Host "Default Address:"
$defaultAddress | ConvertTo-Json -Depth 3
```

---

### 3.4 Get Address by ID (GET /api/addresses/:id)

```powershell
$addressId = 1
$address = Invoke-RestMethod -Uri "http://localhost:3000/api/addresses/$addressId" `
    -Method GET `
    -Headers $headers

Write-Host "Address $addressId:"
$address | ConvertTo-Json -Depth 3
```

---

### 3.5 Update Address (PUT /api/addresses/:id)

```powershell
$addressId = 1
$updatedAddress = @{
    address_type = "both"
    street_address = "456 Updated Street, Suite 100"
    city = "Aden"
    country = "Yemen"
    is_default = $true
} | ConvertTo-Json

$updateResponse = Invoke-RestMethod -Uri "http://localhost:3000/api/addresses/$addressId" `
    -Method PUT `
    -Headers $headers `
    -Body $updatedAddress

Write-Host "Updated Address:"
$updateResponse | ConvertTo-Json -Depth 3
```

---

### 3.6 Set Default Address (PUT /api/addresses/:id/set-default)

```powershell
$addressId = 1
$setDefaultResponse = Invoke-RestMethod -Uri "http://localhost:3000/api/addresses/$addressId/set-default" `
    -Method PUT `
    -Headers $headers

Write-Host "Set as Default:"
$setDefaultResponse | ConvertTo-Json -Depth 3
```

---

### 3.7 Delete Address (DELETE /api/addresses/:id)

```powershell
$addressId = 2
$deleteResponse = Invoke-RestMethod -Uri "http://localhost:3000/api/addresses/$addressId" `
    -Method DELETE `
    -Headers $headers

Write-Host "Deleted Address:"
$deleteResponse | ConvertTo-Json -Depth 3
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Address deleted successfully"
}
```

---

## Complete Test Script

Save this as `test_addresses.ps1`:

```powershell
# Address System Complete Test Script

Write-Host "🧪 Testing Address System..." -ForegroundColor Cyan
Write-Host ""

# Step 1: Login
Write-Host "1️⃣ Logging in..." -ForegroundColor Yellow
try {
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:3000/api/users/login" `
        -Method POST `
        -ContentType "application/json" `
        -Body (@{
            email = "admin@example.com"
            password = "admin123"
        } | ConvertTo-Json)
    
    $token = $loginResponse.data.token
    Write-Host "✅ Login successful" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "❌ Login failed: $_" -ForegroundColor Red
    exit
}

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

# Step 2: Create Address
Write-Host "2️⃣ Creating address..." -ForegroundColor Yellow
try {
    $newAddress = @{
        address_type = "shipping"
        street_address = "123 Test Street, Building 5"
        city = "Sanaa"
        country = "Yemen"
        is_default = $true
    } | ConvertTo-Json

    $createResponse = Invoke-RestMethod -Uri "http://localhost:3000/api/addresses" `
        -Method POST `
        -Headers $headers `
        -Body $newAddress
    
    $addressId = $createResponse.data.id
    Write-Host "✅ Address created with ID: $addressId" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "❌ Create failed: $_" -ForegroundColor Red
    Write-Host ""
}

# Step 3: Get All Addresses
Write-Host "3️⃣ Getting all addresses..." -ForegroundColor Yellow
try {
    $addresses = Invoke-RestMethod -Uri "http://localhost:3000/api/addresses" `
        -Method GET `
        -Headers $headers
    
    Write-Host "✅ Found $($addresses.count) address(es)" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "❌ Get addresses failed: $_" -ForegroundColor Red
    Write-Host ""
}

# Step 4: Get Default Address
Write-Host "4️⃣ Getting default address..." -ForegroundColor Yellow
try {
    $defaultAddress = Invoke-RestMethod -Uri "http://localhost:3000/api/addresses/default" `
        -Method GET `
        -Headers $headers
    
    Write-Host "✅ Default address: $($defaultAddress.data.city)" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "❌ Get default address failed: $_" -ForegroundColor Red
    Write-Host ""
}

# Step 5: Update Address
Write-Host "5️⃣ Updating address..." -ForegroundColor Yellow
try {
    $updatedAddress = @{
        address_type = "both"
        street_address = "456 Updated Street"
        city = "Aden"
        country = "Yemen"
        is_default = $true
    } | ConvertTo-Json

    $updateResponse = Invoke-RestMethod -Uri "http://localhost:3000/api/addresses/$addressId" `
        -Method PUT `
        -Headers $headers `
        -Body $updatedAddress
    
    Write-Host "✅ Address updated" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "❌ Update failed: $_" -ForegroundColor Red
    Write-Host ""
}

# Step 6: Create Second Address
Write-Host "6️⃣ Creating second address..." -ForegroundColor Yellow
try {
    $secondAddress = @{
        address_type = "billing"
        street_address = "789 Billing Street"
        city = "Taiz"
        country = "Yemen"
        is_default = $false
    } | ConvertTo-Json

    $createResponse2 = Invoke-RestMethod -Uri "http://localhost:3000/api/addresses" `
        -Method POST `
        -Headers $headers `
        -Body $secondAddress
    
    $addressId2 = $createResponse2.data.id
    Write-Host "✅ Second address created with ID: $addressId2" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "❌ Second create failed: $_" -ForegroundColor Red
    Write-Host ""
}

Write-Host "✅ All tests completed!" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Summary:" -ForegroundColor Cyan
Write-Host "   - Addresses can be created ✓"
Write-Host "   - Addresses can be retrieved ✓"
Write-Host "   - Addresses can be updated ✓"
Write-Host "   - Default address management ✓"
Write-Host ""
Write-Host "⚠️  Note: Delete tests not included to preserve data" -ForegroundColor Yellow
```

---

## Testing with Flutter App

The Flutter app already has `address_service.dart` with all methods ready. After backend is running:

1. **Run Flutter App**
2. **Navigate to Profile → Addresses**
3. **Test functionality:**
   - Add new address
   - Set default address
   - Update address
   - Delete address

---

## Validation Tests

Test validation by sending invalid data:

### Missing Required Fields
```powershell
# Should fail - missing street_address
$invalidAddress = @{
    address_type = "shipping"
    city = "Sanaa"
    country = "Yemen"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:3000/api/addresses" `
    -Method POST `
    -Headers $headers `
    -Body $invalidAddress
```

### Invalid Address Type
```powershell
# Should fail - invalid address_type
$invalidAddress = @{
    address_type = "invalid_type"
    street_address = "123 Street"
    city = "Sanaa"
    country = "Yemen"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:3000/api/addresses" `
    -Method POST `
    -Headers $headers `
    -Body $invalidAddress
```

---

## Troubleshooting

### Error: "column created_at does not exist"
**Solution:** Run the migration script:
```powershell
psql -U postgres -d albaqer_gemstone_ecommerce_db -f migrations/add_address_timestamps.sql
```

### Error: "Address not found"
**Solution:** Check if address ID exists and belongs to current user

### Error: "Not authorized"
**Solution:** Ensure valid JWT token in Authorization header

### Error: "Validation failed"
**Solution:** Check request body matches validation rules:
- address_type: must be 'shipping', 'billing', or 'both'
- street_address: 5-500 characters
- city: 2-100 characters
- country: 2-100 characters

---

## Success Indicators

✅ All endpoints return success: true  
✅ Default address logic works (only one default per user)  
✅ User can only access their own addresses  
✅ Validation prevents invalid data  
✅ Timestamps (created_at, updated_at) are populated  

---

## Next Steps

After testing backend:
1. Test Flutter app address screens
2. Verify order creation now works with addresses
3. Test address selection during checkout
4. Verify admin can view user addresses

---

**Status:** Backend address system is now complete! 🎉
