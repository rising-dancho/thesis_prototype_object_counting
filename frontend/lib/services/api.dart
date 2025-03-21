import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class API {
  // static const baseUrl = "http://192.168.1.10:2000/api/"; // FOR TESTING
  static const baseUrl =
      "https://thesis-prototype-object-counting.vercel.app/api/";

  // POST REQUEST: REGISTRATION
  static Future<Map<String, dynamic>?> registerUser(
      Map<String, dynamic> userData) async {
    debugPrint("Sending request to: ${baseUrl}register");
    debugPrint("Request body: ${jsonEncode(userData)}");

    var url = Uri.parse("${baseUrl}register");

    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(userData),
      );

      debugPrint("Response Code: ${res.statusCode}");
      debugPrint("Response Body: ${res.body}");

      if (res.statusCode == 201) {
        var data = jsonDecode(res.body.toString());
        debugPrint("Success: $data");
        return data; // Return the response data
      } else {
        debugPrint("Failed: ${res.body}");
        return null; // Return null if the request fails
      }
    } catch (error) {
      debugPrint("Error: $error");
      return null; // Return null if an exception occurs
    }
  }

  // POST REQUEST: LOGIN
  static Future<Map<String, dynamic>?> loginUser(
      Map<String, dynamic> userData) async {
    debugPrint("🚀 Sending request to: ${baseUrl}login");
    debugPrint("📝 Request body: ${jsonEncode(userData)}");

    var url = Uri.parse("${baseUrl}login");

    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(userData),
      );

      debugPrint("Response Code: ${res.statusCode}");
      debugPrint("Response Body: ${res.body}");

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body.toString());
        debugPrint("SUCCESS: $data");
        // Save userId to local storage (SharedPreferences)
        // EXTRACT TOKEN AND USER ID
        String userId = data['userId'];

        // THEN SAVE to SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', userId);
        return data; // Return the response data
      } else {
        debugPrint("Failed: ${res.body}");
        // CONVERT THE RESPONSE FROM SERVER FIRST FROM JSON to STRING
        var errorData = jsonDecode(res.body); // Convert response body to JSON
        String errorMessage = errorData['message'];
        return {
          "error": "Login failed: $errorMessage"
        }; // Return null if the request fails
      }
    } catch (error) {
      debugPrint("⚠️ Exception: $error");
      return {
        "error": "Network error: $error"
      }; // Return null if an exception occurs
    }
  }

  // Fetch activity logs
  static Future<List<Map<String, dynamic>>?> fetchActivityLogs(
      String userId) async {
    debugPrint(
        "📡 Fetching activity logs from: ${baseUrl}activity_logs/$userId");

    var url = Uri.parse("${baseUrl}activity_logs/$userId");

    try {
      final res = await http.get(url);

      debugPrint("Response Code: ${res.statusCode}");
      debugPrint("Response Body: ${res.body}");

      if (res.statusCode == 200) {
        List<dynamic> data = jsonDecode(res.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        debugPrint("❌ Failed to fetch logs: ${res.body}");
        return null;
      }
    } catch (error) {
      debugPrint("⚠️ Error fetching logs: $error");
      return null;
    }
  }

  // Fetch activity logs
  static Future<List<dynamic>?> fetchAllActivityLogs() async {
    final response = await http.get(Uri.parse('$baseUrl/activity_logs'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      debugPrint("❌ Failed to fetch activity logs: ${response.body}");
      return null;
    }
  }
}
