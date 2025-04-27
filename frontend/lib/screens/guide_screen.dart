import 'package:flutter/material.dart';
import 'package:tectags/screens/navigation/side_menu.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('App Guide'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      endDrawer: const SideMenu(),
      body: Stack(
        children: [
          // Background Image
          SizedBox.expand(
            child: Image.asset(
              'assets/images/tectags_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          // Background dim layer
          Container(
            color: Colors.black.withOpacity(0.6),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Quick Guide for TecTags',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Follow these quick steps to start capturing, editing, and managing your TecTags with ease.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  Expanded(
                    child: ListView(
                      children: const [
                        GuideStep(
                          icon: Icons.camera_alt_outlined,
                          title: 'Capture an Image',
                          description:
                              'Quickly snap a new photo to process TecTags directly.',
                          color: Colors.blueAccent,
                        ),
                        GuideStep(
                          icon: Icons.photo_library_outlined,
                          title: 'Choose from Gallery',
                          description:
                              'Pick an image you already have in your device gallery.',
                          color: Colors.deepPurpleAccent,
                        ),
                        GuideStep(
                          icon: Icons.person_outline,
                          title: 'Profile',
                          description:
                              'Edit your profile, update information, and manage your account settings.',
                          color: Colors.tealAccent,
                        ),
                        GuideStep(
                          icon: Icons.history_outlined,
                          title: 'View Activity Logs',
                          description:
                              'Track your recent actions, edits, and interactions within the app.',
                          color: Colors.orangeAccent,
                        ),
                        GuideStep(
                          icon: Icons.inventory_2_outlined,
                          title: 'Manage Inventory',
                          description:
                              'Easily organize, update, and monitor your TecTags inventory.',
                          color: Colors.pinkAccent,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GuideStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const GuideStep({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      margin: const EdgeInsets.symmetric(vertical: 12),
      elevation: 8,
      shadowColor: color.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: color.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(10),
              child: Icon(icon, size: 30, color: Colors.white),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      height: 1.4,
                    ),
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
