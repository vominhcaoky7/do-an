import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // 🔥 CHUẨN CHO EMULATOR
  static const String loginUrl = "http://10.0.2.2:5182/api/AuthApi/login";

  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(loginUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    print("LOGIN STATUS: ${response.statusCode}");
    print("LOGIN BODY: ${response.body}");

    if (response.statusCode != 200) return false;

    if (response.body.isEmpty) throw Exception("Empty response from server");

    final data = jsonDecode(response.body);

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("token", data["token"] ?? "");
    await prefs.setString("userId", data["userId"] ?? "");
    await prefs.setString("email", data["email"] ?? "");
    await prefs.setString("fullName", data["fullName"] ?? "Người dùng");

    print(">>> LOGIN SUCCESS");
    print("TOKEN = ${data["token"]}");
    print("USER = ${data["userId"]}");

    return true;
  }
}
