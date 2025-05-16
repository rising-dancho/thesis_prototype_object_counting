import 'package:flutter/material.dart';
import 'package:tectags/screens/navigation/navigation_menu.dart';
import 'package:tectags/services/api.dart';
import 'package:tectags/services/shared_prefs_service.dart';
import 'package:tectags/widgets/custom_scaffold.dart';
import 'package:tectags/screens/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formLogInKey = GlobalKey<FormState>();
  bool rememberPassword = true;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscureText = true;

  @override
  void initState() {
    super.initState();

    SharedPrefsService.loadRememberPassword().then((value) {
      setState(() {
        rememberPassword = value;
      });
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
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
      child: CustomScaffold(
        child: SingleChildScrollView(
          child: Form(
            key: _formLogInKey,
            child: Column(
              children: [
                const SizedBox(height: 30),
                Image.asset(
                  'assets/images/tectags_logo_nobg.png',
                  width: 200,
                  height: 200,
                ),
                const SizedBox(height: 5),
                const Text(
                  'Log in to your account',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 20.0,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextFormField(
                    controller: emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Email';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter Email',
                      hintStyle: const TextStyle(color: Colors.black26),
                      filled: true,
                      fillColor: const Color.fromARGB(255, 255, 255, 255),
                      border: InputBorder.none,
                      labelStyle:
                          const TextStyle(color: Color.fromRGBO(70, 70, 70, 1)),
                      prefixIcon: const Icon(Icons.email,
                          color: Color.fromRGBO(70, 70, 70, 1)),
                    ),
                  ),
                ),
                const SizedBox(height: 15.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextFormField(
                    controller: passwordController,
                    obscureText: _obscureText,
                    obscuringCharacter: '*',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Password';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter Password',
                      hintStyle: const TextStyle(color: Colors.black26),
                      filled: true,
                      fillColor: const Color.fromARGB(255, 255, 255, 255),
                      border: InputBorder.none,
                      labelStyle:
                          const TextStyle(color: Color.fromRGBO(70, 70, 70, 1)),
                      prefixIcon: const Icon(Icons.lock,
                          color: Color.fromRGBO(70, 70, 70, 1)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Color.fromRGBO(70, 70, 70, 1),
                        ),
                        onPressed: _togglePasswordVisibility,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5.0),
                Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: rememberPassword,
                        onChanged: (bool? value) async {
                          setState(() {
                            rememberPassword = value!;
                          });
                          await SharedPrefsService.saveRememberPassword(
                              value!); // Save the setting
                        },
                        activeColor: const Color.fromARGB(255, 5, 57, 230),
                      ),
                      const Text(
                        'Keep me logged in',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formLogInKey.currentState!.validate()) {
                          var data = {
                            "email": emailController.text,
                            "password": passwordController.text,
                          };

                          Map<String, dynamic>? response;
                          try {
                            response = await API.loginUser(data);
                            debugPrint("API LOGIN Response: $response"); // Debug log
                          } catch (e) {
                            debugPrint("Error during login: $e"); // Debug log
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Login failed. Please try again.')),
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
                            // await SharedPrefsService.saveToken(
                            //     response['token'],
                            //     rememberPassword); // Pass rememberPassword
                            // FOR TESTING`
                            await SharedPrefsService.saveToken(
                                response['token'],
                                true); // Pass rememberPassword

                            String? savedToken =
                                await SharedPrefsService.getToken();
                            debugPrint("Saved token: $savedToken");

                            // Save userId in SharedPreferences
                            if (response.containsKey('userId')) {
                              await SharedPrefsService.saveUserId(
                                  response['userId']);
                            }

                            // ✅ Save user role
                            if (response.containsKey('role')) {
                              await SharedPrefsService.setRole(
                                  response['role']);
                              debugPrint("Saved role: ${response['role']}");
                            }

                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(response['message'] ??
                                      'Login Successful!')),
                            );

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
                                      'Login failed. Token not received.')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 22, 165, 221),
                        foregroundColor: Colors.white,
                        shadowColor: Colors.grey,
                        elevation: 5,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Don\'t have an account? ',
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
                              builder: (context) => const SignUpScreen()),
                        );
                      },
                      child: const Text(
                        'Sign up',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 55, 247, 253),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
