import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tectags/screens/splash_screen.dart';
import 'package:tectags/services/notif_service.dart';
import 'package:tectags/services/stock_check_service.dart';
import 'package:tectags/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // initialize notifications
  await NotifService().initNotification(); // NOTIFICATIONS

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  Timer? _stockTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    startPeriodicStockCheck(); // Optional timer-based check
  }

  void startPeriodicStockCheck() {
    _stockTimer?.cancel();
    _stockTimer = Timer.periodic(Duration(minutes: (60*6)), (_) {
      StockCheckService.checkStocks();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stockTimer?.cancel();
    super.dispose();
  }

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
