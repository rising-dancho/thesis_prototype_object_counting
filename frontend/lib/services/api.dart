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

  // Fetch activity logs per USER ID
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

  // Fetch ALL activity logs
  static Future<List<dynamic>?> fetchAllActivityLogs() async {
    final response = await http.get(Uri.parse('$baseUrl/activity_logs'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      debugPrint("❌ Failed to fetch activity logs: ${response.body}");
      return null;
    }
  }

  static Future<void> saveStockToMongoDB(Map<String, int> stockCounts) async {
    try {
      var stocks = stockCounts.map((key, value) => MapEntry(key, value));

      var response = await http.post(
        Uri.parse("${baseUrl}stocks"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(stocks),
      );

      if (response.statusCode == 200) {
        debugPrint("Stock saved successfully: ${response.body}");
      } else {
        debugPrint("Failed to save stock: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error saving stock: $e");
    }
  }

  static Future<Map<String, int>?> fetchStockFromMongoDB() async {
    try {
      var response = await http.get(Uri.parse("${baseUrl}stocks"));

      debugPrint("Stock API Response: ${response.body}"); // Debug print

      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);

        if (jsonData.isEmpty) {
          debugPrint("Stock response is empty.");
          return null;
        }

        Map<String, int> stockData = {};
        for (var item in jsonData) {
          if (item.containsKey("item") && item.containsKey("expectedCount")) {
            String itemName = item["item"];
            int quantity = item["expectedCount"] is int
                ? item["expectedCount"]
                : int.tryParse(item["expectedCount"].toString()) ?? 0;
            stockData[itemName] = quantity;
          }
        }

        debugPrint("Fetched Stock Data: $stockData");
        return stockData;
      } else {
        debugPrint("Failed to fetch stock: ${response.body}");
        return null;
      }
    } catch (e) {
      debugPrint("Error fetching stock: $e");
      return null;
    }
  }

  static Future<void> deleteStockFromMongoDB(String itemName) async {
    try {
      var response = await http.delete(Uri.parse("${baseUrl}stocks/$itemName"));

      if (response.statusCode == 200) {
        debugPrint("Stock deleted: ${response.body}");
      } else {
        debugPrint(
            "Failed to delete stock: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      debugPrint("Error deleting stock: $e");
    }
  }

  static Future<Map<String, dynamic>?> logStockCurrentCount(
      String userId, String stockItem, int countedAmount) async {
    var url = Uri.parse("${baseUrl}count_objects");

    Map<String, dynamic> requestBody = {
      "userId": userId,
      "stockItem": stockItem,
      "countedAmount": countedAmount,
    };

    debugPrint("🔄 Sending request to: $url");
    debugPrint("📦 Request body: ${jsonEncode(requestBody)}");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      debugPrint("📝 Response Code: ${response.statusCode}");
      debugPrint("📝 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Return the response data
      } else {
        debugPrint("❌ Failed to log object count: ${response.body}");
        return null;
      }
    } catch (error) {
      debugPrint("⚠️ Error logging object count: $error");
      return null;
    }
  }

  // // SAVE DETECTED OBJECTS TO MONGODB
  // static Future<http.Response> saveDetectedObjects(
  //     Map<String, dynamic> detectedCounts) async {
  //   // Accept dynamic values
  //   var response = await http.post(
  //     Uri.parse("${baseUrl}detections"),
  //     headers: {"Content-Type": "application/json"},
  //     body: jsonEncode(detectedCounts),
  //   );

  //   debugPrint("Detections saved: ${response.body}");
  //   return response;
  // }
}
