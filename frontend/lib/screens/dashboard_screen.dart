import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tectags/screens/charts/stock_dashboard.dart';
import 'package:tectags/screens/navigation/side_menu.dart';
import 'package:tectags/screens/guide_screen.dart';
import 'package:tectags/screens/profile_screen.dart';
import 'package:tectags/screens/role_management/role_management_screen.dart';
import 'package:tectags/screens/dashboard/supplies_screen.dart';
import 'package:tectags/screens/navigation/navigation_menu.dart';
import 'package:tectags/services/shared_prefs_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Future<String?> _getRole() async {
    return await SharedPrefsService.getRole();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title:
            // const Text('Home'),
            const Text(
          "Home",
          style: TextStyle(
            fontFamily: 'Rajdhani',
            fontSize: 22,
            letterSpacing: 1.2,
            fontWeight: FontWeight.bold,
            // color: Color.fromARGB(255, 27, 211, 224),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: true,
      ),
      endDrawer: const SideMenu(),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/tectags_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Background dim layer
          Container(
            color: Colors.black.withOpacity(0.6),
          ),
          // Foreground content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                DashboardCard(
                  icon: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 63,
                        height: 63,
                        child: SvgPicture.asset(
                          'assets/icons/tectags_svg_icon.svg',
                          colorFilter: const ColorFilter.mode(
                            Colors.blue,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      // const SizedBox(height: 6),
                      const Text(
                        'TECTAGS',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black87,
                              offset: Offset(1, 1),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  label:
                      '', // Set this to '' to skip the second label rendering
                  accentColor: Colors.blue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NavigationMenu()),
                    );
                  },
                ),
                DashboardCard(
                  icon:
                      const Icon(Icons.inventory, size: 48, color: Colors.teal),
                  label: 'SUPPLIES',
                  accentColor: Colors.teal,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SuppliesScreen()),
                    );
                  },
                ),
                DashboardCard(
                  icon: const Icon(Icons.library_books,
                      size: 48, color: Colors.purple),
                  label: 'GUIDE',
                  accentColor: Colors.purple,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GuideScreen()),
                    );
                  },
                ),
                DashboardCard(
                  icon: const Icon(Icons.account_circle,
                      size: 48, color: Colors.indigo),
                  label: 'PROFILE',
                  accentColor: Colors.indigo,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfileScreen()),
                    );
                  },
                ),
                FutureBuilder<String?>(
                  future: _getRole(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(); // or a small loader if you want
                    }

                    final role = snapshot.data ?? '';

                    if (role == 'manager') {
                      return DashboardCard(
                        icon: const Icon(Icons.bar_chart,
                            size: 48, color: Colors.deepOrange),
                        label: 'CHARTS',
                        accentColor: Colors.deepOrange,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => StockDashboard()),
                          );
                        },
                      );
                    } else {
                      return const SizedBox.shrink(); // Hide for others
                    }
                  },
                ),
                FutureBuilder<String?>(
                  future: _getRole(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(); // or a small loader if you want
                    }

                    final role = snapshot.data ?? '';

                    if (role == 'manager') {
                      return DashboardCard(
                        icon: const Icon(Icons.group,
                            size: 48, color: Colors.green),
                        label: 'ROLES',
                        accentColor: Colors.green,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback onTap;
  final Color accentColor;

  const DashboardCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: accentColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: accentColor.withOpacity(0.4), blurRadius: 6),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              if (label.isNotEmpty) const SizedBox(height: 12),
              if (label.isNotEmpty)
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black87,
                        offset: Offset(1, 1),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
