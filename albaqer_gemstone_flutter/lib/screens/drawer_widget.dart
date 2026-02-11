import 'package:albaqer_gemstone_flutter/screens/login_screen.dart';
import 'package:albaqer_gemstone_flutter/screens/admin_products_screen.dart';
import 'package:albaqer_gemstone_flutter/screens/admin_orders_screen.dart';
import 'package:albaqer_gemstone_flutter/screens/chatbot_screen.dart';
import 'package:albaqer_gemstone_flutter/screens/wishlist_screen.dart';
import 'package:albaqer_gemstone_flutter/screens/dashboard_screen.dart';
import 'package:albaqer_gemstone_flutter/screens/manager_dashboard_screen.dart';
import 'package:albaqer_gemstone_flutter/screens/manager_orders_screen.dart';
import 'package:albaqer_gemstone_flutter/screens/delivery_people_screen.dart';
import 'package:albaqer_gemstone_flutter/screens/delivery_dashboard_screen.dart';
import 'package:albaqer_gemstone_flutter/screens/delivery_orders_screen.dart';
import 'package:albaqer_gemstone_flutter/services/auth_service.dart';
import 'package:flutter/material.dart';
import '../config/app_theme.dart';

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
            decoration: BoxDecoration(color: AppColors.primary),
            currentAccountPicture: CircleAvatar(
              backgroundColor: AppColors.background,
              child: Icon(
                userRole == 'admin'
                    ? Icons.admin_panel_settings
                    : userRole == 'manager'
                    ? Icons.manage_accounts
                    : Icons.person,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            accountName: Text(
              userName,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            accountEmail: Row(
              children: [
                Icon(Icons.verified, size: 16, color: AppColors.textOnPrimary),
                SizedBox(width: 4),
                Text(
                  userRole.toUpperCase(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: (userRole == 'admin' || userRole == 'manager')
                        ? AppColors.secondary
                        : AppColors.textOnPrimary,
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

                // Dashboard
                ListTile(
                  leading: Icon(Icons.dashboard, color: AppColors.primary),
                  title: Text('Dashboard'),
                  subtitle: Text('Product statistics & insights'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DashboardScreen(),
                      ),
                    );
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
                          userId: isLoggedIn
                              ? null
                              : null, // Pass user ID if available
                        ),
                      ),
                    );
                  },
                ),

                // Wishlist
                ListTile(
                  leading: Icon(Icons.favorite, color: AppColors.favorite),
                  title: Text('My Wishlist'),
                  subtitle: Text('Saved items'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WishlistScreen(),
                      ),
                    );
                  },
                ),

                // ========================================
                // MANAGER-ONLY MENU ITEMS
                // ========================================
                if (userRole == 'manager') ...[
                  Divider(),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Manager Tools',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),

                  // Manager Dashboard
                  ListTile(
                    leading: Icon(Icons.dashboard, color: AppColors.primary),
                    title: Text('Manager Dashboard'),
                    subtitle: Text('Overview and quick actions'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ManagerDashboardScreen(),
                        ),
                      );
                    },
                  ),

                  // Manage Orders
                  ListTile(
                    leading: Icon(Icons.receipt_long, color: Colors.blue),
                    title: Text('Manage Orders'),
                    subtitle: Text('Assign orders to delivery'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ManagerOrdersScreen(),
                        ),
                      );
                    },
                  ),

                  // Delivery People
                  ListTile(
                    leading: Icon(Icons.people, color: Colors.green),
                    title: Text('Delivery People'),
                    subtitle: Text('View delivery staff'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DeliveryPeopleScreen(),
                        ),
                      );
                    },
                  ),
                ],

                // ========================================
                // DELIVERY-ONLY MENU ITEMS
                // ========================================
                if (userRole == 'delivery_man') ...[
                  Divider(),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Delivery Tools',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),

                  // Delivery Dashboard
                  ListTile(
                    leading: Icon(
                      Icons.local_shipping,
                      color: Colors.green[700],
                    ),
                    title: Text('Delivery Dashboard'),
                    subtitle: Text('Overview and quick actions'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DeliveryDashboardScreen(),
                        ),
                      );
                    },
                  ),

                  // My Deliveries
                  ListTile(
                    leading: Icon(Icons.assignment, color: Colors.orange),
                    title: Text('My Deliveries'),
                    subtitle: Text('View assigned orders'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DeliveryOrdersScreen(),
                        ),
                      );
                    },
                  ),
                ],

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
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),

                  // Manage Orders
                  ListTile(
                    leading: Icon(Icons.receipt_long, color: AppColors.primary),
                    title: Text('Manage Orders'),
                    subtitle: Text('Review and manage all orders'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminOrdersScreen(),
                        ),
                      );
                    },
                  ),

                  // Manage Products
                  ListTile(
                    leading: Icon(Icons.inventory, color: AppColors.secondary),
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
                    leading: Icon(Icons.logout, color: AppColors.error),
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
