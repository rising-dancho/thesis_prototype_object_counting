// snackbar_utils.dart
import 'package:flutter/material.dart';
import 'package:tectags/main.dart'; // to access scaffoldMessengerKey

void showGlobalSnackbar(String message) {
  scaffoldMessengerKey.currentState?.showSnackBar(
    SnackBar(content: Text(message)),
  );
}
