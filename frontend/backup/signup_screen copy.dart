import 'package:flutter/material.dart';
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
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  // var confirmPasswordController = TextEditingController();
  var fullNameController = TextEditingController();

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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Email';
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
                const SizedBox(height: 20.0),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 3.0),
                //   child: TextFormField(
                //     controller: confirmPasswordController,
                //     obscureText: true,
                //     obscuringCharacter: '*',
                //     validator: (value) {
                //       if (value == null || value.isEmpty) {
                //         return 'Please confirm your Password';
                //       }
                //       if (value != passwordController.text) {
                //         return 'Passwords do not match';
                //       }
                //       return null;
                //     },
                //     decoration: InputDecoration(
                //       label: const Text('Confirm Password'),
                //       hintText: 'Re-enter Password',
                //       hintStyle: const TextStyle(color: Colors.black26),
                //       fillColor: Colors.grey[200],
                //       filled: true,
                //       border: OutlineInputBorder(
                //         borderSide: const BorderSide(color: Colors.black12),
                //         borderRadius: BorderRadius.circular(20),
                //       ),
                //       enabledBorder: const OutlineInputBorder(
                //         borderSide: BorderSide(color: Colors.black12),
                //       ),
                //     ),
                //   ),
                // ),
                const SizedBox(height: 30.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        var data = {
                          "email": emailController.text,
                          "password": passwordController.text,
                          "fullName": fullNameController.text,
                        };

                        await API.registerUser(data);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (e) => const NavigationMenu()),
                        );
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
    );
  }
}
