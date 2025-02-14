import 'package:flutter/material.dart';
import 'marketmate_page.dart';
import 'nearby_page.dart'; // Import the NearbyPage
import 'cart.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    NearbyPage(), // Display NearbyPage for Home tab
    MarketMatePage(), // MarketMate page
    CartPage(cartItems: {}), // CartPage, passing an empty map for now
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset('lib/icons/house.png', height: 24),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('lib/icons/all.png', height: 24),
            label: 'MarketMate',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('lib/icons/cart.png', height: 24),
            label: 'Cart',
          ),
        ],
      ),
    );
  }
}
