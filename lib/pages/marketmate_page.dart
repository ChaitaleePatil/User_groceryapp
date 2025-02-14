import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'fruits.dart'; // Import the FruitsPage
import 'ProfilePage.dart'; // Import the ProfilePage
import 'FreshPage.dart'; // Import the FreshPage
import 'GroceryPage.dart'; // Import the GroceryPage
import 'NewlyAddedPage.dart'; // Import the NewlyAddedPage
import 'ShopsPage.dart'; // Import the ShopsPage
import 'vegetables.dart'; // Import the VegetablesPage
import 'beverages.dart'; // Import the BeveragesPage
import 'grains.dart'; // Import the GrainsPage
import 'package:speech_to_text/speech_to_text.dart' as stt;

class MarketMatePage extends StatefulWidget {
  @override
  _MarketMatePageState createState() => _MarketMatePageState();
}

class _MarketMatePageState extends State<MarketMatePage> {
  // Variables to store user data
  String userName = '';
  String userAddress = '';
  int _selectedTab = 0; // Initialize selected tab index
  stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Fetch user data when the page loads
  }

  // Function to start or stop speech recognition
  void _toggleListening() async {
    if (_isListening) {
      _speech.stop();
    } else {
      bool available = await _speech.initialize();
      if (available) {
        _speech.listen(onResult: (result) {
          setState(() {
            _searchQuery = result.recognizedWords;
          });

          // Check the spoken words and navigate accordingly
          if (_searchQuery.contains('fruits')) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FruitsPage()),
            );
          } else if (_searchQuery.contains('shop')) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ShopsPage()),
            );
          } else if (_searchQuery.contains('grains')) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => GrainsPage()),
            );
          } else if (_searchQuery.contains('profile')) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
          } else if (_searchQuery.contains('vegetables')) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => VegetablesPage()),
            );
          } else if (_searchQuery.contains('beverages')) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BeveragesPage()),
            );
          }
        });
      }
    }

    setState(() {
      _isListening = !_isListening;
    });
  }

  // Function to fetch user data from Firestore
  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser; // Get the current user
    if (user != null) {
      // Fetch the user data from Firestore using the user's email
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('appusers')
          .doc(user.uid) // Use the UID to get the user document
          .get();

      if (userDoc.exists) {
        setState(() {
          userName =
              userDoc['name'] ?? 'User Name'; // Default name if not found
          userAddress = userDoc['address'] ?? 'User Address'; // Default address if not found
        });
      } else {
        print('User not found');
      }
    }
  }

  // Navigate to the Profile Page
  void _goToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfilePage()),
    );
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedTab = index; // Update selected tab
    });

    switch (index) {
      case 0:
        // Go to the All page (for now we'll stay on the current page)
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GroceryPage()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NewlyAddedPage()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FreshPage()),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ShopsPage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[100],
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                buildDeliveryTimeBadge(),
                SizedBox(width: 8),
                Text(
                  userName, // Display user name here
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Text(
              userAddress, // Display user address here
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: Colors.black),
            onPressed: _goToProfile, // Navigate to Profile Page on tap
          ),
          SizedBox(width: 16),
          // Remove mic icon from the app bar, we now have it in the search bar
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildSearchBar(),
            buildTabs(),
            buildMegaSavingsFestival(context),
            buildTopDeals(),
          ],
        ),
      ),
    );
  }

  Widget buildDeliveryTimeBadge() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        'User',
        style: TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  Widget buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            SizedBox(width: 8),
            Icon(Icons.search, color: Colors.grey),
            SizedBox(width: 8),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Search for 'fresh vegetables'",
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            IconButton(
              icon: Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                color: Colors.orange,
              ),
              onPressed: _toggleListening, // Start/stop listening
            ),
            SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget buildTabs() {
    return Container(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TabItem(
            imagePath: 'lib/icons/all.png',
            label: 'All',
            isSelected: _selectedTab == 0,
            onTap: () => _onTabSelected(0), // Pass the callback here
          ),
          TabItem(
            imagePath: 'lib/icons/grocery.png',
            label: 'Grocery',
            isSelected: _selectedTab == 1,
            onTap: () => _onTabSelected(1), // Pass the callback here
          ),
          TabItem(
            imagePath: 'lib/icons/new.png',
            label: 'Newly Added',
            isSelected: _selectedTab == 2,
            onTap: () => _onTabSelected(2), // Pass the callback here
          ),
          TabItem(
            imagePath: 'lib/icons/fresh.png',
            label: 'Fresh',
            isSelected: _selectedTab == 3,
            onTap: () => _onTabSelected(3), // Pass the callback here
          ),
          TabItem(
            imagePath: 'lib/icons/store.png',
            label: 'Shops',
            isSelected: _selectedTab == 4,
            onTap: () => _onTabSelected(4), // Pass the callback here
          ),
        ],
      ),
    );
  }

  Widget buildMegaSavingsFestival(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Grocery Companion, Simplified',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[700]),
          ),
          SizedBox(height: 8),
          Text(
            'Smart Choices for Smarter Living',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 3,
            childAspectRatio: 0.8,
            physics: NeverScrollableScrollPhysics(),
            children: [
              GestureDetector(
                onTap: () {
                  // Navigate to VegetablesPage when Vegetables is clicked
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => VegetablesPage()),
                  );
                },
                child: ProductItem(
                  imagePath: 'lib/assets/h1.jpg',
                  label: 'Farm Fresh Veggies',
                  discount: 'Locally Sourced Vegetables',
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to FruitsPage when Fruits is clicked
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FruitsPage()),
                  );
                },
                child: ProductItem(
                  imagePath: 'lib/assets/h2.jpg',
                  label: 'Fruits',
                  discount: 'Fresh, Juicy Fruits',
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to GrainsPage when Grains is clicked
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GrainsPage()),
                  );
                },
                child: ProductItem(
                  imagePath: 'lib/assets/h3.jpg',
                  label: 'Grains',
                  discount: 'Wholesome, Nutritious Grains',
                ),
              ),
              ProductItem(
                imagePath: 'lib/assets/h4.jpg',
                label: 'Dairy Farm',
                discount: 'Fresh Dairy Products',
              ),
              ProductItem(
                imagePath: 'lib/assets/h5.jpg',
                label: 'Cold Pressed Oils',
                discount: 'Pure, Healthy Oils',
              ),
              ProductItem(
                imagePath: 'lib/assets/h6.jpg',
                label: 'Masala Blends',
                discount: 'Aromatic Spice Blends',
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to BeveragesPage when Beverages is clicked
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BeveragesPage()),
                  );
                },
                child: ProductItem(
                  imagePath: 'lib/assets/h7.jpg',
                  label: 'Beverages',
                  discount: 'Refreshing Drink Options',
                ),
              ),
              ProductItem(
                imagePath: 'lib/assets/h8.jpg',
                label: 'Dry Fruits',
                discount: 'Healthy, Tasty Snacks',
              ),
              ProductItem(
                imagePath: 'lib/assets/h9.jpg',
                label: 'Bakery Products',
                discount: 'Freshly Baked Goodies',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildTopDeals() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Fresh Arrivals',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          TextButton(
            onPressed: () {},
            child: Text('Discover More'),
          ),
        ],
      ),
    );
  }
}

class TabItem extends StatelessWidget {
  final String imagePath;
  final String label;
  final bool isSelected;
  final VoidCallback onTap; // Added onTap parameter

  TabItem({
    required this.imagePath,
    required this.label,
    this.isSelected = false,
    required this.onTap, // Update constructor to accept onTap
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Wrap with GestureDetector to handle taps
      onTap: onTap, // Use the onTap parameter here
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, height: 24),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                  color: isSelected ? Colors.orange : Colors.green[800],
                  fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductItem extends StatelessWidget {
  final String imagePath;
  final String label;
  final String discount;

  ProductItem(
      {required this.imagePath, required this.label, required this.discount});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(imagePath, height: 80, fit: BoxFit.cover),
        SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12),
        ),
        SizedBox(height: 4),
        Text(
          discount,
          style: TextStyle(fontSize: 12, color: Colors.green[700]),
        ),
      ],
    );
  }
}
