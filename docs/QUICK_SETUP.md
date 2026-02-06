# 🎯 Quick Reference Card - Network Setup

## For the Developer (You)

### 1. Start Backend
```bash
cd albaqer_gemstone_backend
node server.js
```

**Look for this output:**
```
═══════════════════════════════════════════════════════
🚀 AlBaqer Gemstone Backend Server
═══════════════════════════════════════════════════════
✅ Server running on port 3000

📱 Access URLs:
   Network:          http://192.168.1.100:3000/api  ← COPY THIS IP!
═══════════════════════════════════════════════════════
```

### 2. Update Flutter Config
1. Open `albaqer_gemstone_flutter/lib/config/api_config.dart`
2. Change line 28:
   ```dart
   static const String _baseIp = '192.168.1.100'; // ← PASTE YOUR IP HERE
   ```
3. Save file

### 3. Run Flutter App
```bash
cd albaqer_gemstone_flutter
flutter run
```

---

## For Your Partner/Tester

### What They Need:
1. **Same WiFi Network** - Must be connected to YOUR WiFi
2. **IP Address** - You send them: `192.168.1.100` (your IP from backend startup)
3. **Make Sure Backend is Running** - Your computer must have backend active

### What They Do:
1. Clone/receive the project
2. Edit `lib/config/api_config.dart`:
   ```dart
   static const String _baseIp = 'YOUR_IP_HERE';
   ```
3. Run: `flutter run`

---

## Device-Specific IPs

| Device Type | IP Address to Use |
|-------------|-------------------|
| Android Emulator (on your PC) | `10.0.2.2` |
| iOS Simulator (on your Mac) | `localhost` |
| Real Android/iOS (same WiFi) | `192.168.x.x` (your network IP) |
| Partner's device (same WiFi) | `192.168.x.x` (your network IP) |

---

## Troubleshooting Checklist

- [ ] Backend shows "Server running on port 3000"
- [ ] IP address is correct in `api_config.dart`
- [ ] Both devices on SAME WiFi network
- [ ] Firewall allows port 3000
- [ ] Can ping IP: `ping 192.168.x.x`
- [ ] Browser can access: `http://192.168.x.x:3000/api/health`

---

## Files Modified

✅ Created: `lib/config/api_config.dart` - Centralized API URL
✅ Updated: All service files now use `ApiConfig.baseUrl`
✅ Updated: `server.js` - Shows network IP on startup
✅ Updated: `main.dart` - Prints config on app launch

**Only 1 file to edit: `lib/config/api_config.dart`**
