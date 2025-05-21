import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tectags/screens/navigation/side_menu.dart';
import 'package:tectags/screens/guide_screen.dart';
import 'package:tectags/screens/dashboard/supplies_screen.dart';
import 'package:tectags/screens/navigation/navigation_menu.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
        automaticallyImplyLeading: false,
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
                      const SizedBox(height: 32),
                      SizedBox(
                        width: 70,
                        height: 70,
                        child: SvgPicture.asset(
                          'assets/icons/tectags_svg_icon.svg',
                          colorFilter: const ColorFilter.mode(
                            Colors.blue,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      const SizedBox(
                          height: 3), // Reduce this value to bring them closer
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
                  label: '',
                  accentColor: Colors.blue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NavigationMenu()),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(height: 12),
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
    );
  }
}
