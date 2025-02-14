import 'package:flutter/material.dart';

class FreshPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Fresh"),
        backgroundColor: Colors.green[100],
      ),
      body: Center(
        child: Text("Fresh Page Content Here"),
      ),
    );
  }
}
