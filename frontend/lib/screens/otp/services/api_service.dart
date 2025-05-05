import 'dart:convert';
import 'package:tectags/screens/otp/models/login_response_model.dart';
import 'package:http/http.dart' as http;

class APIService {
  static var client = http.Client();

  static Future<LoginResponseModel> otpLogin(String email) async {
    var url = Uri.https(
      "thesis-prototype-object-counting-uwen.vercel.app", // Use https here
      "api/otp-login",
    );

    var response = await client.post(
      url,
      headers: {"Content-type": "application/json"},
      body: jsonEncode({"email": email}),
    );

    if (response.statusCode == 200) {
      print("Response body: ${response.body}"); // Log the response body
      // Ensure the response is JSON
      if (response.headers['content-type']?.contains('application/json') ??
          false) {
        return loginResponseModel(response.body);
      } else {
        throw Exception(
          "Expected JSON, but received ${response.headers['content-type']}",
        );
      }
    } else {
      throw Exception("Failed to load data: ${response.statusCode}");
    }
  }

  static Future<LoginResponseModel> verifyOTP(
    String email,
    String otp,
    String hash,
  ) async {
    final url = Uri.parse(
      "https://thesis-prototype-object-counting-uwen.vercel.app/api/otp-verify",
    ); 

    final requestBody = {"email": email, "otp": otp, "hash": hash};

    print("🔁 Sending OTP verification request to: $url");
    print("📦 Request body: ${json.encode(requestBody)}");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestBody),
      );

      print("📥 Response status: ${response.statusCode}");
      print("📥 Response body: ${response.body}");

      if (response.statusCode == 200) {
        return LoginResponseModel.fromJson(json.decode(response.body));
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      print("❌ Exception in verifyOTP: $e\n$stackTrace");
      throw Exception("Exception: $e");
    }
  }
}
