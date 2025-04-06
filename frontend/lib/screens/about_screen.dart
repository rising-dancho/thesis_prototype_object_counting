import 'package:flutter/material.dart';
import 'package:tectags/screens/tensorflow/tensorflow_lite.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  final List<Map<String, String>> developers = const [
    {
      "name": "Jose A. Perez",
      "role": "Student/Information Technology"
    },
    {
      "name": "Joshua Martin A. Peralta",
      "role": "Student/Information Technology"
    },
    {
      "name": "Arvin F. Eugenio",
      "role": "Student/Information Technology"
    },
    {
      "name": "Armand Sebastian E. Bueno",
      "role": "Student/Information Technology"
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About The App'),
        backgroundColor: const Color.fromARGB(255, 5, 45, 90),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const TensorflowLite()),
            );
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/tectags_bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const SizedBox(height: 20),
            const Center(
              child: Text(
                "Welcome to TecTags!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Image.asset(
                'assets/images/tectags_icon.png',
                height: 100,
              ),
            ),
            const SizedBox(height: 10),
            Card(
              color: Colors.transparent,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blueAccent, Colors.lightBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "TecTags is an innovative application designed to enhance inventory management and operational efficiency in hardware stores through AI-powered object detection. Below, meet the talented developers behind this project.",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Roboto',
                    color: const Color.fromARGB(220, 255, 255, 255),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                "Meet Our Developers",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Developer Cards with Dividers
            ...developers.map((developer) {
              int index = developers.indexOf(developer);
              return Column(
                children: [
                  Card(
                    color: Colors.white.withOpacity(0.85),
                    elevation: 6,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: const Color.fromARGB(255, 5, 45, 90),
                            child: Text(
                              developer["name"]![0],
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  developer["name"]!,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  developer["role"]!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (index != developers.length - 1)
                    const Divider(
                      color: Colors.grey,
                      height: 1,
                      thickness: 1,
                    ),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
