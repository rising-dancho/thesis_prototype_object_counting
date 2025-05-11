import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tectags/screens/navigation/navigation_menu.dart';
import 'package:tectags/screens/onboarding/onboarding_view.dart';
import 'package:tectags/services/api.dart';
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

    // Fetch stock and check levels when the splash screen is loaded
    _initializeApp();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      final token = await SharedPrefsService.getToken();
      if (token == null || token.isEmpty) {
        debugPrint("Token not found.");
        return;
      }

      final response = await http.get(
        Uri.parse('${API.baseUrl}stocks'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> stocks = jsonDecode(response.body);

        // Call fetchStockAndCheck for each stock using _id
        for (var stock in stocks) {
          final id = stock['_id'];
          if (id != null) {
            await API.fetchStockAndCheck(id);
          }
        }
      } else {
        debugPrint("Failed to fetch stock list: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint('Error checking stock levels: $e');
    }

    await Future.delayed(const Duration(seconds: 4));
    await checkTokenAndRedirect();
  }

  Future<void> checkTokenAndRedirect() async {
    final hasToken = await SharedPrefsService.hasValidToken();
    final hasSeenOnboarding =
        await SharedPrefsService.hasSeenOnboarding(); // <- check onboarding

    if (!hasSeenOnboarding) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          FadeRoute(page: const OnboardingView()),
        );
      }
    } else if (hasToken) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NavigationMenu()),
        );
      }
    } else {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          FadeRoute(page: const WelcomeScreen()),
        );
      }
    }

    setState(() {
      _isLoading = false;
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
