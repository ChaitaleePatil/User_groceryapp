import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'cart.dart'; // Import your CartPage

class BeveragesPage extends StatefulWidget {
  @override
  _BeveragesPageState createState() => _BeveragesPageState();
}

class _BeveragesPageState extends State<BeveragesPage> {
  Map<String, Map<String, dynamic>> _cart = {}; // Cart with productName as key
  late CollectionReference shopmenuCollection;

  @override
  void initState() {
    super.initState();
    shopmenuCollection = FirebaseFirestore.instance.collection('shopmenu');
  }

  Future<List<QueryDocumentSnapshot>> _fetchItems() async {
    List<QueryDocumentSnapshot> beverages = [];
    try {
      // Fetch the shopmenu documents
      QuerySnapshot shopmenuDocs = await shopmenuCollection.get();
      for (var doc in shopmenuDocs.docs) {
        // Now iterate over the items collection in each shopmenu document
        CollectionReference itemsCollection = doc.reference.collection('items');
        // Fetch items where the category is 'Beverages'
        QuerySnapshot itemsSnapshot = await itemsCollection
            .where('category', isEqualTo: 'Beverages')
            .get();

        // Add the fetched beverages to the list
        beverages.addAll(itemsSnapshot.docs);
      }
    } catch (e) {
      print("Error fetching items: $e");
    }
    return beverages;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[100],
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Beverages Gallery",
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<QueryDocumentSnapshot>>(
              future: _fetchItems(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No beverages available.'));
                }

                var beverages = snapshot.data!;
                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: beverages.length,
                  itemBuilder: (context, index) {
                    var beverage = beverages[index];
                    return buildBeverageCard(beverage);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _cart.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CartPage(cartItems: _cart),
                  ),
                );
              },
              label: const Text("Go to Cart"),
              icon: const Icon(Icons.shopping_cart),
              backgroundColor: Colors.orange,
            )
          : null,
    );
  }

  Widget buildBeverageCard(QueryDocumentSnapshot beverage) {
    Map<String, dynamic> beverageData = beverage.data() as Map<String, dynamic>;
    String productName = beverageData['productName'] ?? 'No Name';

    // Check if 'img' field is available, otherwise use a default image
    String img = beverageData['img'] ?? 
        'https://zaimiaoemrivlpmnujvm.supabase.co/storage/v1/object/public/items/shop_imgs/images.jpeg'; // Default image URL

    double price = beverageData['price']?.toDouble() ?? 0.0;
    int quantity = _cart[productName]?['quantity'] ?? 0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(10)),
                child: Image.network(
                  img,
                  height: MediaQuery.of(context).size.height * 0.15,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback image if there's an error loading the image
                    return Image.network(
                      'https://zaimiaoemrivlpmnujvm.supabase.co/storage/v1/object/public/items/shop_imgs/images.jpeg', // Default image
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  "₹$price",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                quantity > 0
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                if (quantity > 1) {
                                  _cart[productName]!['quantity']--;
                                } else {
                                  _cart.remove(productName);
                                }
                              });
                            },
                            icon: const Icon(Icons.remove, color: Colors.red),
                          ),
                          Text('$quantity',
                              style: const TextStyle(fontSize: 16)),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _cart[productName]!['quantity']++;
                              });
                            },
                            icon: const Icon(Icons.add, color: Colors.green),
                          ),
                        ],
                      )
                    : ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _cart[productName] = {
                              'productName': productName,
                              'price': price,
                              'quantity': 1,
                              'img': img,
                            };
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text("  Add to Cart  ",
                            style: TextStyle(color: Colors.white)),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
