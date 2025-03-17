import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class API {
  static const baseUrl = "http://192.168.1.10:2000/api/";

  // POST REQUEST: REGISTRATION
  static registerUser(Map<String, dynamic> userData) async {
    debugPrint(jsonEncode(userData));

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
      } else {
        debugPrint("Failed: ${res.body}");
      }
    } catch (error) {
      debugPrint("Error: $error");
    }
  }

  // POST REQUEST: LOGIN
  static loginUser(Map<String, dynamic> userData) async {
    debugPrint(jsonEncode(userData)); // Debugging

    var url = Uri.parse("${baseUrl}login");

    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(userData),
      );

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body.toString());
        debugPrint(data.toString());
      } else {
        debugPrint("Failed to get response");
      }
    } catch (error) {
      debugPrint("Error: $error");
    }
  }
}
