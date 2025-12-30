import 'package:albaqer_gemstone_flutter/screens/drawer_widget.dart';
import 'package:albaqer_gemstone_flutter/screens/home_screen.dart';
import 'package:albaqer_gemstone_flutter/screens/search_screen.dart';
import 'package:flutter/material.dart';

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
                IconButton(
                  icon: Icon(Icons.shopping_cart, color: Colors.white),
                  onPressed: () {
                    // Navigate to cart screen
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
        children: const [
          HomeScreen(),
          SearchScreen(),
          Center(child: Text('Profile Screen')),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: selectPage,
        currentIndex: selectedIndex,
      ),
    );
  }
}
