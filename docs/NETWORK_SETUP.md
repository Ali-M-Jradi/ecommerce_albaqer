# 🌐 Network Configuration Guide

This guide explains how to configure the app to connect to the backend from any device.

## 📱 Quick Setup for Testing on Different Devices

### Step 1: Find Your Computer's IP Address

**Windows:**
```bash
ipconfig
```
Look for "IPv4 Address" (usually looks like `192.168.x.x`)

**Mac:**
```bash
ifconfig | grep inet
```
Look for an address like `192.168.x.x`

**Linux:**
```bash
ip addr show
```
Look for `inet 192.168.x.x`

### Step 2: Update the Configuration

1. Open `lib/config/api_config.dart`
2. Find this line:
   ```dart
   static const String _baseIp = '10.91.89.60'; // <-- UPDATE THIS!
   ```
3. Replace `10.91.89.60` with YOUR computer's IP address
4. Save the file

### Step 3: Start the Backend Server

```bash
cd albaqer_gemstone_backend
node server.js
```

You should see:
```
🚀 Server running on port 3000
🌐 Accessible at: http://localhost:3000 and http://10.0.2.2:3000
```

### Step 4: Run the Flutter App

**From Terminal:**
```bash
cd albaqer_gemstone_flutter
flutter run
```

**From VS Code:**
- Press F5 or click Run > Start Debugging

### Step 5: Verify Connection

When the app starts, check the console output. You should see:
```
═══════════════════════════════════════════════════════
📡 API Configuration
═══════════════════════════════════════════════════════
Backend URL: http://192.168.1.100:3000/api
Health URL:  http://192.168.1.100:3000/api/health
═══════════════════════════════════════════════════════
```

## 📋 Testing Scenarios

### Scenario 1: Android Emulator (on same PC as backend)
```dart
// In lib/config/api_config.dart
static const String _baseIp = '10.0.2.2';
```
The emulator uses `10.0.2.2` to reach the host machine's localhost.

### Scenario 2: Real Android/iOS Device (same WiFi)
```dart
// In lib/config/api_config.dart
static const String _baseIp = '192.168.1.100'; // Your PC's actual IP
```

### Scenario 3: iOS Simulator (on same Mac as backend)
```dart
// In lib/config/api_config.dart
static const String _baseIp = 'localhost';
```

### Scenario 4: Partner's Device (different location)
Your partner needs to:
1. Connect to the SAME WiFi network as the computer running the backend
2. Get the backend computer's IP address
3. Update `lib/config/api_config.dart` with that IP
4. Rebuild and run the app

## 🔥 Troubleshooting

### ❌ "Connection refused" or "Network error"

**Check 1: Backend Running?**
```bash
# Should show backend process
netstat -an | findstr :3000
```

**Check 2: Firewall Blocking?**
- Windows: Allow Node.js through Windows Defender Firewall
- Mac: System Preferences > Security & Privacy > Firewall > Allow Node
- Linux: `sudo ufw allow 3000`

**Check 3: Same Network?**
- Both devices MUST be on the same WiFi network
- Check IP ranges match (both should be 192.168.x.x or 10.0.x.x)

**Check 4: Correct IP?**
```bash
# Ping your backend from the device
ping 192.168.1.100
```

### ❌ "Backend sync failed"

**Solution 1: Verify Backend Health**
Open browser on your phone and visit:
```
http://YOUR_IP:3000/api/health
```
Should show JSON response.

**Solution 2: Check Backend Logs**
The backend console should show incoming requests:
```
📨 2026-01-27T... - GET /api/health
📤 2026-01-27T... - Response sent: 200
```

### ❌ Works on emulator but not real device

- Emulators use special IP (`10.0.2.2`)
- Real devices need your computer's actual network IP
- Update `api_config.dart` when switching between emulator and real device

## 🎯 Best Practices

1. **Development**: Use emulator with `10.0.2.2`
2. **Local Testing**: Use your WiFi IP (e.g., `192.168.1.100`)
3. **Demo/Presentation**: Ensure both devices on same network
4. **Collaboration**: Share your IP with teammates

## 📝 Configuration Files

### Backend Configuration
- File: `albaqer_gemstone_backend/server.js`
- Already configured to listen on `0.0.0.0` (all network interfaces)
- No changes needed

### Flutter Configuration
- File: `albaqer_gemstone_flutter/lib/config/api_config.dart`
- **This is the ONLY file you need to edit**
- All services automatically use this configuration

## 🚀 Advanced: Using Environment Variables (Optional)

For production, you might want to use different URLs for dev/staging/prod:

1. Create `lib/config/env.dart`:
```dart
class Env {
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.91.89.60:3000/api',
  );
}
```

2. Run with custom URL:
```bash
flutter run --dart-define=API_URL=http://192.168.1.100:3000/api
```

## 📞 Support

If you're still having issues:
1. Check all devices are on same WiFi
2. Restart the backend server
3. Restart the Flutter app
4. Check firewall settings
5. Verify IP address is correct

Backend logs will show all incoming connections, which helps debug connectivity issues.
