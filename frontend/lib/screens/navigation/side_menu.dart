import 'package:flutter/material.dart';
import 'package:tectags/screens/about_screen.dart';
import 'package:tectags/screens/guide_screen.dart';
import 'package:tectags/screens/login_screen.dart';
import 'package:tectags/screens/navigation/navigation_menu.dart';
import 'package:tectags/screens/onboarding/onboarding_view.dart';
import 'package:tectags/screens/otp/pages/otp_login.dart';
import 'package:tectags/screens/profile_screen.dart';
import 'package:tectags/services/shared_prefs_service.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  Future<void> logout(BuildContext context) async {
    await SharedPrefsService.clearUserId(); // Clear user ID
    await SharedPrefsService
        .clearToken(); // Clear token for remembering login state
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
          ListTile(
            leading: const Icon(Icons.person_2),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.menu_book),
            title: const Text('Guide'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const GuideScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.slideshow),
            title: const Text('Onboarding'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const OnboardingView()),
              );
            },
          ),
          // ListTile(
          //   leading: const Icon(Icons.lock),
          //   title: const Text('Email Verification'),
          //   onTap: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => LoginPage()),
          //     );
          //   },
          // ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
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
