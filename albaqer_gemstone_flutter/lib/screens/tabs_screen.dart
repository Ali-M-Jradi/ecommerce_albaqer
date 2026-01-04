import 'package:albaqer_gemstone_flutter/screens/drawer_widget.dart';
import 'package:albaqer_gemstone_flutter/screens/home_screen.dart';
import 'package:albaqer_gemstone_flutter/screens/search_screen.dart';
import 'package:albaqer_gemstone_flutter/screens/cart_screen.dart';
import 'package:albaqer_gemstone_flutter/services/cart_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  final String selectedScreenName = "home_screen";
  int selectedIndex = 0;
  void selectPage(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: selectedIndex == 1
          ? null
          : AppBar(
              animateColor: true,
              elevation: 10,
              backgroundColor: Colors.black,
              iconTheme: IconThemeData(color: Colors.white),
              title: Text(
                'Albaqer Gemstone',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              actions: [
                // Cart icon with badge showing item count
                Consumer<CartService>(
                  builder: (context, cartService, child) {
                    return Stack(
                      children: [
                        IconButton(
                          icon: Icon(Icons.shopping_cart, color: Colors.white),
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
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                '${cartService.itemCount}',
                                style: TextStyle(
                                  color: Colors.white,
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
              bottom: PreferredSize(
                preferredSize: Size(double.infinity, 75),
                child: SearchBar(
                  hintText: 'Search gemstones...',
                  onTap: () => selectPage(1),
                ),
              ),
            ),
      drawer: selectedIndex == 1 ? null : DrawerWidget(),
      body: IndexedStack(
        index: selectedIndex,
        children: [
          const HomeScreen(),
          SearchScreen(onBackPressed: () => selectPage(0)),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        ],
        onTap: selectPage,
        currentIndex: selectedIndex,
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
      ),
    );
  }
}
