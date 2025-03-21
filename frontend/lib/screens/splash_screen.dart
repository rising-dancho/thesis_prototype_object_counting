import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techtags/screens/navigation/navigation_menu.dart';
import 'package:techtags/widgets/custom_scaffold.dart';
import 'package:techtags/widgets/fade_route.dart';
import 'package:techtags/screens/welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  bool _isLoading = true;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this, // 'this' refers to the SingleTickerProviderStateMixin
      duration: Duration(seconds: 20), // SECONDS TO COMPLETE ANIMATION 1 CYCLE
    )..addListener(() {
        setState(() {});
      });
    controller.repeat(reverse: true);
    super.initState();

    // DURATION OF THE SPLASH SCREEN
    Timer(const Duration(seconds: 4), () {
      checkTokenAndRedirect(); // Check for token on startup
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // AUTO LOGIN IF TOKEN EXISTS IN THE SHAREDPREFERENCE
  Future<void> checkTokenAndRedirect() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token != null && token.isNotEmpty) {
      // Token exists, redirect to NavigationMenu
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NavigationMenu()),
        );
      }
    } else {
      // No token, redirect to WelcomeScreen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          FadeRoute(page: const WelcomeScreen()),
        );
      }
    }

    setState(() {
      _isLoading = false; // Stop loading
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 140.0),
              child: Image.asset(
                'assets/images/tectags_logo_nobg.png',
                width: 250,
                height: 250,
              ),
            ),
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: SizedBox(
                  width: 200,
                  child: LinearProgressIndicator(
                    backgroundColor: Color(0xFF001C35), // Light gray background
                    valueColor:
                        // CUSTOMIZE PROGRESS BAR COLOR: 0xFF[hex_color_code]
                        AlwaysStoppedAnimation<Color>(Color(0xFF146E9E)),
                    minHeight: 5, // Make it slightly thicker
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
