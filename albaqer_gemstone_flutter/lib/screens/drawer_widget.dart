import 'package:albaqer_gemstone_flutter/screens/login_screen.dart';
import 'package:albaqer_gemstone_flutter/screens/admin_products_screen.dart';
import 'package:albaqer_gemstone_flutter/screens/chatbot_screen.dart';
import 'package:albaqer_gemstone_flutter/services/auth_service.dart';
import 'package:flutter/material.dart';

/// =======================================================================
/// DRAWER WIDGET - Navigation Menu with Role-Based Display
/// =======================================================================
/// Shows different options based on user role (admin vs user)

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  String userName = 'Guest';
  String userRole = 'user';
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  /// Load user information from AuthService
  Future<void> _loadUserInfo() async {
    final authService = AuthService();
    final loggedIn = await authService.isLoggedIn();

    if (loggedIn) {
      final user = await authService.getCurrentUser();
      if (user != null) {
        setState(() {
          isLoggedIn = true;
          userName = user.fullName;
          userRole = user.role;
        });
      }
    }
  }

  /// Logout user
  Future<void> _logout() async {
    final authService = AuthService();
    await authService.logout();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // ========================================
          // USER HEADER - Shows name and role
          // ========================================
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.black),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                userRole == 'admin' ? Icons.admin_panel_settings : Icons.person,
                size: 40,
                color: Colors.black,
              ),
            ),
            accountName: Text(
              userName,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            accountEmail: Row(
              children: [
                Icon(Icons.verified, size: 16, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  userRole.toUpperCase(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: userRole == 'admin' ? Colors.amber : Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // ========================================
          // MENU ITEMS
          // ========================================
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Home
                ListTile(
                  leading: Icon(Icons.home),
                  title: Text('Home'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),

                // AI Assistant (Chatbot)
                ListTile(
                  leading: Icon(Icons.chat_bubble, color: Colors.purple),
                  title: Text('AI Assistant'),
                  subtitle: Text('Chat with our gemstone expert'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatbotScreen(
                          userId: isLoggedIn ? null : null, // Pass user ID if available
                        ),
                      ),
                    );
                  },
                ),

                // ========================================
                // ADMIN-ONLY MENU ITEMS
                // ========================================
                if (userRole == 'admin') ...[
                  Divider(),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Admin Tools',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),

                  // Manage Products
                  ListTile(
                    leading: Icon(Icons.inventory, color: Colors.amber[700]),
                    title: Text('Manage Products'),
                    subtitle: Text('Add, edit, delete products'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminProductsScreen(),
                        ),
                      );
                    },
                  ),
                ],

                Divider(),

                // Login/Logout
                if (!isLoggedIn)
                  ListTile(
                    leading: Icon(Icons.login),
                    title: Text('Login / Register'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                  )
                else
                  ListTile(
                    leading: Icon(Icons.logout, color: Colors.red),
                    title: Text('Logout'),
                    onTap: _logout,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
