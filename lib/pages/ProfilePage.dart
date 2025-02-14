import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;
  bool isEditing = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  // Fetch user data using the UID
  Future<void> fetchUserDetails() async {
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('appusers')
          .doc(user!.uid) // Use the UID to fetch the user document
          .get();

      if (userDoc.exists) {
        setState(() {
          userData = userDoc.data() as Map<String, dynamic>;
          nameController.text = userData!['name'] ?? '';
          phoneController.text = userData!['phone'] ?? '';
          addressController.text = userData!['address'] ?? '';
        });
      } else {
        print('User not found');
      }
    }
  }

  Future<void> updateUserDetails() async {
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('appusers')
          .doc(user!.uid) // Use the UID to update the user document
          .update({
        'name': nameController.text,
        'phone': phoneController.text,
        'address': addressController.text,
      });

      setState(() {
        isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully!')),
      );
    }
  }

  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Location services are disabled. Please enable them.')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Location permissions are permanently denied.')),
        );
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    if (placemarks.isNotEmpty) {
      Placemark place = placemarks[0];

      String fullAddress =
          "${place.name}, ${place.locality}, ${place.subAdministrativeArea}, ${place.administrativeArea}, ${place.country}";

      setState(() {
        addressController.text = fullAddress;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.green[100],
        elevation: 0,
        actions: [
          isEditing
              ? IconButton(
                  icon: Icon(Icons.save, color: Colors.black),
                  onPressed: updateUserDetails,
                )
              : IconButton(
                  icon: Icon(Icons.edit, color: Colors.black),
                  onPressed: () {
                    setState(() {
                      isEditing = true;
                    });
                  },
                ),
        ],
      ),
      body: userData == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Icon(Icons.account_circle,
                        size: 100, color: Colors.grey),
                  ),
                  SizedBox(height: 16),
                  _buildEditableField("Name", nameController),
                  _buildEditableField("Phone", phoneController),
                  _buildAddressField(),
                ],
              ),
            ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 4),
          TextField(
            controller: controller,
            enabled: isEditing,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.grey[200],
            ),
          ),
          Divider(),
        ],
      ),
    );
  }

  Widget _buildAddressField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Address",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 4),
          TextField(
            controller: addressController,
            enabled: isEditing,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.grey[200],
              suffixIcon: isEditing
                  ? IconButton(
                      icon: Icon(Icons.location_on),
                      onPressed: getCurrentLocation,
                    )
                  : null,
            ),
          ),
          Divider(),
        ],
      ),
    );
  }
}
