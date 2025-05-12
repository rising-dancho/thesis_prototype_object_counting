import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tectags/services/shared_prefs_service.dart';
import 'package:tectags/utils/label_formatter.dart';
import 'package:tectags/utils/stock_notifier.dart';

class SaveResult {
  final bool isSuccess;
  final String? errorMessage;

  SaveResult({required this.isSuccess, this.errorMessage});
}

class API {
  // static const baseUrl = "http://192.168.1.10:2000/api/"; // FOR TESTING
  static const baseUrl =
      "https://thesis-prototype-object-counting.vercel.app/api/";
  // static const baseUrl = "https://fix-inventory.vercel.app/api/";

  static Future<void> fetchStockAndCheck(String id) async {
    // Fetch token from Shared Preferences
    final token = await SharedPrefsService.getToken();

    // Check if token is valid
    if (token == null || token.isEmpty) {
      print("No valid token found");
      return;
    }

    // Make API call with Authorization header
    final response = await http.get(
      Uri.parse('${API.baseUrl}stocks/$id'), // dynamic stock ID
      headers: {
        'Authorization': 'Bearer $token', // pass token in header
      },
    );

    if (response.statusCode == 200) {
      // Parse response and extract necessary data
      final data = jsonDecode(response.body);
      int stockAmount = data['availableStock'];
      int totalStock = data['totalStock']; // Extract stock name
      String stockName = data['stockName']; // Extract stock name
      StockNotifier.checkStockAndNotify(
          stockAmount, totalStock, stockName); // Call notification method
    } else {
      print("Failed to fetch stock data");
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

  static Future<Map<String, dynamic>?> logStockCurrentCount(
      String userId, String stockItem, int sold) async {
    var url = Uri.parse("${baseUrl}count_objects");

    // ✅ Get token from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      debugPrint("❌ No token found in SharedPreferences");
      return null;
    }

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
        headers: {
          "Content-Type": "application/json",
          "Authorization":
              "Bearer $token", // ✅ AUTHORIZATION FOR PROTECTED ROUTES
        },
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

  static Future<SaveResult> saveStockToMongoDB(
      Map<String, Map<String, int>> stockCounts) async {
    try {
      List<Map<String, dynamic>> formattedStocks =
          stockCounts.entries.map((entry) {
        return {
          "stockName": LabelFormatter.titleCase(entry.key),
          "totalStock": entry.value["totalStock"] ?? 0,
          "sold": entry.value["sold"] ?? 0,
          "availableStock": entry.value["availableStock"] ?? 0,
        };
      }).toList();

      var response = await http.post(
        Uri.parse("${baseUrl}update/sold"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(formattedStocks),
      );

      if (response.statusCode == 200) {
        debugPrint("Stock saved successfully: ${response.body}");
      } else {
        debugPrint("Failed to save stock: ${response.body}");
      }
      return SaveResult(isSuccess: true);
    } catch (e) {
      return SaveResult(isSuccess: false, errorMessage: e.toString());
    }
  }

  static Future<Map<String, dynamic>?> restockStock(
      String stockName, int restockAmount) async {
    final url = Uri.parse('${baseUrl}/api/update/restock');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      debugPrint("❌ No token found in SharedPreferences");
      return null;
    }

    Map<String, dynamic> requestBody = {
      "stockName": stockName,
      "restockAmount": restockAmount,
    };

    debugPrint("🔄 Sending restock request to: $url");
    debugPrint("📦 Request body: ${jsonEncode(requestBody)}");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization":
              "Bearer $token", // ✅ Send token if route is protected
        },
        body: jsonEncode(requestBody),
      );

      debugPrint("📝 Response Code: ${response.statusCode}");
      debugPrint("📝 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint("❌ Failed to restock stock: ${response.body}");
        return null;
      }
    } catch (error) {
      debugPrint("⚠️ Error during restocking: $error");
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

  // CHANGE PASSWORD
  static Future<Map<String, dynamic>?> changePassword(
    String userId,
    String currentPassword,
    String newPassword,
  ) async {
    final url = Uri.parse('${baseUrl}change-password/$userId');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      debugPrint("Change Password Response Code: ${response.statusCode}");
      debugPrint("Change Password Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'error': jsonDecode(response.body)['message']};
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }

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

      var data = jsonDecode(res.body.toString());

      if (res.statusCode == 201) {
        debugPrint("SUCCESS: $data");

        String userId = data['userId'];
        String token = data['token'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', userId);
        await prefs.setString('token', token);

        return data;
      } else {
        String errorMessage = data['message'] ?? "Unknown error";
        return {"error": "Registration failed: $errorMessage"};
      }
    } on SocketException catch (_) {
      return {"error": "No internet connection"};
    } catch (error) {
      debugPrint("⚠️ Exception: $error");
      return {"error": "Network error: ${error.toString()}"};
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
        String token = data['token']; // ⬅️ Saving TOKEN

        // THEN SAVE to SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', userId);
        await prefs.setString('token', token); // ⬅️ Save token too
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

  // UPDATE for user profile
  static Future<Map<String, dynamic>?> updateUserProfile(
    String userId,
    Map<String, dynamic> profileData,
  ) async {
    final url = Uri.parse('${baseUrl}profile/$userId');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(profileData),
      );

      debugPrint("Response Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'error': jsonDecode(response.body)['message']};
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // Method to fetch the user profile
  static Future<Map<String, dynamic>?> fetchUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userId =
        prefs.getString('userId'); // Get the userId from SharedPreferences
    final token =
        prefs.getString('token'); // Get the token from SharedPreferences

    if (userId == null || token == null) {
      debugPrint("❌ User ID or Token not found in SharedPreferences");
      return null;
    }

    final url = Uri.parse(
        "${baseUrl}user/$userId"); // Construct the URL with the userId

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token", // Add token for authentication
        },
      );

      debugPrint("Response Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Return the user data
      } else {
        debugPrint("❌ Failed to fetch user profile: ${response.body}");
        return null;
      }
    } catch (error) {
      debugPrint("⚠️ Error fetching user profile: $error");
      return null;
    }
  }

  // Fetch activity logs per USER ID
  static Future<List<Map<String, dynamic>>?> fetchActivityLogs(
      String userId) async {
    debugPrint(
        "📡 Fetching activity logs from: ${baseUrl}activity_logs/$userId");

    var url = Uri.parse("${baseUrl}activity_logs/$userId");

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token'); // Retrieve token
      final res = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
      );

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
}
