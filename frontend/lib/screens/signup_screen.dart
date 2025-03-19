import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techtags/screens/login_screen.dart';
import 'package:techtags/screens/navigation/navigation_menu.dart';
import 'package:techtags/services/api.dart';
import 'package:techtags/widgets/custom_scaffold.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  // var confirmPasswordController = TextEditingController();
  var fullNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    testSaveToken();
  }

  Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      debugPrint("Token saved successfully: $token"); // Debug log
    } catch (e) {
      debugPrint("Error saving token: $e"); // Debug log
    }
  }

  Future<void> testSaveToken() async {
    await saveToken("test_token");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/tectags_bg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        child: CustomScaffold(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Image.asset(
                    'assets/images/tectags_logo_nobg.png',
                    width: 200,
                    height: 200,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Create your account',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w900,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                  const SizedBox(height: 40.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3.0),
                    child: TextFormField(
                      controller: fullNameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Full Name';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        label: const Text('Full Name'),
                        hintText: 'Enter Full Name',
                        hintStyle: const TextStyle(color: Colors.black26),
                        fillColor: Colors.grey[200],
                        filled: true,
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.black12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3.0),
                    child: TextFormField(
                      controller: emailController,
                      // VALID EMAILS ONLY!
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Email';
                        }
                        if (!RegExp(
                                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                            .hasMatch(value)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        label: const Text('Email'),
                        hintText: 'Enter Email',
                        hintStyle: const TextStyle(color: Colors.black26),
                        fillColor: Colors.grey[200],
                        filled: true,
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.black12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3.0),
                    child: TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      obscuringCharacter: '*',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Password';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        label: const Text('Password'),
                        hintText: 'Enter Password',
                        hintStyle: const TextStyle(color: Colors.black26),
                        fillColor: Colors.grey[200],
                        filled: true,
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.black12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            var data = {
                              "email": emailController.text,
                              "password": passwordController.text,
                              "fullName": fullNameController.text,
                            };

                            Map<String, dynamic>? response;
                            try {
                              response = await API.registerUser(data);
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

                            // Check if response is null
                            if (response == null) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Server error: No response received')),
                              );
                              return;
                            }

                            // Check for errors in the response
                            if (response.containsKey('error') &&
                                response['error'] != null) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(response['error'])),
                              );
                              return;
                            }

                            // Check for token in the response
                            if (response.containsKey('token')) {
                              await saveToken(response['token']);

                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(response['message'] ??
                                        'Registration Successful!')),
                              );

                              emailController.clear();
                              passwordController.clear();
                              fullNameController.clear();

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const NavigationMenu()),
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.grey,
                          elevation: 5,
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Register',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (e) => const LoginScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Login',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 55, 247, 253),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
