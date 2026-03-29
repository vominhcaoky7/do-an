import 'dart:convert';
import 'package:http/http.dart' as http;

class PatientProfileService {
  final String baseUrl = "http://10.0.2.2:5182/api/PatientProfileApi";

  // GET
  Future<Map<String, dynamic>?> getProfile(String userId) async {
    final url = Uri.parse("$baseUrl/$userId");
    final res = await http.get(url);

    print("GET STATUS = ${res.statusCode}");
    print("GET BODY = ${res.body}");

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    return null;
  }

  // POST (save)
  Future<bool> saveProfile(Map<String, dynamic> data) async {
    final url = Uri.parse("$baseUrl/save");

    print("POST TO = $url");
    print("SEND BODY = ${jsonEncode(data)}");

    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    print("STATUS = ${res.statusCode}");
    print("RESPONSE = ${res.body}");

    return res.statusCode == 200;
  }
}
