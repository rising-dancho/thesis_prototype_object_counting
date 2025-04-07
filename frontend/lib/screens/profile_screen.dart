import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tectags/screens/navigation/side_menu.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Map<String, TextEditingController> _controllers = {
    'Full Name': TextEditingController(),
    'Email': TextEditingController(),
    'Phone': TextEditingController(),
    'Password': TextEditingController(),
  };

  File? _profileImage; // Stores selected profile picture

  // Function to pick an image
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _profileImage = File(image.path); // Updates the profile picture
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: const Color.fromARGB(255, 5, 45, 90),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      endDrawer: const SideMenu(),
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

            // Profile Picture with Edit Option
            GestureDetector(
              onTap: _pickImage, // Opens image picker
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _profileImage != null
                        ? Image.file(_profileImage!).image // Corrected here
                        : const AssetImage('assets/profile_picture.png')
                            as ImageProvider,
                    child: _profileImage == null
                        ? const Icon(Icons.camera_alt,
                            size: 30, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Edit your profile",
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 20,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Dynamic Input Fields
            _buildTextField(label: 'Full Name', icon: Icons.person),
            _buildTextField(label: 'Email', icon: Icons.email),
            _buildTextField(label: 'Phone', icon: Icons.phone),
            _buildTextField(
                label: 'Password', icon: Icons.lock, obscureText: true),

            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shadowColor: Colors.grey,
                elevation: 5,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                // Add save functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Changes saved successfully!')),
                );
              },
              child: const Text(
                'Save changes',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.bold,
                  fontSize: 15.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: _controllers[label], // Dynamically selects the controller
        obscureText: obscureText, // Used for password field
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[200],
          prefixIcon: Icon(icon, color: const Color.fromARGB(255, 51, 51, 51)),
          labelText: label,
          labelStyle: const TextStyle(color: Color.fromARGB(255, 51, 51, 51)),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.orange, width: 2),
          ),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
