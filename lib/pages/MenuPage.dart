import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Import CartPage
import 'cart.dart';

class ShopMenuPage extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> shopDetails;

  ShopMenuPage({required this.userId, required this.shopDetails});

  @override
  _ShopMenuPageState createState() => _ShopMenuPageState();
}

class _ShopMenuPageState extends State<ShopMenuPage> {
  // Map to hold the cart items
  Map<String, int> cartItems = {};

  // Fetch products for the shop from the 'shopmenu' collection
  Future<List<QueryDocumentSnapshot>> fetchMenuItems() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('shopmenu')
        .doc(widget.userId) // User's ID to fetch the shop's menu
        .collection('items')
        .get();
    return snapshot.docs;
  }

  // Method to handle adding item to the cart
  void addToCart(String itemId) {
    setState(() {
      if (cartItems.containsKey(itemId)) {
        cartItems[itemId] = cartItems[itemId]! + 1;
      } else {
        cartItems[itemId] = 1;
      }
    });
  }

  // Method to open the cart
  void openCart(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CartPage(cartItems: cartItems)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: FutureBuilder(
        future: fetchMenuItems(),
        builder:
            (context, AsyncSnapshot<List<QueryDocumentSnapshot>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No items available.'));
          }

          final items = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Shop Details Header
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(16)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundImage: NetworkImage(
                                widget.shopDetails['img'] ??
                                    'https://via.placeholder.com/150'),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.shopDetails['shopName'] ?? 'Shop Name',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  widget.shopDetails['vendorName'] ??
                                      'Vendor Name',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                Row(
                                  children: [
                                    Icon(Icons.location_on,
                                        color: Colors.orange),
                                    SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        widget.shopDetails['shopAddress'] ??
                                            'Shop Address',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8.0),
                                Row(
                                  children: [
                                    Icon(Icons.phone, color: Colors.green),
                                    SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        widget.shopDetails['phone'] ??
                                            'Contact Number',
                                        style: TextStyle(
                                          fontSize: 14,
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
                    ],
                  ),
                ),

                // Menu Items Grid (Two Items per Row)
                GridView.builder(
                  padding: EdgeInsets.all(8.0),
                  shrinkWrap: true,
                  itemCount: items.length,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Two items per row
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio:
                        0.75, // Adjust the item aspect ratio for better fitting
                  ),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final itemId = item.id;

                    // Check if the 'img' field exists, and use the default URL if it doesn't
                    String itemImage = (item.data() as Map<String, dynamic>?)
                                    ?.containsKey('img') ==
                                true &&
                            (item.data() as Map<String, dynamic>)!['img'] !=
                                null
                        ? (item.data() as Map<String, dynamic>)!['img']
                        : 'https://zaimiaoemrivlpmnujvm.supabase.co/storage/v1/object/public/items/shop_imgs/store.png';
                    // Fetching discount values safely
                    final itemData = item.data() as Map<String, dynamic>;
                    String? discountPrice = itemData['discountPrice'];
                    String? discountPercentage = itemData['discountPercentage'];

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 6.0,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Larger Square Image with increased width
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: Image.network(
                                itemImage, // Use the item image or default image
                                width: 200, // Increased width
                                height: 100, // Keeping the height the same
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Center(child: Icon(Icons.error)),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              item['productName'],
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            // Price and Discount in a Row
                            Row(
                              children: [
                                // Discounted Price
                                if (discountPrice != null)
                                  Text(
                                    '₹$discountPrice',
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                  ),
                                SizedBox(width: 8),
                                // Original Price with Strikethrough
                                Text(
                                  '₹${item['price']}',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 8,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                // Display discount percentage if available
                                if (discountPercentage != null)
                                  SizedBox(width: 8),
                                if (discountPercentage != null)
                                  Text(
                                    '$discountPercentage% off',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 8,
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: 8),
                            // Add to Cart Button
                            if (cartItems[itemId] == null ||
                                cartItems[itemId]! == 0)
                              ElevatedButton(
                                onPressed: () {
                                  addToCart(itemId); // Adding item to cart
                                },
                                child: Text(" Add to Cart "),
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.green),
                                  foregroundColor:
                                      MaterialStateProperty.all(Colors.white),
                                ),
                              )
                            else
                              ElevatedButton(
                                onPressed: () {
                                  openCart(context); // Go to Cart Page
                                },
                                child: Text(" Go to Cart "),
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.green),
                                  foregroundColor:
                                      MaterialStateProperty.all(Colors.white),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
