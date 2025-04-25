import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:tectags/screens/navigation/navigation_menu.dart';
import 'package:tectags/screens/navigation/side_menu.dart';
import 'package:tectags/services/api.dart';
import 'package:tectags/services/shared_prefs_service.dart';
import 'dart:io';

import 'package:tectags/utils/label_formatter.dart';
import 'package:tectags/utils/phone_number_formatter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formSignUpKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    // _loadUserProfile();
    getUserProfile();
  }

  void getUserProfile() async {
    var userProfile = await API.fetchUserProfile();
    if (userProfile != null) {
      // Use the user profile data, e.g., display it in your UI
      debugPrint("User Profile: $userProfile");
    } else {
      debugPrint("Failed to fetch user profile.");
    }
  }

  // void _loadUserProfile() async {
  //   final user =
  //       await SharedPrefsService.getUser(); // Make sure this method exists
  //   setState(() {
  //     _firstNameController.text = user['firstName'] ?? '';
  //     _lastNameController.text = user['lastName'] ?? '';
  //     _emailController.text = user['email'] ?? '';
  //     _contactNumberController.text = user['contactNumber'] ?? '';
  //     _birthdayController.text = user['birthday'] ?? '';
  //     _passwordController.text = ''; // Keep password empty for security
  //   });
  // }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _contactNumberController.dispose();
    _birthdayController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  // {
  //     "email": "admin@gmail.com",
  //     "password": "admin123",
  //     "firstName": "rising",
  //     "lastName": "dancho",
  //     "contactNumber":"09231234567",
  //     "birthday": "1992-05-07"
  // }

  File? _profileImage;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    void _openDatePicker() {
      showDatePicker(
              context: context,
              initialDate: DateTime.now().subtract(Duration(days: 365 * 20)),
              firstDate: DateTime(1900),
              lastDate: DateTime.now())
          .then((pickedDate) {
        if (pickedDate == null) {
          return;
        }
        setState(() {
          _birthdayController.text = DateFormat.yMd().format(pickedDate);
        });
      });
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: const Color.fromARGB(255, 5, 45, 90),
        elevation: 0,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      endDrawer: const SideMenu(),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/tectags_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.3)),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 40),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!)
                              : const AssetImage('assets/profile_picture.png')
                                  as ImageProvider,
                        ),
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blueAccent,
                            ),
                            child: const Icon(Icons.edit,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Edit Your Profile",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(221, 250, 250, 250),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3.0),
                      child: TextFormField(
                        controller: _lastNameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your last name';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Last Name',
                          hintText: 'Enter your last name',
                          hintStyle: const TextStyle(color: Colors.black26),
                          fillColor: Colors.white,
                          filled: true,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3.0),
                      child: TextFormField(
                        controller: _emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'Enter your email',
                          hintStyle: const TextStyle(color: Colors.black26),
                          fillColor: Colors.white,
                          filled: true,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3.0),
                      child: TextFormField(
                        controller: _contactNumberController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(11),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          } else if (!RegExp(r'^09\d{9}$').hasMatch(value)) {
                            return 'Must start with 09 and be 11 digits';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Phone',
                          hintText: 'eg. 09231234567',
                          hintStyle: const TextStyle(color: Colors.black26),
                          fillColor: Colors.white,
                          filled: true,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3.0),
                      child: TextFormField(
                        controller: _birthdayController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your birthday';
                          }
                          return null;
                        },
                        onTap: _openDatePicker,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Birthday',
                          hintText: 'Enter your your birthday',
                          hintStyle: const TextStyle(color: Colors.black26),
                          fillColor: Colors.white,
                          filled: true,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_passwordVisible,
                            obscuringCharacter: '*',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a password';
                              } else if (value.length < 8) {
                                return 'Password must be at least 8 characters long';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'Enter your password',
                              hintStyle: const TextStyle(color: Colors.black26),
                              fillColor:
                                  const Color.fromARGB(255, 255, 255, 255),
                              filled: true,
                              border: InputBorder.none,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _passwordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _passwordVisible = !_passwordVisible;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Must be at least 8 characters',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color.fromARGB(221, 255, 255, 255),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 22, 165, 221),
                        foregroundColor: Colors.white,
                        shadowColor: Colors.grey,
                        elevation: 5,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 105, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        if (_formSignUpKey.currentState!.validate()) {
                          var data = {
                            "email": _emailController.text,
                            "password": _passwordController.text,
                            "firstName": LabelFormatter.titleCase(
                                _firstNameController.text),
                            "lastName": LabelFormatter.titleCase(
                                _lastNameController.text),
                            "contactNumber": PhoneNumberFormatter.format(
                                _contactNumberController.text),
                            "birthday": _birthdayController.text,
                          };

                          // {
                          //     "email": "admin@gmail.com",
                          //     "password": "admin123",
                          //     "firstName": "rising",
                          //     "lastName": "dancho",
                          //     "contactNumber":"09234699665",
                          //     "birthday": "1992-05-07"
                          // }

                          Map<String, dynamic>? response;
                          try {
                            response = await API.updateUserProfile(data);
                            debugPrint("API Response: $response"); // Debug log
                          } catch (e) {
                            debugPrint(
                                "Error during registration: $e"); // Debug log
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Registration failed. Please try again.')),
                            );
                            return;
                          }

                          // Check for errors in the response
                          if (response != null &&
                              response.containsKey('error') &&
                              response['error'] != null) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(response['error'])),
                            );
                            return;
                          }

                          // Check for token in the response
                          if (response != null &&
                              response.containsKey('token')) {
                            await SharedPrefsService.saveTokenWithoutCheck(
                                response['token']);

                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Changes saved successfully!')),
                            );

                            _emailController.clear();
                            _passwordController.clear();
                            _firstNameController.clear();
                            _lastNameController.clear();

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const NavigationMenu()),
                            );
                          } else {
                            // Handle case where token is missing
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Registration failed. Token not received.')),
                            );
                          }
                        }
                      },
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 15.0,
                        ),
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
}
