import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class API {
  static const baseUrl = "http://192.168.1.10:2000/api/";

  // POST REQUEST: REGISTRATION
  static registerUser(Map<String, dynamic> userData) async {
    debugPrint(jsonEncode(userData)); // Debugging

    var url = Uri.parse("${baseUrl}register");

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
    } catch (e) {
      debugPrint(e.toString());
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
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // // GET REQUEST
  // static getProduct() async {
  //   List<Product> products = [];

  //   var url = Uri.parse("${baseUrl}get_product");

  //   try {
  //     final res = await http.get(url);

  //     if (res.statusCode == 200) {
  //       var data = jsonDecode(res.body);
  //       // debugPrint(data);

  //       for (var value in (data as List)) {
  //         products.add(Product(
  //           id: value["_id"], // MongoDB returns "_id" as a String
  //           name: value["pname"],
  //           price: value["pprice"],
  //           desc: value["pdesc"],
  //         ));
  //       }

  //       return products;
  //     } else {
  //       return [];
  //     }
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   }
  // }

  // UPDATE REQUEST
  // static updateProduct(id, body) async {
  //   var url = Uri.parse("${baseUrl}update_product/$id");

  //   try {
  //     final res = await http.put(
  //       url,
  //       headers: {"Content-Type": "application/json"},
  //       body: jsonEncode(body),
  //     );

  //     if (res.statusCode == 200) {
  //       debugPrint(jsonDecode(res.body).toString());
  //     } else {
  //       debugPrint("Failed to update data");
  //     }
  //   } catch (e) {
  //     debugPrint("Error: $e");
  //   }
  // }

  // // DELETE REQUEST
  // static deleteProduct(id) async {
  //   var url = Uri.parse("${baseUrl}delete_product/$id");

  //   final res = await http.delete(url);

  //   if (res.statusCode == 204) {
  //     debugPrint(jsonDecode(res.body));
  //   } else {
  //     debugPrint("Failed to delete");
  //   }
  // }
}
