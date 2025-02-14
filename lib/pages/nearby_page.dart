import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math'; // For math operations
import 'ProfilePage.dart'; // Import the ProfilePage if it's defined elsewhere
import 'nearbyshopmenu.dart';

class NearbyPage extends StatefulWidget {
  @override
  _NearbyPageState createState() => _NearbyPageState();
}

class _NearbyPageState extends State<NearbyPage> {
  String userName = 'Loading...';
  String userAddress = 'Loading...';
  double? userLatitude;
  double? userLongitude;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fetch the current user's data from Firestore
  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser; // Get the current user
    if (user != null) {
      // Fetch the user data from Firestore using the user's UID
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('appusers')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          userName =
              userDoc['name'] ?? 'User Name'; // Default name if not found
          userAddress = userDoc['address'] ??
              'User Address'; // Default address if not found

          // Check if latitude and longitude are present
          userLatitude = _parseDouble(userDoc['latitude']);
          userLongitude = _parseDouble(userDoc['longitude']);
        });
      } else {
        print('User not found');
      }
    }
  }

  // Function to safely parse latitude and longitude from String to Double
  double? _parseDouble(dynamic value) {
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        print("Error parsing value: $value");
        return null;
      }
    } else if (value is double) {
      return value;
    }
    return null; // Return null if the value is neither String nor double
  }

  // Navigate to the Profile Page
  void _goToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfilePage()),
    );
  }

  // Build the delivery time badge with the user name
  Widget buildDeliveryTimeBadge() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        'User', // Static label or fetched name if needed
        style: TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  // Build the search bar widget
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
                  hintText: "Search for 'nearby shops'",
                ),
              ),
            ),
            Icon(Icons.mic, color: Colors.orange),
            SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  // Navigate to ShopMenuPage
  void navigateToShopMenu(
      BuildContext context, String userId, Map<String, dynamic> shopDetails) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            NearbyShopMenuPage(userId: userId, shopDetails: shopDetails),
      ),
    );
  }

  // Haversine formula to calculate distance between two latitude/longitude points
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371; // Radius of Earth in km
    var dLat = _degToRad(lat2 - lat1);
    var dLon = _degToRad(lon2 - lon1);

    var a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));
    var distance = earthRadius * c; // Distance in km
    return distance;
  }

  double _degToRad(double degree) {
    return degree * pi / 180.0;
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
        ],
      ),
      body: Column(
        children: [
          buildSearchBar(), // Add the search bar
          // Check if user location is available and show a message if not
          if (userLatitude == null || userLongitude == null)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, color: Colors.grey, size: 70),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Please provide your location to shop from nearby shops',
                      style: TextStyle(
                        fontSize: 60, // Adjust the font size here
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 5, // Limit the text to 2 lines
                      overflow:
                          TextOverflow.ellipsis, // Ensure it doesn't overflow
                    ),
                  ),
                ],
              ),
            ),
          // If latitude and longitude are not available, don't display the shop grid
          if (userLatitude != null && userLongitude != null)
            Expanded(
              child: StreamBuilder(
                stream:
                    FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final shops = snapshot.data!.docs;

                  // Filter shops to only include those with latitude and longitude
                  final filteredShops = shops.where((shop) {
                    final shopData = shop.data() as Map<String, dynamic>;
                    return shopData.containsKey('latitude') &&
                        shopData.containsKey('longitude');
                  }).toList(); // Convert to list after filtering

                  // Sort shops by distance if user has valid latitude and longitude
                  if (userLatitude != null && userLongitude != null) {
                    filteredShops.retainWhere((shop) {
                      final shopData = shop.data() as Map<String, dynamic>;

                      double distance = _calculateDistance(
                          userLatitude!,
                          userLongitude!,
                          shopData['latitude'],
                          shopData['longitude']);
                      return distance <= 2; // Only show shops within 1km
                    });

                    // Sort shops by distance
                    filteredShops.sort((shopA, shopB) {
                      final shopAData = shopA.data() as Map<String, dynamic>;
                      final shopBData = shopB.data() as Map<String, dynamic>;

                      double distanceA = _calculateDistance(
                          userLatitude!,
                          userLongitude!,
                          shopAData['latitude'],
                          shopAData['longitude']);
                      double distanceB = _calculateDistance(
                          userLatitude!,
                          userLongitude!,
                          shopBData['latitude'],
                          shopBData['longitude']);

                      return distanceA.compareTo(distanceB); // Sort by distance
                    });
                  }

                  return GridView.builder(
                    padding: EdgeInsets.all(8.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                      childAspectRatio: 3 / 4,
                    ),
                    itemCount: filteredShops.length, // Use the filtered list
                    itemBuilder: (context, index) {
                      final shop = filteredShops[index];

                      String shopImage = (shop.data() as Map<String, dynamic>)
                                  .containsKey('img') &&
                              (shop.data() as Map<String, dynamic>)['img'] !=
                                  null
                          ? (shop.data() as Map<String, dynamic>)['img']
                          : 'https://zaimiaoemrivlpmnujvm.supabase.co/storage/v1/object/public/items/shop_imgs/store.png';
                      return GestureDetector(
                        onTap: () {
                          // Navigate to Shop Menu when a shop is tapped
                          navigateToShopMenu(context, shop.id,
                              shop.data() as Map<String, dynamic>);
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 4.0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(10.0),
                                  ),
                                  child: Image.network(
                                    shopImage, // Use default shop icon if image is missing
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  (loadingProgress
                                                          .expectedTotalBytes ??
                                                      1)
                                              : null,
                                        ),
                                      );
                                    },
                                    errorBuilder:
                                        (context, error, stackTrace) => Center(
                                            child: Icon(Icons.error,
                                                color: Colors.red)),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      shop['shopName'] ?? 'Shop Name',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4.0),
                                    Text(
                                      shop['vendorName'] ?? 'Vendor Name',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    SizedBox(height: 8.0),
                                    Row(
                                      children: [
                                        Icon(Icons.location_on,
                                            color: Colors.orange),
                                        SizedBox(width: 4.0),
                                        Expanded(
                                          child: Text(
                                            shop['shopAddress'] ??
                                                'Shop Address',
                                            style: TextStyle(
                                              fontSize: 12.0,
                                              color: Colors.grey[600],
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4.0),
                                    Row(
                                      children: [
                                        Icon(Icons.phone, color: Colors.green),
                                        SizedBox(width: 4.0),
                                        Expanded(
                                          child: Text(
                                            shop['phone'] ?? 'Contact Number',
                                            style: TextStyle(
                                              fontSize: 12.0,
                                              color: Colors.grey[600],
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
