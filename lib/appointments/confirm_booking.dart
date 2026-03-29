// lib/appointments/confirm_booking.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';

import 'appointment_history_model.dart';

class ConfirmBookingPage extends StatelessWidget {
  final String fullName;
  final String phone;
  final String specialty;
  final String doctor;
  final int doctorId;
  final int departmentId;
  final int slotId;
  final DateTime date;
  final String slot;
  final String patientCode;
  final String symptom;

  final int startHour;
  final int startMinute;

  ConfirmBookingPage({
    super.key,
    required this.fullName,
    required this.phone,
    required this.specialty,
    required this.doctor,
    required this.doctorId,
    required this.departmentId,
    required this.slotId,
    required this.date,
    required this.slot,
    required this.patientCode,
    required this.startHour,
    required this.startMinute,
    required this.symptom,
  });

  final Map<String, int> specialtyPrices = {
    "Nội tổng quát": 120000,
    "Nhi khoa": 150000,
    "Tim mạch": 180000,
    "Da liễu": 130000,
    "Tai Mũi Họng": 140000,
    "Răng Hàm Mặt": 160000,
    "Chấn thương chỉnh hình": 200000,
  };

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd/MM/yyyy').format(date);
    int defaultPrice = specialtyPrices[specialty] ?? 100000;

    final amountCtrl = TextEditingController(text: defaultPrice.toString());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Xác nhận đặt lịch"),
        foregroundColor: Colors.blue,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Thông tin đặt khám",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildRow("Họ tên", fullName),
            _buildRow("SĐT", phone),
            _buildRow("Mã BN", patientCode),
            _buildRow("Chuyên khoa", specialty),
            _buildRow("Bác sĩ", doctor),
            _buildRow("Ngày khám", dateStr),
            _buildRow("Khung giờ", slot),
            _buildRow("Triệu chứng", symptom.isEmpty ? "Không có" : symptom),
            _buildRow("Giá khám dự kiến", "${defaultPrice}đ"),
            const SizedBox(height: 20),
            const Text(
              "Mã QR thanh toán",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Center(
              child: QrImageView(
                data:
                    "PAYMENT:$fullName|BS:$doctor|DATE:$dateStr|AMOUNT:${amountCtrl.text}",
                version: QrVersions.auto,
                size: 180,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Nhập số tiền thanh toán",
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: const Text("Thanh toán & Hoàn tất đặt lịch"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  int? money = int.tryParse(amountCtrl.text.trim());
                  if (money == null || money <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Vui lòng nhập số tiền hợp lệ!"),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  _submitBooking(context, money);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _submitBooking(BuildContext context, int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("userId") ?? "";

    if (userId.isEmpty) {
      _showError(context, "Bạn chưa đăng nhập!");
      return;
    }

    final appointmentDate =
        DateTime(date.year, date.month, date.day, startHour, startMinute);

    final body = {
      "userId": userId,
      "fullName": fullName,
      "phone": phone,
      "doctorId": doctorId,
      "departmentId": departmentId,
      "slotId": slotId,
      "appointmentDate": appointmentDate.toIso8601String(),
      "symptom": symptom,
      "paymentAmount": amount,
    };

    final url = Uri.parse("http://10.0.2.2:5182/api/AppointmentApi/create");

    http.Response res;

    try {
      res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
    } catch (e) {
      _showError(context, "Không kết nối được Server!");
      return;
    }

    if (res.statusCode != 200 && res.statusCode != 201) {
      _showError(context, "Đặt lịch thất bại: ${res.body}");
      return;
    }

    // Lưu local
    final newAppt = AppointmentHistory(
      id: DateTime.now().millisecondsSinceEpoch,
      patientName: fullName,
      doctorName: doctor,
      specialty: specialty,
      clinicName: "Trạm Xá Di Động HUTECH",
      date: appointmentDate,
      slot: slot,
      status: "Đã thanh toán",
    );

    final history = prefs.getStringList("local_appointment_history") ?? [];
    history.insert(0, jsonEncode(newAppt.toJson()));
    await prefs.setStringList("local_appointment_history", history);

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Đặt lịch thành công!"),
        content: const Text("Bạn đã thanh toán và đặt lịch thành công."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.popUntil(context, (r) => r.isFirst);
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }
}
