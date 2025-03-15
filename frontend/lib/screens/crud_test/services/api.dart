import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class API {
  static const baseUrl = "http://192.168.1.10/api/";

  static addproduct(Map pdata) async {
    debugPrint(pdata.toString());
    var url = Uri.parse("${baseUrl}app_product");

    try {
      final res = await http.post(url, body: pdata);

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body.toString());
        debugPrint(data);
      } else {
        debugPrint("Failed to get response");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
