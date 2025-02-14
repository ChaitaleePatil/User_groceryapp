import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:groceryapp/pages/login_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with the options for the current platform
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Grocery App',
      theme: ThemeData(primarySwatch: Colors.green),
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
