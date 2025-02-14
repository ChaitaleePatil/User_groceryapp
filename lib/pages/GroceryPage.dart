import 'package:flutter/material.dart';

class GroceryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Grocery"),
        backgroundColor: Colors.green[100],
      ),
      body: Center(
        child: Text("Grocery Page Content Here"),
      ),
    );
  }
}
