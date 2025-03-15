import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class API {
  static const baseUrl = "http://192.168.1.10:2000/api/";

  static addproduct(Map<String, dynamic> pdata) async {
    print(jsonEncode(pdata)); // Debugging

    var url = Uri.parse("${baseUrl}add_product");

    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(pdata),
      );

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body.toString());
        debugPrint(data.toString());
      } else {
        debugPrint("Failed to get response");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
