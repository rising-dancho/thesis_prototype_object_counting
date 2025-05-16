import 'package:flutter/material.dart';
import 'package:tectags/screens/about_screen.dart';
import 'package:tectags/screens/guide_screen.dart';
import 'package:tectags/screens/login_screen.dart';
import 'package:tectags/screens/navigation/navigation_menu.dart';
import 'package:tectags/screens/onboarding/onboarding_view.dart';
import 'package:tectags/screens/profile_screen.dart';
import 'package:tectags/screens/role_management/role_management_screen.dart';
import 'package:tectags/services/shared_prefs_service.dart';
import 'package:tectags/screens/dashboard_screen.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  Future<void> logout(BuildContext context) async {
    // Clear all relevant shared preferences first
    await SharedPrefsService.clearUserId();
    await SharedPrefsService.clearToken();
    await SharedPrefsService.clearRole();

    // Ensure we're on the UI thread after async ops, then navigate
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<String?> _getRole() async {
    return await SharedPrefsService.getRole();
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
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => DashboardScreen()),
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
          // Conditionally show Roles tile only for manager
          FutureBuilder<String?>(
            future: _getRole(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(); // or a small loader if you want
              }

              final role = snapshot.data ?? '';

              if (role == 'manager') {
                return ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text('Roles'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UserManagementScreen()),
                    );
                  },
                );
              } else {
                return const SizedBox.shrink(); // Hide for others
              }
            },
          ),
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
