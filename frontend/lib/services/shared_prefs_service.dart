import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  // ----------------- ROLE MANAGEMENT -----------------

  static const String _roleKey = 'role';
  static Future<void> setRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey, role);
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  static Future<void> clearRole() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_roleKey);
  }

  // ----------------- TOKEN MANAGEMENT -----------------
  static Future<bool> hasValidToken() async {
    final prefs = await _getPrefs();
    final token = prefs.getString('auth_token');
    return token != null && token.isNotEmpty;
  }

  static Future<String?> getToken() async {
    final prefs = await _getPrefs();
    return prefs.getString('auth_token');
  }

  static Future<void> saveToken(String token, bool rememberPassword) async {
    final prefs = await _getPrefs();
    if (rememberPassword) {
      await prefs.setString('auth_token', token);
    } else {
      await prefs.remove('auth_token');
    }
  }

  static Future<void> saveTokenWithoutCheck(String token) async {
    try {
      final prefs = await _getPrefs();
      await prefs.setString('auth_token', token);
      debugPrint("Token saved successfully: $token");
    } catch (e) {
      debugPrint("Error saving token: $e");
    }
  }

  static Future<void> clearToken() async {
    final prefs = await _getPrefs();
    await prefs.remove('auth_token');
  }

  // ----------------- USER ID MANAGEMENT -----------------
  static Future<String?> getUserId() async {
    final prefs = await _getPrefs();
    return prefs.getString('userId');
  }

  static Future<void> saveUserId(String userId) async {
    final prefs = await _getPrefs();
    await prefs.setString('userId', userId);
  }

  static Future<void> clearUserId() async {
    final prefs = await _getPrefs();
    await prefs.remove('userId');
  }

  // ----------------- REMEMBER PASSWORD MANAGEMENT -----------------
  static Future<void> saveRememberPassword(bool rememberPassword) async {
    final prefs = await _getPrefs();
    await prefs.setBool('remember_password', rememberPassword);
  }

  static Future<bool> loadRememberPassword() async {
    final prefs = await _getPrefs();
    return prefs.getBool('remember_password') ?? true; // Default to true
  }

  // ----------------- ONBOARDING MANAGEMENT -----------------
  static Future<bool> hasSeenOnboarding() async {
    final prefs = await _getPrefs();
    return prefs.getBool('hasSeenOnboarding') ?? false;
  }

  static Future<void> setHasSeenOnboarding(bool value) async {
    final prefs = await _getPrefs();
    await prefs.setBool('hasSeenOnboarding', value);
  }
}
