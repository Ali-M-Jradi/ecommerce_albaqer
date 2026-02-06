/// Static API Configuration
/// Update the _serverIp when your server IP changes
class ApiConfig {
  // ⚙️ CONFIGURATION - Server IP (both services on same machine)
  static const String _serverIp = '192.168.0.120';

  // Backend API (products, cart, orders)
  static const String _backendPort = '3000';

  // Chatbot API (AI assistant)
  static const String _chatbotPort = '8000';

  /// Backend API (products, cart, orders, auth)
  static String get baseUrl => 'http://$_serverIp:$_backendPort/api';

  /// Chatbot API (AI chat) - no /api suffix, endpoints include it
  static String get chatbotUrl => 'http://$_serverIp:$_chatbotPort';

  /// Server URL for static files (images, etc)
  static String get serverUrl => 'http://$_serverIp:$_backendPort';

  /// Health check URLs
  static String get healthUrl => 'http://$_serverIp:$_backendPort/api/health';
  static String get chatbotHealthUrl =>
      'http://$_serverIp:$_chatbotPort/api/health';

  /// Print current configuration
  static void printConfig() {
    print('═══════════════════════════════════════════════════════');
    print('📱 Server Configuration');
    print('═══════════════════════════════════════════════════════');
    print('🌐 Server IP: $_serverIp');
    print('🛒 Backend Port: $_backendPort');
    print('💬 Chatbot Port: $_chatbotPort');
    print('═══════════════════════════════════════════════════════');
    print('📍 Backend URL: $baseUrl');
    print('🤖 Chatbot URL: $chatbotUrl');
    print('🖼️  Server URL: $serverUrl');
    print('═══════════════════════════════════════════════════════');
  }
}
