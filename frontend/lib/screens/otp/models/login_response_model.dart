import 'dart:convert';

LoginResponseModel loginResponseModel(String str) =>
    LoginResponseModel.fromJson(json.decode(str));

class LoginResponseModel {
  LoginResponseModel({required this.message, this.data});
  late final String message;
  late final String? data;

  LoginResponseModel.fromJson(Map<String, dynamic> json) {
    message = json["message"] ?? "No message";
    data = json["data"];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data["message"] = message;
    _data["data"] = data;

    return _data;
  }
}
