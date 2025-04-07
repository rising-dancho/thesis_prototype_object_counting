import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tectags/screens/navigation/navigation_menu.dart';
import 'package:tectags/services/shared_prefs_service.dart';
import 'package:tectags/widgets/custom_scaffold.dart';
import 'package:tectags/widgets/fade_route.dart';
import 'package:tectags/screens/welcome_screen.dart';

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
      duration: Duration(seconds: 20), // SECONDS TO COMPLETE 1 ANIMATION CYCLE
    )..addListener(() {
        setState(() {}); // Rebuild UI every frame for smooth animation
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

  Future<void> checkTokenAndRedirect() async {
    final hasToken = await SharedPrefsService.hasValidToken();

    if (hasToken) {
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
            Expanded(child: SizedBox()),
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 30, 0, 30),
                child: SizedBox(
                  width: 60,
                  child: LinearProgressIndicator(
                    backgroundColor: Color(0xFFF7F7F7), // Light gray background
                    valueColor:
                        // CUSTOMIZE PROGRESS BAR COLOR: 0xFF[hex_color_code]
                        AlwaysStoppedAnimation<Color>(Colors.grey),
                    minHeight: 2, // Make it slightly thicker
                  ),
                ),
              ),
            SizedBox(
              height: 50,
            ),
            // Expanded(child: SizedBox()),
          ],
        ),
      ),
    );
  }
}
