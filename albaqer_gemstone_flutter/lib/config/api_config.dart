/// Static API Configuration
/// Update the _baseIp when your server IP changes
class ApiConfig {
  // ⚙️ CONFIGURATION - Change this IP address when needed
  static const String _baseIp = '192.168.179.1';
  static const String _port = '3000';

  /// Get base URL for API calls
  static String get baseUrl => 'http://$_baseIp:$_port/api';

  /// Get server URL (without /api) for static files like images
  static String get serverUrl => 'http://$_baseIp:$_port';

  /// Get health check URL
  static String get healthUrl => 'http://$_baseIp:$_port/api/health';

  /// Print current configuration
  static void printConfig() {
    print('═══════════════════════════════════════════════════════');
    print('📱 Backend Configuration');
    print('═══════════════════════════════════════════════════════');
    print('🌐 Backend IP: $_baseIp');
    print('🔌 Port: $_port');
    print('📍 Base URL: $baseUrl');
    print('🖼️  Server URL: $serverUrl');
    print('═══════════════════════════════════════════════════════');
  }
}
