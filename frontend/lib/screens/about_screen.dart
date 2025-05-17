import 'package:flutter/material.dart';
import 'package:tectags/screens/navigation/side_menu.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  final List<Map<String, String>> developers = const [
    {
      "name": "Jose A. Perez Jr.",
      "role": "Development Lead and Features Implementation",
      "email": "josealejoperezjr@gmail.com"
    },
    {
      "name": "Joshua Martin A. Peralta",
      "role": "UI Conceptualization and Implementation",
      "email": "joshuamartinperalta96@gmail.com"
    },
    {
      "name": "Arvin F. Eugenio",
      "role": "Documentation and Logo",
      "email": "arvin.4298@gmail.com"
    },
    {
      "name": "Armand Sebastian E. Bueno",
      "role": "Dataset Annotation and Model Training",
      "email": "armandsebastian12@gmail.com"
    }
  ];

  final List<Map<String, String>> advisers = const [
    {
      "name": "Dr. Risty M. Acerado",
      "role": "Capstone Project Adviser",
      "affiliation": "Technological Institute of the Philippines"
    },
  ];

  final List<Map<String, String>> panels = const [
    {
      "name": "Dr. Gerald T. Cayabyab",
      "role": "Dean and Program Chair",
      "affiliation": "Technological Institute of the Philippines"
    },
    {
      "name": "Ms. Roxanne Pagaduan",
      "role": "Defense Panel",
      "affiliation": "Technological Institute of the Philippines"
    },
    {
      "name": "Ms. Arceli Salo",
      "role": "Defense Panel",
      "affiliation": "Technological Institute of the Philippines"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('About the App'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      endDrawer: const SideMenu(),
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              "assets/images/tectags_bg.png",
              fit: BoxFit.cover,
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.6),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/tectags_logo_nobg.png',
                    height: 100,
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: const Text(
                      "TecTags is an innovative application designed to enhance inventory management and operational efficiency in hardware stores through AI-powered object detection.\n\nBelow, meet the team behind this project.",
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.white,
                        fontFamily: 'Roboto',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Center(
                  child: Text(
                    "Meet Our Adviser",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ...advisers.map((adviser) {
                  return Card(
                    elevation: 6,
                    color: Colors.white.withOpacity(0.9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: const Color(0xFF0D47A1),
                            child: Text(
                              adviser['name']![0],
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  adviser['name']!,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  adviser['role']!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.school,
                                        size: 16, color: Colors.black45),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        adviser['affiliation']!,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black45,
                                          fontStyle: FontStyle.italic,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 30),
                const Center(
                  child: Text(
                    "Meet Our Developers",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ...developers.map((developer) {
                  return Card(
                    elevation: 6,
                    color: Colors.white.withOpacity(0.9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: const Color(0xFF0D47A1),
                            child: Text(
                              developer['name']![0],
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  developer['name']!,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  developer['role']!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.email,
                                        size: 16, color: Colors.black45),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        developer['email']!,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black45,
                                          fontStyle: FontStyle.italic,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    "Defense Panel Members",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ...panels.map((panel) {
                  return Card(
                    elevation: 6,
                    color: Colors.white.withOpacity(0.9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: const Color(0xFF0D47A1),
                            child: Text(
                              panel['name']![0],
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  panel['name']!,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  panel['role']!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.email,
                                        size: 16, color: Colors.black45),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        panel['affiliation']!,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black45,
                                          fontStyle: FontStyle.italic,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
