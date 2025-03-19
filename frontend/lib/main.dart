import 'package:flutter/material.dart';
import 'package:techtags/screens/splash_screen.dart';
import 'package:techtags/theme/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TecTags App',
      theme: lightMode,
      home: SplashScreen(),
      // home: NavigationMenu(),
    );
  }
}


