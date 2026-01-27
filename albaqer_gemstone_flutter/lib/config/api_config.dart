import 'dart:io';
import 'package:http/http.dart' as http;

/// Automatic API Configuration - No manual setup needed!
/// Automatically discovers backend server on local network
class ApiConfig {
  static const String _port = '3000';
  static String? _discoveredIp;

  /// Common IP ranges to check
  static List<String> get _commonIps => [
    '192.168.0.103', // Current WiFi
    '192.168.1.1', // Common router gateway
    '10.0.2.2', // Android emulator
    'localhost', // Testing locally
  ];

  /// Auto-discover backend IP by testing common addresses
  static Future<String> _discoverBackendIp() async {
    print('🔍 Auto-discovering backend server...');

    // Try cached IP first
    if (_discoveredIp != null) {
      if (await _testConnection(_discoveredIp!)) {
        print('✅ Using cached IP: $_discoveredIp');
        return _discoveredIp!;
      }
    }

    // Try common IPs
    for (String ip in _commonIps) {
      if (await _testConnection(ip)) {
        _discoveredIp = ip;
        print('✅ Backend found at: $ip');
        return ip;
      }
    }

    // Try to get network IP dynamically
    try {
      for (var interface in await NetworkInterface.list()) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            String ip = addr.address;
            if (await _testConnection(ip)) {
              _discoveredIp = ip;
              print('✅ Backend found at network IP: $ip');
              return ip;
            }
          }
        }
      }
    } catch (e) {
      print('⚠️ Could not scan network interfaces: $e');
    }

    // Fallback to first common IP
    print('⚠️ Backend not found, using fallback: ${_commonIps.first}');
    return _commonIps.first;
  }

  /// Test if backend is reachable at given IP
  static Future<bool> _testConnection(String ip) async {
    try {
      final response = await http
          .get(Uri.parse('http://$ip:$_port/api/health'))
          .timeout(const Duration(seconds: 2));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Get base URL with auto-discovery
  static Future<String> get baseUrl async {
    final ip = await _discoverBackendIp();
    return 'http://$ip:$_port/api';
  }

  /// Get health check URL
  static Future<String> get healthUrl async {
    final ip = await _discoverBackendIp();
    return 'http://$ip:$_port/api/health';
  }

  /// Force rediscovery (useful if network changes)
  static void resetDiscovery() {
    _discoveredIp = null;
    print('🔄 IP discovery reset');
  }

  /// Print current configuration
  static Future<void> printConfig() async {
    final ip = await _discoverBackendIp();
    print('═══════════════════════════════════════════════════════');
    print('📱 Auto-Discovered Backend Configuration');
    print('═══════════════════════════════════════════════════════');
    print('🌐 Backend IP: $ip');
    print('🔌 Port: $_port');
    print('📍 Base URL: http://$ip:$_port/api');
    print('═══════════════════════════════════════════════════════');
  }
}
