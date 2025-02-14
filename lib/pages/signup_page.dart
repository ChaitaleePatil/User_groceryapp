import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'home_page.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:geolocator/geolocator.dart'; // Geolocator package for location
import 'package:permission_handler/permission_handler.dart'; // Permission handler for location
import 'package:geocoding/geocoding.dart'; // Geocoding package for reverse geocoding

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController =
      TextEditingController(); // Address field
  final TextEditingController _latitudeController =
      TextEditingController(); // Latitude field
  final TextEditingController _longitudeController =
      TextEditingController(); // Longitude field
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isListening = false;
  stt.SpeechToText _speech = stt.SpeechToText();
  int _currentQuestionIndex = 0;

  final List<String> _questions = [
    'What is your name?',
    'What is your email?',
    'What is your phone number?',
    'What is your password?'
  ];

  @override
  void initState() {
    super.initState();
    _speech.initialize();
  }

  // Check permissions and get location with reverse geocoding
  Future<void> _getCurrentLocation() async {
    PermissionStatus permission = await Permission.location.request();

    if (permission.isGranted) {
      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Set latitude and longitude
      setState(() {
        _latitudeController.text = position.latitude.toString();
        _longitudeController.text = position.longitude.toString();
      });

      // Use reverse geocoding to get the address
      try {
        List<Placemark>? placemarks = await GeocodingPlatform.instance
            ?.placemarkFromCoordinates(position.latitude, position.longitude);

        if (placemarks != null && placemarks.isNotEmpty) {
          Placemark place = placemarks[0]; // Take the first placemark

          // Log the complete placemark data for debugging
          print("Geocoding result: $place");

          // Check if fields are available and concatenate them
          String fullAddress = '';
          if (place.name != null) fullAddress += place.name!;
          if (place.locality != null) fullAddress += ", ${place.locality}";
          if (place.subAdministrativeArea != null)
            fullAddress += ", ${place.subAdministrativeArea}";
          if (place.country != null) fullAddress += ", ${place.country}";

          // Set the address in the address field
          setState(() {
            _addressController.text = fullAddress.isNotEmpty
                ? fullAddress
                : "Address could not be resolved";
          });
        } else {
          // If no placemarks are found, show the coordinates as fallback
          setState(() {
            _addressController.text =
                "Location detected: [Lat: ${position.latitude}, Long: ${position.longitude}]";
          });
        }
      } catch (e) {
        // Handle errors or exceptions in reverse geocoding
        setState(() {
          _addressController.text =
              "Location detected, but address could not be resolved.";
        });
        print("Error in reverse geocoding: $e");
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission denied!')),
      );
    }
  }

  Future<void> _signUp() async {
    if (_nameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _addressController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      try {
        // Create user with email and password
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Hash the password before saving to Firestore
        String hashedPassword = _hashPassword(_passwordController.text);

        // Save user data in Firestore, including address and location details
        FirebaseFirestore.instance
            .collection('appusers')
            .doc(userCredential.user!.uid)
            .set({
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'address': _addressController.text, // Save the full address
          'latitude': _latitudeController.text, // Save latitude
          'longitude': _longitudeController.text, // Save longitude
          'password': hashedPassword, // Saving hashed password
        });

        // Navigate to HomePage after successful sign-up
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signup successful!')),
        );
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all the details.')),
      );
    }
  }

  // Hash the password before saving it
  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Reset form fields
  void _reset() {
    setState(() {
      _currentQuestionIndex = 0;
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _addressController.clear();
      _latitudeController.clear();
      _longitudeController.clear();
      _passwordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'lib/assets/b4.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Sign Up",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      icon: Icons.phone_outlined,
                      prefixText: '+91 ',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _addressController, // Address input
                      label: 'Address',
                      icon: Icons.location_on_outlined,
                      suffixIcon: IconButton(
                        icon: Icon(Icons.my_location, color: Colors.green),
                        onPressed: _getCurrentLocation, // Get location
                      ),
                    ),
                    const SizedBox(height: 16),
                    // New fields for Latitude and Longitude
                    _buildTextField(
                      controller: _latitudeController,
                      label: 'Latitude',
                      icon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _longitudeController,
                      label: 'Longitude',
                      icon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildPasswordField(),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _signUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          _reset();
                          // _askQuestion(context); // Implement your speech-to-text question functionality if needed
                        },
                        child: const Text("Start Voice Input"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? prefixText,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefixText,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
            color: Colors.green,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
