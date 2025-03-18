import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class API {
  static const baseUrl = "http://192.168.1.10:2000/api/";

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
        // Use 200 for successful login
        var data = jsonDecode(res.body.toString());
        debugPrint("Success: $data");
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
}
