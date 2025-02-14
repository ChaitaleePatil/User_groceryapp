import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NewlyAddedPage extends StatelessWidget {
  // Fetch the newly added items based on timestamp from Firestore
  Future<List<DocumentSnapshot>> _fetchItems() async {
    List<DocumentSnapshot> items = [];
    try {
      // Get the 'shopmenu' collection
      CollectionReference shopmenuCollection =
          FirebaseFirestore.instance.collection('shopmenu');
      QuerySnapshot shopmenuDocs = await shopmenuCollection.get();

      for (var doc in shopmenuDocs.docs) {
        // Fetch the 'items' subcollection for each shopmenu document
        CollectionReference itemsCollection = doc.reference.collection('items');
        QuerySnapshot itemsSnapshot = await itemsCollection.get();

        for (var itemDoc in itemsSnapshot.docs) {
          // Check if the item has a 'timestamp' field
          var itemData = itemDoc.data() as Map<String, dynamic>?;
          if (itemData != null && itemData.containsKey('timestamp')) {
            items.add(itemDoc);
          }
        }
      }

      // Sort the items by timestamp (new to old)
      items.sort((a, b) {
        Timestamp timestampA = a['timestamp'];
        Timestamp timestampB = b['timestamp'];
        return timestampB.compareTo(timestampA); // Sort in descending order
      });
    } catch (e) {
      print("Error fetching items: $e");
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Newly Added"),
        backgroundColor: Colors.green[100],
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _fetchItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No newly added items."));
          }

          List<DocumentSnapshot> items = snapshot.data!;
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              var item = items[index];
              var itemData = item.data() as Map<String, dynamic>;

              // Extract item data
              String productName = itemData['productName'] ?? 'No Name';
              String img = itemData['img'] ??
                  'https://via.placeholder.com/150'; // Default image
              double price = itemData['price']?.toDouble() ?? 0.0;
              String unit = itemData['unit'] ?? 'Unit';
              Timestamp timestamp = itemData['timestamp'];
              String formattedTimestamp = timestamp.toDate().toString();

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: Image.network(
                    img,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                  title: Text(
                    productName,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Price: ₹$price ($unit)"),
                      Text("Added on: $formattedTimestamp"),
                    ],
                  ),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Handle item tap (e.g., navigate to item details page)
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
