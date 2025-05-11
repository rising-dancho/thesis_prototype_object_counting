import 'package:flutter/material.dart';
import 'package:tectags/screens/splash_screen.dart';
import 'package:tectags/services/notif_service.dart';
import 'package:tectags/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // initialize notifications
  await NotifService().initNotification(); // NOTIFICATIONS

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
