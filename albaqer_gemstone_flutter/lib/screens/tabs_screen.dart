import 'package:albaqer_gemstone_flutter/screens/drawer_widget.dart';
import 'package:albaqer_gemstone_flutter/screens/home_screen.dart';
import 'package:albaqer_gemstone_flutter/screens/shop_screen.dart';
import 'package:albaqer_gemstone_flutter/screens/profile_screen.dart';
import 'package:albaqer_gemstone_flutter/screens/cart_screen.dart';
import 'package:albaqer_gemstone_flutter/services/cart_service.dart';
import 'package:albaqer_gemstone_flutter/config/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  TabsScreenState createState() => TabsScreenState();
}

class TabsScreenState extends State<TabsScreen> {
  int selectedIndex = 0;

  void selectPage(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: AppColors.textOnPrimary),
        title: const Text(
          'AlBaqer Gemstone',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textOnPrimary,
          ),
        ),
        actions: [
          // Cart icon with badge showing item count
          Consumer<CartService>(
            builder: (context, cartService, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.shopping_cart,
                      color: AppColors.textOnPrimary,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CartScreen(),
                        ),
                      );
                    },
                  ),
                  // Badge showing cart item count
                  if (cartService.itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.badge,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${cartService.itemCount}',
                          style: const TextStyle(
                            color: AppColors.textOnPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
        centerTitle: true,
      ),
      drawer: DrawerWidget(),
      body: IndexedStack(
        index: selectedIndex,
        children: const [HomeScreen(), ShopScreen(), ProfileScreen()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Shop',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: selectPage,
        currentIndex: selectedIndex,
        selectedItemColor: AppColors.secondary,
        unselectedItemColor: AppColors.textSecondary,
        backgroundColor: AppColors.background,
      ),
    );
  }
}
