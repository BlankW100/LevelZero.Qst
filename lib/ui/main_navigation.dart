import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'shop_screen.dart';
import 'inventory_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // The Master List of Screens!
  final List<Widget> _screens = [
    const DashboardScreen(),
    const Center(child: Text('Quest Screen (Coming Soon)', style: TextStyle(color: Colors.white, fontSize: 20))),
    const Center(child: Text('Stats Screen (Coming Soon)', style: TextStyle(color: Colors.white, fontSize: 20))),
    const ShopScreen(),
    const InventoryScreen(),
    const Center(child: Text('Profile Screen (Coming Soon)', style: TextStyle(color: Colors.white, fontSize: 20))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // FIX: Removed IndexedStack! 
      // Now, swapping tabs forces the screen to grab your freshest Data/Coins!
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Forces all 6 icons to stay visible
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey[700],
        selectedFontSize: 10,
        unselectedFontSize: 10,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Quest'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Shop'),
          BottomNavigationBarItem(icon: Icon(Icons.backpack), label: 'Vault'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}