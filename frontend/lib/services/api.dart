import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class API {
  // static const baseUrl = "http://192.168.1.10:2000/api/"; // FOR TESTING
  static const baseUrl = "https://thesis-prototype-object-counting.vercel.app/api/";

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
        debugPrint("fetchActivityLogs Full API RESPONSE!!: $data");
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

  // Fetch activity details by activityId
  static Future<Map<String, dynamic>?> fetchActivityById(
      String activityId) async {
    debugPrint(
        "📡 Fetching activity details from: ${baseUrl}activity/$activityId");

    var url = Uri.parse("${baseUrl}activity/$activityId");

    try {
      final res = await http.get(url);

      debugPrint("Response Code: ${res.statusCode}");
      debugPrint("Response Body: ${res.body}");

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        debugPrint("❌ Failed to fetch activity details: ${res.body}");
        return null;
      }
    } catch (error) {
      debugPrint("⚠️ Error fetching activity details: $error");
      return null;
    }
  }

  static Future<Map<String, dynamic>?> logStockCurrentCount(
    String userId, String stockItem, int sold) async {
    var url = Uri.parse("${baseUrl}count_objects");

    Map<String, dynamic> requestBody = {
      "userId": userId,
      "stockName": stockItem,
      "sold": sold,
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
        return jsonDecode(response.body);
      } else {
        debugPrint("❌ Failed to log object count: ${response.body}");
        return null;
      }
    } catch (error, stacktrace) {
      debugPrint("⚠️ Error logging object count: $error");
      debugPrint(stacktrace.toString());
      return null;
    }
  }

  static Future<void> saveStockToMongoDB(
      Map<String, Map<String, int>> stockCounts) async {
    try {
      List<Map<String, dynamic>> formattedStocks =
          stockCounts.entries.map((entry) {
        return {
          "stockName": entry.key,
          "totalStock": entry.value["totalStock"] ?? 0, // ✅ Fixed key
          "sold": entry.value["sold"] ?? 0,
          "availableStock": entry.value["availableStock"] ?? 0, // ✅ Added
        };
      }).toList();

      var response = await http.post(
        Uri.parse("${baseUrl}stocks"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(formattedStocks),
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

  static Future<Map<String, Map<String, int>>?> fetchStockFromMongoDB() async {
    try {
      var response = await http.get(Uri.parse("${baseUrl}stocks"));

      debugPrint("Stock API Response: ${response.body}");

      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);

        Map<String, Map<String, int>> stockData = {};
        for (var item in jsonData) {
          if (item.containsKey("stockName") &&
              item.containsKey("availableStock") &&
              item.containsKey("totalStock")) {
            // ✅ No longer requiring "sold"

            String itemName = item["stockName"];
            int availableStock = item["availableStock"] ?? 0;
            int totalStock = item["totalStock"] ?? 0;
            int sold = item.containsKey("sold")
                ? item["sold"] ?? 0
                : 0; // ✅ Handle missing "sold"

            stockData[itemName] = {
              "availableStock": availableStock,
              "totalStock": totalStock,
              "sold": sold, // ✅ Ensures "sold" exists
            };
          }
        }

        debugPrint("Fetched Stock Data with Sold: $stockData");
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
      var encodedName =
          Uri.encodeComponent(itemName); // ✅ Prevent issues with spaces
      var response =
          await http.delete(Uri.parse("${baseUrl}stocks/$encodedName"));

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
}
