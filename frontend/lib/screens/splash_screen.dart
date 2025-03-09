import 'dart:async';
import 'package:flutter/material.dart';
import 'package:techtags/widgets/custom_scaffold.dart';
import 'package:techtags/widgets/fade_route.dart';
import 'package:techtags/screens/welcome_screen.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(FadeRoute(page: const WelcomeScreen()));
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
          ],
        ),
      ),
    );
  }
}
