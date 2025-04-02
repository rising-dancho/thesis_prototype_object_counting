import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tectags/screens/tensorflow/tensorflow_lite.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  // Developer List
  final List<Map<String, String>> developers = const [
    {
      "name": "Jose A. Perez",
      "role": "Student/Lead Programmer",
      "email": "johndoe@example.com"
    },
    {
      "name": "Joshua Martin A. Peralta",
      "role": "Student/",
      "email": "janesmith@example.com"
    },
    {
      "name": "Arvin F. Eugenio",
      "role": "Student/",
      "email": "alexbrown@example.com"
    },
    {
      "name": "Armand Sebastian E. Bueno",
      "role": "Student/",
      "email": "emilywhite@example.com"
    }
  ];

  // Function to launch email
  void _launchEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      debugPrint("Could not launch email client.");
    }
  }

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
            // Navigate to the TensorflowLite screen
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
            image: AssetImage("assets/images/tectags_bg.png"), // Background image
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
            const Center(
              child: Text(
                "TecTags is an innovative application designed to enhance your experience with AI-powered object recognition. Our mission is to provide a seamless and interactive way to explore technology. Below, you can meet the talented developers behind this project.",
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Roboto',
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
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

            // List of developers
            ...developers.map((developer) {
              return Card(
                color: Colors.white.withOpacity(0.9),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  title: Text(
                    developer["name"]!,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    developer["role"]!,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.email, color: Colors.blue),
                    onPressed: () => _launchEmail(developer["email"]!),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}