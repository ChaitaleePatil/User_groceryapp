import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'MenuPage.dart'; // Import the ShopMenuPage from the new file

class ShopsPage extends StatelessWidget {
  // Method to build the search bar
  Widget buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                  hintText: "Search for your fav 'shop'",
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

  // Method to handle shop tap and navigate to the shop menu page
  void navigateToShopMenu(
      BuildContext context, String userId, Map<String, dynamic> shopDetails) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ShopMenuPage(userId: userId, shopDetails: shopDetails),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Custom Header with store icon and text in one line
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Image.asset(
                  'lib/icons/store.png',
                  height: 40,
                  width: 40,
                ),
                SizedBox(width: 12),
                Text(
                  'Shop Finder',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: buildSearchBar(),
          ),

          // StreamBuilder to load shop data from Firestore
          Expanded(
            child: StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final shops = snapshot.data!.docs;

                return GridView.builder(
                  padding: EdgeInsets.all(8.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 3 / 4,
                  ),
                  itemCount: shops.length,
                  itemBuilder: (context, index) {
                    final shop = shops[index];

                    // Get the shop image URL or use the default if not available
                    String shopImage = (shop.data() as Map<String, dynamic>)
                                .containsKey('img') &&
                            (shop.data() as Map<String, dynamic>)['img'] != null
                        ? (shop.data() as Map<String, dynamic>)['img']
                        : 'https://zaimiaoemrivlpmnujvm.supabase.co/storage/v1/object/public/items/shop%20imgs/store.png'; // Default image URL

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
                                  shopImage, // Use the shop image or default image
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
                                  errorBuilder: (context, error, stackTrace) =>
                                      Center(
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
                                          shop['shopAddress'] ?? 'Shop Address',
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
