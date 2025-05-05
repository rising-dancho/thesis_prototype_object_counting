import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:tectags/screens/navigation/side_menu.dart';
import 'package:tectags/services/api.dart';
import 'package:tectags/services/shared_prefs_service.dart';
import 'dart:io';

import 'package:tectags/utils/label_formatter.dart';
// import 'package:tectags/utils/phone_number_formatter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formUpdateKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  bool _currentPasswordVisible = false;
  bool _newPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() async {
    var userProfile = await API.fetchUserProfile();
    if (userProfile != null) {
      DateTime dateTime = DateTime.parse(userProfile['birthday']);
      String formattedDate = DateFormat('MM/dd/yyyy').format(dateTime);

      setState(() {
        _firstNameController.text = userProfile['firstName'] ?? '';
        _lastNameController.text = userProfile['lastName'] ?? '';
        _emailController.text = userProfile['email'] ?? '';
        _contactNumberController.text = userProfile['contactNumber'] ?? '';
        _birthdayController.text = formattedDate;
        _currentPasswordController.text =
            ''; // Keep password empty for security
        _newPasswordController.text = "";
      });
      debugPrint("User Profile: $userProfile");

      String? userId = await SharedPrefsService.getUserId();
      debugPrint("User ID: $userId"); // Log the user ID
    } else {
      debugPrint("Failed to fetch user profile.");
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _contactNumberController.dispose();
    _birthdayController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
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
    final today = DateTime.now();
    final latestAllowedBirthday =
        today.subtract(const Duration(days: 365 * 10)); // 10 years ago
    void openDatePicker() {
      showDatePicker(
        context: context,
        initialDate: DateTime(2000),
        firstDate: DateTime(1900),
        lastDate: latestAllowedBirthday,
      ).then((pickedDate) {
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
        backgroundColor: Colors.black,
        elevation: 0,
        foregroundColor: Colors.white,
        // title: const Text('My Profile'),
        // backgroundColor: const Color.fromARGB(255, 5, 45, 90),
        // elevation: 0,
        // foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      endDrawer: const SideMenu(),
      body: SafeArea(
        child: Stack(
          children: [
            SizedBox.expand(
                child: Image.asset(
              'assets/images/tectags_bg.png',
              fit: BoxFit.cover,
            )),
            // Background dim layer
            Container(
              color: Colors.black.withOpacity(0.6),
            ),
            Container(color: Colors.black.withOpacity(0.3)),
            Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 2, vertical: 40),
                child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Form(
                            key: _formUpdateKey,
                            child: Column(
                              children: [
                                Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    CircleAvatar(
                                      radius: 60,
                                      backgroundImage: _profileImage != null
                                          ? FileImage(_profileImage!)
                                          : const AssetImage(
                                                  'assets/icons/profile_picture.png')
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
                                    fontSize: 28,
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromARGB(221, 250, 250, 250),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Personal Information",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            Color.fromARGB(221, 250, 250, 250),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 3.0),
                                      child: TextFormField(
                                        controller: _firstNameController,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter your first name';
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          labelText: 'First Name',
                                          hintText: 'Enter your first name',
                                          hintStyle: const TextStyle(
                                              color: Colors.black26),
                                          fillColor: Colors.white,
                                          filled: true,
                                          prefixIcon: const Icon(
                                              Icons.person_2_rounded,
                                              color: Color.fromRGBO(
                                                  70, 70, 70, 1)),
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 3.0),
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
                                          hintStyle: const TextStyle(
                                              color: Colors.black26),
                                          fillColor: Colors.white,
                                          filled: true,
                                          prefixIcon: const Icon(
                                              Icons.person_2_rounded,
                                              color: Color.fromRGBO(
                                                  70, 70, 70, 1)),
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20.0),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 3.0),
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
                                          hintStyle: const TextStyle(
                                              color: Colors.black26),
                                          fillColor: Colors.white,
                                          filled: true,
                                          prefixIcon: const Icon(Icons.email,
                                              color: Color.fromRGBO(
                                                  70, 70, 70, 1)),
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20.0),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 3.0),
                                      child: TextFormField(
                                        controller: _contactNumberController,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                          LengthLimitingTextInputFormatter(11),
                                        ],
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter your phone number';
                                          } else if (!RegExp(r'^09\d{9}$')
                                              .hasMatch(value)) {
                                            return 'Must start with 09 and be 11 digits';
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          labelText: 'Phone',
                                          hintText: 'eg. 09231234567',
                                          hintStyle: const TextStyle(
                                              color: Colors.black26),
                                          fillColor: Colors.white,
                                          filled: true,
                                          prefixIcon: const Icon(Icons.phone,
                                              color: Color.fromRGBO(
                                                  70, 70, 70, 1)),
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20.0),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 3.0),
                                      child: TextFormField(
                                        controller: _birthdayController,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter your birthday';
                                          }
                                          return null;
                                        },
                                        onTap: openDatePicker,
                                        readOnly: true,
                                        decoration: InputDecoration(
                                          labelText: 'Birthday',
                                          hintText: 'Enter your your birthday',
                                          hintStyle: const TextStyle(
                                              color: Colors.black26),
                                          fillColor: Colors.white,
                                          filled: true,
                                          prefixIcon: const Icon(
                                              Icons.calendar_month,
                                              color: Color.fromRGBO(
                                                  70, 70, 70, 1)),
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Container(
                                    width: double
                                        .infinity, // Makes the button take all horizontal space
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                            255, 22, 165, 221),
                                        foregroundColor: Colors.white,
                                        shadowColor: Colors.grey,
                                        elevation: 5,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 105, vertical: 15),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      onPressed: () async {
                                        if (_formUpdateKey.currentState!
                                            .validate()) {
                                          // Validate inputs
                                          if (_firstNameController
                                                  .text.isEmpty ||
                                              _lastNameController
                                                  .text.isEmpty ||
                                              _contactNumberController
                                                  .text.isEmpty ||
                                              _birthdayController
                                                  .text.isEmpty) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                      'Please fill all fields.')),
                                            );
                                            return;
                                          }
                                          // Profile data to update (only include fields expected by the backend)
                                          Map<String, dynamic> profileData = {
                                            "firstName":
                                                LabelFormatter.titleCase(
                                                    _firstNameController.text),
                                            "lastName":
                                                LabelFormatter.titleCase(
                                                    _lastNameController.text),
                                            "contactNumber":
                                                _contactNumberController.text,
                                            "birthday": _birthdayController
                                                .text, // Ensure format is YYYY-MM-DD
                                          };

                                          // Get userId from SharedPreferences
                                          String? userId =
                                              await SharedPrefsService
                                                  .getUserId();
                                          debugPrint(
                                              "User ID: $userId"); // Log the user ID

                                          // Check if userId is available
                                          if (userId == null) {
                                            if (!mounted) return;
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                      'User ID not found. Please log in again.')),
                                            );
                                            return;
                                          }

                                          // Call the API to update profile
                                          Map<String, dynamic>? response;
                                          try {
                                            response =
                                                await API.updateUserProfile(
                                                    userId, profileData);
                                            debugPrint(
                                                "API Response: $response"); // Debug log

                                            if (!mounted) return;

                                            // Handle response
                                            if (response != null &&
                                                response.containsKey('error')) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        'Failed to update profile: ${response['error']}')),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    content: Text(
                                                        'Profile updated successfully!')),
                                              );
                                              // Optionally navigate back or update UI
                                            }
                                          } catch (e) {
                                            debugPrint(
                                                "Error during profile update: $e"); // Debug log
                                            if (!mounted) return;
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                      'Profile update failed. Please try again.')),
                                            );
                                          }
                                        }
                                      },
                                      child: const Text(
                                        'Save',
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          fontSize: 15.0,
                                        ),
                                      ),
                                    )),
                                const SizedBox(height: 30.0),
                              ],
                            )),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Change Password",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color.fromARGB(221, 250, 250, 250),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 3.0),
                              child: TextFormField(
                                controller: _currentPasswordController,
                                obscureText: !_currentPasswordVisible,
                                obscuringCharacter: '*',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your current password';
                                  } else if (value.length < 8) {
                                    return 'Password must be at least 8 characters long';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Current Password',
                                  hintText: 'Enter your current password',
                                  hintStyle:
                                      const TextStyle(color: Colors.black26),
                                  fillColor:
                                      const Color.fromARGB(255, 255, 255, 255),
                                  filled: true,
                                  prefixIcon: const Icon(Icons.lock,
                                      color: Color.fromRGBO(70, 70, 70, 1)),
                                  border: InputBorder.none,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _currentPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _currentPasswordVisible =
                                            !_currentPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 3.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormField(
                                    controller: _newPasswordController,
                                    obscureText: !_newPasswordVisible,
                                    obscuringCharacter: '*',
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your new password';
                                      } else if (value.length < 8) {
                                        return 'Password must be at least 8 characters long';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'New Password',
                                      hintText: 'Enter your new password',
                                      hintStyle: const TextStyle(
                                          color: Colors.black26),
                                      fillColor: const Color.fromARGB(
                                          255, 255, 255, 255),
                                      filled: true,
                                      prefixIcon: const Icon(Icons.lock,
                                          color: Color.fromRGBO(70, 70, 70, 1)),
                                      border: InputBorder.none,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _newPasswordVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _newPasswordVisible =
                                                !_newPasswordVisible;
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
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                            width: double
                                .infinity, // Makes the button take all horizontal space
                            child: ElevatedButton(
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
                                if (_formUpdateKey.currentState!.validate()) {
                                  // Validate inputs
                                  if (_currentPasswordController.text.isEmpty ||
                                      _newPasswordController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Please enter both passwords.')),
                                    );
                                    return;
                                  }
                                  // Get userId
                                  String? userId =
                                      await SharedPrefsService.getUserId();
                                  debugPrint("User ID: $userId");

                                  if (userId == null) {
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'User ID not found. Please log in again.')),
                                    );
                                    return;
                                  }
                                  // Change password
                                  Map<String, dynamic>? response;
                                  try {
                                    response = await API.changePassword(
                                      userId,
                                      _currentPasswordController.text,
                                      _newPasswordController.text,
                                    );
                                    debugPrint(
                                        "Change Password Response: $response");

                                    if (!mounted) return;

                                    if (response != null &&
                                        response.containsKey('error')) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Failed to change password: ${response['error']}')),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Password changed successfully!')),
                                      );
                                      // Clear password fields
                                      _currentPasswordController.clear();
                                      _newPasswordController.clear();
                                    }
                                  } catch (e) {
                                    debugPrint(
                                        "Error during password change: $e");
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Password change failed. Please try again.')),
                                    );
                                  }
                                }
                              },
                              child: const Text(
                                'Change',
                                style: TextStyle(
                                    fontFamily: 'Roboto', fontSize: 15.0),
                              ),
                            )),
                      ],
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// GO BACK HERE TO ADD THE JWT REQUIRE AUTH
// https://grok.com/share/c2hhcmQtMg%3D%3D_4d2720e7-a164-4ed4-918d-578a8ce368b9

