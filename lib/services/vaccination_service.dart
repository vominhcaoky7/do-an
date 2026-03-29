import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vaccination.dart';

class VaccinationService {
  static const String baseUrl =
      'http://10.0.2.2:5182/api/vaccinations'; // Đảm bảo URL chính xác khi chạy trên Android Emulator

  // ================== GET BY PATIENT ==================
  Future<List<Vaccination>> getByPatient(
    String patientCode,
    String token,
  ) async {
    final url = Uri.parse('$baseUrl/patient/$patientCode');

    final res = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token', // Đảm bảo token hợp lệ
        'Accept': 'application/json', // Đảm bảo nhận JSON
      },
    );

    print('GET VACCINATION URL = $url');
    print('GET RESPONSE STATUS = ${res.statusCode}');
    print('GET RESPONSE BODY = ${res.body}');

    if (res.statusCode == 302) {
      // Xử lý trường hợp chuyển hướng (redirect)
      throw Exception(
          'Lỗi: API yêu cầu chuyển hướng. Kiểm tra lại token hoặc URL API.');
    }

    if (res.statusCode != 200) {
      String msg = 'GET_VACCINATION_FAILED';
      try {
        final errorBody = jsonDecode(res.body);
        if (errorBody['message'] != null) {
          msg += ': ${errorBody['message']}';
        } else if (errorBody['title'] != null) {
          msg += ': ${errorBody['title']}';
        }
      } catch (_) {
        msg += ': Không thể phân tích phản hồi lỗi từ API.';
      }
      throw Exception(msg);
    }

    // Giải mã dữ liệu JSON và chuyển nó thành danh sách các đối tượng
    final List data = jsonDecode(res.body);
    return data.map((e) => Vaccination.fromJson(e)).toList();
  }

  // ================== CREATE (ĐẶT LỊCH TIÊM) ==================
  Future<void> createVaccination({
    required String patientCode,
    required String vaccineName,
    required int doseNumber,
    required DateTime nextDueDate,
    required String token,
    String? note,
  }) async {
    final url = Uri.parse('$baseUrl');

    final body = {
      'patientCode': patientCode.trim().toUpperCase(),
      'vaccineName': vaccineName.trim(),
      'doseNumber': doseNumber,
      'nextDueDate': nextDueDate.toIso8601String(),
      'note': note?.trim() ??
          'Đặt lịch từ Flutter', // Ghi chú mặc định nếu không có
    };

    print('CREATE VACCINATION BODY: $body');

    final res = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token', // Đảm bảo token hợp lệ
        'Content-Type': 'application/json',
        'Accept': 'application/json', // Quan trọng để nhận JSON lỗi
      },
      body: jsonEncode(body),
    );

    print('CREATE STATUS = ${res.statusCode}');
    print('CREATE RESPONSE BODY = ${res.body}');

    if (res.statusCode == 302) {
      // Xử lý trường hợp chuyển hướng (redirect)
      throw Exception(
          'Lỗi: API yêu cầu chuyển hướng. Kiểm tra lại token hoặc URL API.');
    }

    if (res.statusCode != 200 && res.statusCode != 201) {
      String msg = 'CREATE_VACCINATION_FAILED';
      try {
        final errorBody = jsonDecode(res.body);
        if (errorBody['message'] != null) {
          msg += ': ${errorBody['message']}';
        } else if (errorBody['title'] != null) {
          msg += ': ${errorBody['title']}';
        }
      } catch (_) {
        msg += ': Không thể phân tích phản hồi lỗi từ API.';
      }
      throw Exception(msg);
    }
  }
}
