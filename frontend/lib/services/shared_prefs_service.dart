import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  static Future<bool> hasValidToken() async {
    final prefs = await _getPrefs();
    final token = prefs.getString('auth_token');
    return token != null && token.isNotEmpty;
  }

  static Future<String?> getUserId() async {
    final prefs = await _getPrefs();
    return prefs.getString('userId'); // Returns null if not found
  }

  static Future<void> saveUserId(String userId) async {
    final prefs = await _getPrefs();
    await prefs.setString('userId', userId);
  }

  static Future<void> clearUserId() async {
    final prefs = await _getPrefs();
    await prefs.remove('userId');
  }

  static Future<void> clearToken() async {
    final prefs = await _getPrefs();
    await prefs.remove('auth_token'); // Properly removes the token
  }

  // Save the token conditionally (for login)
  static Future<void> saveToken(String token, bool rememberPassword) async {
    final prefs = await _getPrefs();
    if (rememberPassword) {
      await prefs.setString('auth_token', token);
    } else {
      await prefs.remove('auth_token');
    }
  }

  //Save the token unconditionally (for signup)
  // NEXT TIME THEY GO IN THEY ARE AUTO LOGGED IN UNLESS THEY LOGOUT
  static Future<void> saveTokenWithoutCheck(String token) async {
    try {
      final prefs = await _getPrefs();
      await prefs.setString('auth_token', token);
      debugPrint("Token saved successfully: $token"); // Debug log
    } catch (e) {
      debugPrint("Error saving token: $e"); // Debug log
    }
  }

  static Future<String?> getToken() async {
    final prefs = await _getPrefs();
    return prefs.getString('auth_token');
  }

  static Future<void> saveRememberPassword(bool rememberPassword) async {
    final prefs = await _getPrefs();
    await prefs.setBool('remember_password', rememberPassword);
  }

  static Future<bool> loadRememberPassword() async {
    final prefs = await _getPrefs();
    return prefs.getBool('remember_password') ?? true; // Default to true
  }
}
