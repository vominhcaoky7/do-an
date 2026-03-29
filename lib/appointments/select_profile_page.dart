// lib/appointments/select_profile_page.dart
// BẢN FULL FIX – CÓ TRIỆU CHỨNG + KHÔNG LỖI NULL

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'select_specialty.dart';
import 'select_doctor.dart';
import 'select_date.dart';
import 'select_slot.dart';
import 'select_symptom_page.dart';
import 'confirm_booking.dart';
import '../utils/mask_phone.dart';

class SelectProfilePage extends StatefulWidget {
  const SelectProfilePage({super.key});

  @override
  State<SelectProfilePage> createState() => _SelectProfilePageState();
}

class _SelectProfilePageState extends State<SelectProfilePage> {
  List<Map<String, dynamic>> profiles = [];

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  // ====================== SANITIZE PROFILE – CHỐNG LỖI ======================
  Map<String, dynamic> sanitizeProfile(Map<String, dynamic> p) {
    final first = (p["firstName"] ?? "").toString().trim();
    final last = (p["lastName"] ?? "").toString().trim();
    final full = (p["fullName"] ?? "").toString().trim();

    String finalFullName = full;
    if (finalFullName.isEmpty) {
      finalFullName = "$last $first".trim();
      if (finalFullName.isEmpty) {
        finalFullName = "Người dùng";
      }
    }

    final phone = (p["phone"] ?? "").toString().trim();
    final finalPhone = phone.isEmpty ? "0000000000" : phone;

    return {
      "patientCode": p["patientCode"] ?? "BN000000",
      "fullName": finalFullName,
      "lastName": last,
      "firstName": first,
      "phone": finalPhone,
      "email": p["email"] ?? "",
      "cccd": p["cccd"] ?? "",
      "passport": p["passport"] ?? "",
      "personalId": p["personalId"] ?? "",
      "gender": p["gender"] ?? "",
      "birth": p["birth"] ?? DateTime.now().toIso8601String(),
      "nationality": p["nationality"] ?? "",
      "ethnicity": p["ethnicity"] ?? "",
      "province": p["province"] ?? "",
      "district": p["district"] ?? "",
      "address": p["address"] ?? "",
      "job": p["job"] ?? "",
    };
  }

  // ====================== LOAD PROFILES ======================
  Future<void> _loadProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString("profiles");

    if (raw != null) {
      final list = jsonDecode(raw);
      profiles = List<Map<String, dynamic>>.from(
        list.map((e) => sanitizeProfile(Map<String, dynamic>.from(e))),
      );

      // lưu lại phiên bản sạch
      await prefs.setString("profiles", jsonEncode(profiles));
    }

    if (mounted) setState(() {});
  }

  Future<void> _createNewProfile() async {
    final result = await Navigator.pushNamed(context, "/create_profile");
    if (result == true) await _loadProfiles();
  }

  // ====================== BOOKING FLOW ======================
  void _selectProfile(Map<String, dynamic> p) async {
    p = sanitizeProfile(p);

    // 1. chọn chuyên khoa
    final specialtyResult = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SelectSpecialtyPage()),
    );
    if (specialtyResult == null) return;

    final String specialtyName = specialtyResult["name"] ??
        specialtyResult["specialtyName"] ??
        specialtyResult["title"] ??
        "Chưa chọn chuyên khoa";

    // 2. chọn bác sĩ
    final doctorResult = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SelectDoctorPage(specialty: specialtyName),
      ),
    );
    if (doctorResult == null) return;

    final int? doctorId = _parseInt(doctorResult["doctorId"]);
    final int? departmentId = _parseInt(doctorResult["departmentId"]);

    if (doctorId == null || departmentId == null) {
      _showError("Không lấy được thông tin bác sĩ");
      return;
    }

    // 3. chọn ngày
    final date = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SelectDatePage()),
    );
    if (date == null) return;

    // 4. chọn slot
    final slotResult = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SelectSlotPage(
          doctorId: doctorId,
          departmentId: departmentId,
          date: date,
        ),
      ),
    );
    if (slotResult == null) return;

    final int slotId = slotResult["slotId"] is int
        ? slotResult["slotId"]
        : (int.tryParse(slotResult["slotId"].toString()) ?? 0);

    final String timeRange =
        (slotResult["timeRange"] as String?) ?? "Không xác định";

    final int startHour = slotResult["startHour"] ?? 0;
    final int startMinute = slotResult["startMinute"] ?? 0;

    // ⭐⭐⭐ 4.5 – NHẬP TRIỆU CHỨNG ⭐⭐⭐
    final symptom = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SelectSymptomPage()),
    );
    if (symptom == null) return;

    // 5. xác nhận
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConfirmBookingPage(
          fullName: p["fullName"],
          phone: p["phone"],
          specialty: specialtyName,
          doctor: doctorResult["doctorName"] ?? "Bác sĩ",
          doctorId: doctorId,
          departmentId: departmentId,
          slotId: slotId,
          slot: timeRange,
          date: date,
          patientCode: p["patientCode"],
          startHour: startHour,
          startMinute: startMinute,
          symptom: symptom, // ⭐⭐ gửi triệu chứng ⭐⭐
        ),
      ),
    );
  }

  // ========= Helper =========
  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  // ====================== UI ======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F9FB),
      appBar: AppBar(
        title: const Text("Đặt khám"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        elevation: 0.4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Chọn hồ sơ đặt khám",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff003366)),
            ),
            const SizedBox(height: 16),

            // Avatar ngang
            SizedBox(
              height: 130,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildAddProfileAvatar(),
                  const SizedBox(width: 14),
                  ...profiles.map((p) => _buildProfileAvatar(p)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: profiles.isEmpty
                  ? _emptyState()
                  : ListView.separated(
                      itemCount: profiles.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (_, i) => _buildProfileCard(profiles[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset("assets/images/doctor.png", height: 160),
            const SizedBox(height: 20),
            const Text(
              "Bạn chưa có hồ sơ đặt khám,\nvui lòng tạo hồ sơ mới",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createNewProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text("Thêm hồ sơ", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      );

  Widget _buildAddProfileAvatar() => Column(
        children: [
          InkWell(
            onTap: _createNewProfile,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: const Icon(Icons.add, color: Colors.blue, size: 34),
            ),
          ),
          const SizedBox(height: 8),
          const Text("Thêm mới", style: TextStyle(fontSize: 13)),
        ],
      );

  Widget _buildProfileAvatar(Map<String, dynamic> p) {
    final namePart = p["fullName"].toString().split(" ").last;

    final code = p["patientCode"];

    return Padding(
      padding: const EdgeInsets.only(right: 18),
      child: Column(
        children: [
          InkWell(
            onTap: () => _selectProfile(p),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue.withOpacity(.15),
              child: const Icon(Icons.person, size: 42, color: Colors.blue),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            namePart.toUpperCase(),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Text(code, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildProfileCard(Map<String, dynamic> p) {
    final name = p["fullName"];
    final code = p["patientCode"];
    final phone = maskPhone(p["phone"] ?? "");

    return InkWell(
      onTap: () => _selectProfile(p),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.blue.withOpacity(.15),
              child: const Icon(Icons.person, size: 34, color: Colors.blue),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff003366),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.qr_code, size: 18, color: Colors.blue),
                      const SizedBox(width: 6),
                      Text(code),
                      const SizedBox(width: 20),
                      const Icon(Icons.phone_android,
                          size: 18, color: Colors.blue),
                      const SizedBox(width: 6),
                      Text(phone),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.blue),
          ],
        ),
      ),
    );
  }
}
