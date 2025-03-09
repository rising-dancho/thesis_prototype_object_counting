import 'package:flutter/material.dart';
import 'package:techtags/screens/navigation_menu.dart';
import 'package:techtags/theme/theme.dart';
import 'package:techtags/widgets/custom_scaffold.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formLogInKey = GlobalKey<FormState>();
  bool rememberPassword = true;

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
        child: Column(
          children: [
            const SizedBox(height: 30),
            Image.asset(
              'assets/images/tectags_logo_nobg.png',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 20),
            Text(
              'Log in to your account',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 23.0,
                fontWeight: FontWeight.w900,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
            ),
            const SizedBox(height: 40.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                  hintStyle: const TextStyle(
                    color: Colors.black26,
                  ),
                  fillColor: Colors.grey[200],
                  filled: true,
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.black12,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black12,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextFormField(
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
                  hintStyle: const TextStyle(
                    color: Colors.black26,
                  ),
                  fillColor: Colors.grey[200],
                  filled: true,
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.black12,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  value: rememberPassword,
                  onChanged: (bool? value) {
                    setState(() {
                      rememberPassword = value!;
                    });
                  },
                  activeColor: lightColorScheme.primary,
                ),
                const Text(
                  'Keep me logged in',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // if (_formLogInKey.currentState!.validate()) {
                    //   ScaffoldMessenger.of(context).showSnackBar(
                    //     const SnackBar(
                    //       content: Text('Processing Data'),
                    //     ),
                    //   );
                    // }

                    // Navigate to HomeScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NavigationMenu()),
                    );
                  },
                  child: const Text(
                    'LOGIN',
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
          ],
        ),
      ),
    );
  }
}
