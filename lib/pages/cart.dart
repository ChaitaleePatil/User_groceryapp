import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartPage extends StatefulWidget {
  final Map<String, dynamic> cartItems;

  CartPage({required this.cartItems});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late Map<String, dynamic> _cartItems;

  @override
  void initState() {
    super.initState();
    _cartItems = Map.from(
        widget.cartItems); // Clone the cart items for real-time updates
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Your Cart",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: _cartItems.isEmpty
          ? const Center(
              child: Text(
                "Your cart is empty!",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCartSummary(),
                    const SizedBox(height: 16),
                    _buildOrderItems(),
                    const SizedBox(height: 16),
                    _buildBillDetails(),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  Widget _buildCartSummary() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text(
        "₹25 saved! Save more on every order with One membership",
        style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green),
      ),
    );
  }

  Widget _buildOrderItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _cartItems.keys.map((itemId) {
        final itemData = _cartItems[itemId];
        final itemImage = itemData['image'] ?? '';
        final itemPrice = itemData['price'];
        final itemQuantity = itemData['quantity'];
        final vendorName = itemData['vendorName']; // Vendor name
        final shopName = itemData['shopName']; // Shop name

        return Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: itemImage.isNotEmpty
                      ? Image.network(
                          itemImage,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image_not_supported,
                                  color: Colors.grey),
                        )
                      : const Icon(Icons.shopping_cart,
                          size: 40, color: Colors.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        itemId,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text("Price: ₹$itemPrice",
                          style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 4),
                      Text("Shop: $shopName",
                          style: const TextStyle(fontSize: 14)),
                      Text("Vendor: $vendorName",
                          style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Quantity: $itemQuantity",
                              style: const TextStyle(fontSize: 14)),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeItem(itemId),
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
      }).toList(),
    );
  }

  Widget _buildBillDetails() {
    double totalPrice = _calculateTotalPrice();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBillDetailRow(
                "Item Total", "₹${totalPrice.toStringAsFixed(2)}"),
            const SizedBox(height: 8),
            _buildBillDetailRow("Handling Fee", "₹8.10"),
            const SizedBox(height: 8),
            _buildBillDetailRow("Small Cart Fee", "₹15.00"),
            const SizedBox(height: 8),
            const Text(
              "No small cart fee on orders above ₹500",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const Divider(height: 20, thickness: 1),
            _buildBillDetailRow(
                "To Pay", "₹${(totalPrice + 23.10).toStringAsFixed(2)}",
                isBold: true),
          ],
        ),
      ),
    );
  }

  Widget _buildBillDetailRow(String label, String value,
      {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 14,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value,
            style: TextStyle(
                fontSize: 14,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  Widget _buildBottomButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () async {
          await saveCartToFirestore();
        },
        child: const Text(
          "Proceed to place the order",
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  void _removeItem(String itemId) {
    setState(() {
      _cartItems.remove(itemId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$itemId removed from the cart!")),
    );
  }

  Future<void> saveCartToFirestore() async {
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cart is empty. Cannot place an order.")),
      );
      return;
    }

    try {
      List<Map<String, dynamic>> cartItemsWithVendorInfo = [];

      // Iterate over cartItems to add vendor and shop name
      for (var itemId in _cartItems.keys) {
        final itemData = _cartItems[itemId];
        final vendorName = itemData['vendorName']; // Vendor name
        final shopName = itemData['shopName']; // Shop name

        // Append vendorName and shopName to the cart item details
        cartItemsWithVendorInfo.add({
          ...itemData, // Merge existing item data
          'vendorName': vendorName,
          'shopName': shopName,
        });
      }

      final customerorder = {
        'cartDetails': cartItemsWithVendorInfo,
        'timestamp': FieldValue.serverTimestamp(),
        'totalItems': _cartItems.length,
        'totalPrice': _calculateTotalPrice(),
      };

      final collectionRef =
          FirebaseFirestore.instance.collection('customerOrders');
      await collectionRef.add(customerorder);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order placed successfully!")),
      );

      setState(() {
        _cartItems.clear();
      });

      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to place order: $error")),
      );
    }
  }

  double _calculateTotalPrice() {
    double total = 0.0;
    _cartItems.forEach((key, value) {
      total += (value['price'] * value['quantity']);
    });
    return total;
  }
}
