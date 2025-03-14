import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Api {
  static const baseUrl = "";

  static addproduct(Map pdata) async {
    try {
      final res = await http.post(Uri.parse("uri"), body: pdata);

      if (res.statusCode == 200) {
      } else {}
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
