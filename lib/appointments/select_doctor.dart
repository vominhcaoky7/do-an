// Folder: lib/appointments
// File: select_doctor.dart
// FINAL FIX – Đồng bộ SQL + Chống null + Không crash + Mapping chuẩn

import 'package:flutter/material.dart';

class SelectDoctorPage extends StatefulWidget {
  final String specialty;

  const SelectDoctorPage({
    super.key,
    required this.specialty,
  });

  @override
  State<SelectDoctorPage> createState() => _SelectDoctorPageState();
}

class _SelectDoctorPageState extends State<SelectDoctorPage>
    with SingleTickerProviderStateMixin {
  String? selectedWeekday;
  String? selectedSession;

  // ==========================
  // CHUẨN HÓA TÊN CHUYÊN KHOA
  // ==========================
  String get normalizedSpecialty {
    final alias = {
      "Nội tổng quát": "Khám tổng quát",
      "Nội khoa tổng quát": "Khám tổng quát",
      "Tổng quát": "Khám tổng quát",
      "Khám tổng quát": "Khám tổng quát",
      "Ngoại khoa": "Ngoại tổng quát",
      "Ngoại tổng quát": "Ngoại tổng quát",
      "Da liễu": "Da liễu",
      "Tai Mũi Họng": "Tai Mũi Họng",
      "Xương Khớp": "Xương Khớp",
    };

    final raw = widget.specialty.trim();
    return alias[raw] ?? raw;
  }

  // =====================================================
  // LIST BÁC SĨ – ĐÃ ĐỒNG BỘ 100% VỚI SQL BACKEND
  // =====================================================
  final Map<String, List<Map<String, dynamic>>> doctorsBySpecialty = {
    "Khám tổng quát": [
      {
        "id": 1,
        "departmentId": 1,
        "name": "BS. Nguyễn Văn A",
        "gender": "Nam",
        "price": 120000,
        "weekday": ["2", "3", "4", "5"],
        "session": ["Sáng", "Chiều"],
      },
      {
        "id": 2,
        "departmentId": 1,
        "name": "BS. Trần Thị B",
        "gender": "Nữ",
        "price": 120000,
        "weekday": ["2", "4"],
        "session": ["Sáng"],
      },
    ],
    "Ngoại tổng quát": [
      {
        "id": 3,
        "departmentId": 2,
        "name": "BS. Lê Văn C",
        "gender": "Nam",
        "price": 150000,
        "weekday": ["3", "5", "6"],
        "session": ["Chiều"],
      },
      {
        "id": 4,
        "departmentId": 2,
        "name": "BS. Phạm Thị D",
        "gender": "Nữ",
        "price": 150000,
        "weekday": ["2", "6"],
        "session": ["Sáng"],
      },
    ],
    "Da liễu": [
      {
        "id": 5,
        "departmentId": 3,
        "name": "BS. Vũ Văn E",
        "gender": "Nam",
        "price": 150000,
        "weekday": ["3", "4"],
        "session": ["Sáng"],
      },
      {
        "id": 6,
        "departmentId": 3,
        "name": "BS. Nguyễn Thu F",
        "gender": "Nữ",
        "price": 150000,
        "weekday": ["4", "5"],
        "session": ["Chiều"],
      },
    ],
    "Tai Mũi Họng": [
      {
        "id": 7,
        "departmentId": 4,
        "name": "BS. Đỗ Minh G",
        "gender": "Nam",
        "price": 150000,
        "weekday": ["2", "3"],
        "session": ["Chiều"],
      },
      {
        "id": 8,
        "departmentId": 4,
        "name": "BS. Hồ Lan H",
        "gender": "Nữ",
        "price": 150000,
        "weekday": ["5", "6"],
        "session": ["Sáng"],
      },
    ],
    "Xương Khớp": [
      {
        "id": 9,
        "departmentId": 5,
        "name": "BS. Võ Trí I",
        "gender": "Nam",
        "price": 180000,
        "weekday": ["3", "4"],
        "session": ["Sáng"],
      },
      {
        "id": 10,
        "departmentId": 5,
        "name": "BS. Tống Mỹ K",
        "gender": "Nữ",
        "price": 180000,
        "weekday": ["6"],
        "session": ["Chiều"],
      },
    ],
  };

  // =====================================================
  // FILTER BÁC SĨ – KHÔNG CRASH
  // =====================================================
  List<Map<String, dynamic>> get filteredDoctors {
    final list = doctorsBySpecialty[normalizedSpecialty] ?? [];
    if (list.isEmpty) return [];

    return list.where((doc) {
      if (selectedWeekday != null &&
          !(doc["weekday"] as List).contains(selectedWeekday)) return false;

      if (selectedSession != null &&
          !(doc["session"] as List).contains(selectedSession)) return false;

      return true;
    }).toList();
  }

  // =====================================================
  // UI HIỂN THỊ
  // =====================================================
  @override
  Widget build(BuildContext context) {
    final hasDoctor = doctorsBySpecialty.containsKey(normalizedSpecialty);

    return Scaffold(
      appBar: AppBar(
        title: Text("Chọn bác sĩ - ${widget.specialty}"),
        foregroundColor: Colors.blue,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: hasDoctor
          ? Column(
              children: [
                _filters(),
                Expanded(
                  child: filteredDoctors.isEmpty
                      ? Center(
                          child: Text(
                            "Không tìm thấy bác sĩ phù hợp.",
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredDoctors.length,
                          padding: const EdgeInsets.all(12),
                          itemBuilder: (_, i) =>
                              _buildDoctorCard(filteredDoctors[i]),
                        ),
                ),
              ],
            )
          : _noSpecialty(),
    );
  }

  Widget _filters() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          _filterBox(
            title: "Thứ",
            value: selectedWeekday,
            onTap: () => _selectWeekday(context),
          ),
          const SizedBox(width: 10),
          _filterBox(
            title: "Ca",
            value: selectedSession,
            onTap: () => _selectSession(context),
          ),
        ],
      ),
    );
  }

  Widget _noSpecialty() {
    return Center(
      child: Text(
        "Chuyên khoa chưa có bác sĩ.",
        style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
      ),
    );
  }

  // =====================================================
  // UI FILTER BOX
  // =====================================================
  Widget _filterBox({
    required String title,
    required String? value,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value ?? title,
                style: TextStyle(
                  color: value == null ? Colors.grey : Colors.blue,
                  fontWeight:
                      value == null ? FontWeight.normal : FontWeight.bold,
                ),
              ),
              const Icon(Icons.keyboard_arrow_down, color: Colors.blue),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================
  // FILTER POPUP
  // =====================================================
  void _selectWeekday(BuildContext context) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (_) =>
          _bottomSheetList("Chọn thứ", ["2", "3", "4", "5", "6", "7"]),
    );
    if (selected != null) setState(() => selectedWeekday = selected);
  }

  void _selectSession(BuildContext context) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => _bottomSheetList("Chọn ca khám", ["Sáng", "Chiều"]),
    );
    if (selected != null) setState(() => selectedSession = selected);
  }

  Widget _bottomSheetList(String title, List<String> items) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...items.map(
              (e) => ListTile(
                title: Text(e),
                onTap: () => Navigator.pop(context, e),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // CARD BÁC SĨ – RETURN DATA CHUẨN
  // =====================================================
  Widget _buildDoctorCard(Map<String, dynamic> d) {
    final avatar = d["gender"] == "Nữ" ? Icons.female : Icons.male;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.pop(context, {
          "doctorId": d["id"],
          "doctorName": d["name"],
          "departmentId": d["departmentId"],
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          border: Border.all(color: Colors.blue.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.blue.withOpacity(.15),
              child: Icon(avatar, color: Colors.blue, size: 32),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    d["name"],
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text("Giá khám: ${d["price"]}đ",
                      style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    "Thứ: ${d["weekday"].join(', ')} | Ca: ${d["session"].join(', ')}",
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue),
          ],
        ),
      ),
    );
  }
}
