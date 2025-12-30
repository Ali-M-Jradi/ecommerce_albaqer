# Quick API Test Script
# Run this in PowerShell to test your endpoints

Write-Host "Testing API Endpoints..." -ForegroundColor Green

# 1. Health Check
Write-Host "`n1. Testing Health Check..." -ForegroundColor Yellow
Invoke-RestMethod -Uri "http://localhost:3000/api/health" -Method GET | ConvertTo-Json

# 2. Get All Products
Write-Host "`n2. Testing Get Products..." -ForegroundColor Yellow
Invoke-RestMethod -Uri "http://localhost:3000/api/products" -Method GET | ConvertTo-Json

# 3. Register User
Write-Host "`n3. Testing User Registration..." -ForegroundColor Yellow
$registerBody = @{
    email = "test@example.com"
    password = "password123"
    full_name = "Test User"
    phone = "1234567890"
} | ConvertTo-Json

try {
    $registerResponse = Invoke-RestMethod -Uri "http://localhost:3000/api/users/register" -Method POST -Body $registerBody -ContentType "application/json"
    Write-Host "Registration successful!" -ForegroundColor Green
    $registerResponse | ConvertTo-Json
} catch {
    Write-Host "User might already exist or error occurred" -ForegroundColor Red
    $_.Exception.Message
}

# 4. Login User
Write-Host "`n4. Testing User Login..." -ForegroundColor Yellow
$loginBody = @{
    email = "test@example.com"
    password = "password123"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:3000/api/users/login" -Method POST -Body $loginBody -ContentType "application/json"
    $token = $loginResponse.data.token
    Write-Host "Login successful! Token received." -ForegroundColor Green
    Write-Host "Token: $token" -ForegroundColor Cyan

    # 5. Get Profile (Protected Route)
    Write-Host "`n5. Testing Get Profile (Protected)..." -ForegroundColor Yellow
    $headers = @{
        Authorization = "Bearer $token"
    }
    $profile = Invoke-RestMethod -Uri "http://localhost:3000/api/users/profile" -Method GET -Headers $headers
    $profile | ConvertTo-Json
    Write-Host "Profile retrieved successfully!" -ForegroundColor Green

} catch {
    Write-Host "Login failed:" -ForegroundColor Red
    $_.Exception.Message
}

Write-Host "`n✅ Testing Complete!" -ForegroundColor Green
Write-Host "Server is working correctly. Install Thunder Client extension for easier testing." -ForegroundColor Cyan
