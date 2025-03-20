import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techtags/screens/login_screen.dart';
import 'package:techtags/screens/navigation/navigation_menu.dart';
import 'package:techtags/screens/opencv/opencv.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token'); // Remove the jasonwebtoken (JWT)
    await prefs.remove('userId'); // Remove the user id
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 5, 45, 90),  
            ),
            child: Container(
              alignment: Alignment.center,
              child: Image.asset(
                'assets/images/tectags_logo_nobg.png', // Replace with your logo's asset path
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const NavigationMenu()),
              );
            },
          ),
          // ListTile(
          //   leading: const Icon(Icons.history),
          //   title: const Text('Activity Logs'),
          //   onTap: () {
          //     Navigator.pushReplacement(
          //       context,
          //       MaterialPageRoute(builder: (context) => const ActivityLogs( )),
          //     );
          //   },
          // ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Edit Profile'),
            onTap: () {
              // Navigator.pushReplacement(
              //   context,
              //   MaterialPageRoute(builder: (context) => const ActivityLogs()),
              // );
            },
          ),
          ListTile(
            leading: const Icon(Icons.spoke),
            title: const Text('Beta Feature (OpenCV)'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const OpenCV()),
              );
            },
          ),
          const Divider(
            height: 20,
            thickness: 1,
            indent: 20,
            endIndent: 20,
            color: Color.fromARGB(255, 82, 81, 81),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () => logout(context),
          ),
        ],
      ),
    );
  }
}
