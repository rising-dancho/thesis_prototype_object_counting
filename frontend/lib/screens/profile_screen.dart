import 'package:flutter/material.dart';
import 'package:tectags/screens/tensorflow/tensorflow_lite.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _emailController =
      TextEditingController(text: 'user@example.com');
  final TextEditingController _phoneController =
      TextEditingController(text: '+1234567890');
  final TextEditingController _addressController =
      TextEditingController(text: '123 Main Street, City, Country');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color.fromARGB(255, 5, 45, 90),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate to the TensorflowLite screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const TensorflowLite()),
            );
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/tectags_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/profile_picture.png'),
            ),
            const SizedBox(height: 20),
            _buildTextField(
                controller: _emailController,
                icon: Icons.email,
                label: 'Email'),
            _buildTextField(
                controller: _phoneController,
                icon: Icons.phone,
                label: 'Phone'),
            _buildTextField(
                controller: _addressController,
                icon: Icons.location_on,
                label: 'Address'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implement the save functionality here
                // For example, save the updated information to a database or API
                print('Email: ${_emailController.text}');
                print('Phone: ${_phoneController.text}');
                print('Address: ${_addressController.text}');
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller,
      required IconData icon,
      required String label}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
