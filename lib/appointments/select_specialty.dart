// Folder: lib/appointments
// File: select_specialty.dart
// FINAL FIX – Ổn định, chống null, highlight chuẩn, trả về đúng format

import 'package:flutter/material.dart';

class SelectSpecialtyPage extends StatefulWidget {
  const SelectSpecialtyPage({super.key});

  @override
  State<SelectSpecialtyPage> createState() => _SelectSpecialtyPageState();
}

class _SelectSpecialtyPageState extends State<SelectSpecialtyPage> {
  String search = "";
  int tapIndex = -1;

  // =========================
  // DATA CHUYÊN KHOA
  // =========================
  final Map<String, List<Map<String, dynamic>>> specialtyGroups = {
    "Nội khoa": [
      {"id": 1, "name": "Nội tổng quát", "note": "", "price": "150.000đ"},
      {"id": 2, "name": "Nội tim mạch", "note": "", "price": "180.000đ"},
      {"id": 3, "name": "Nội hô hấp", "note": "", "price": "150.000đ"},
      {"id": 4, "name": "Nội thần kinh", "note": "", "price": "180.000đ"},
      {
        "id": 5,
        "name": "Nội tiết – đái tháo đường",
        "note": "",
        "price": "180.000đ"
      },
      {
        "id": 6,
        "name": "Dị ứng – miễn dịch lâm sàng",
        "note": "",
        "price": "150.000đ"
      },
      {"id": 7, "name": "Tiêu hoá – Gan mật", "note": "", "price": "180.000đ"},
    ],
    "Ngoại khoa": [
      {"id": 8, "name": "Ngoại tổng quát", "note": "", "price": "200.000đ"},
      {
        "id": 9,
        "name": "Chấn thương chỉnh hình",
        "note": "",
        "price": "250.000đ"
      },
      {"id": 10, "name": "Ngoại cột sống", "note": "", "price": "250.000đ"},
      {"id": 11, "name": "Ngoại thần kinh", "note": "", "price": "250.000đ"},
      {
        "id": 12,
        "name": "Hậu môn – trực tràng",
        "note": "",
        "price": "200.000đ"
      },
    ],
    "Sản – Phụ khoa": [
      {"id": 13, "name": "Khám sản", "note": "", "price": "150.000đ"},
      {"id": 14, "name": "Khám phụ khoa", "note": "", "price": "150.000đ"},
      {"id": 15, "name": "Hiếm muộn – IVF", "note": "", "price": "300.000đ"},
    ],
    "Nhi khoa": [
      {"id": 16, "name": "Nhi tổng quát", "note": "", "price": "120.000đ"},
      {"id": 17, "name": "Nhi hô hấp", "note": "", "price": "150.000đ"},
      {"id": 18, "name": "Nhi tiêu hoá", "note": "", "price": "150.000đ"},
      {
        "id": 19,
        "name": "Ghép gan nhi",
        "note": "(Chỉ nhận tái khám hoặc có giấy giới thiệu)",
        "price": "300.000đ"
      },
    ],
    "Chuyên khoa khác": [
      {"id": 20, "name": "Da liễu", "note": "", "price": "150.000đ"},
      {"id": 21, "name": "Tai Mũi Họng", "note": "", "price": "150.000đ"},
      {"id": 22, "name": "Mắt", "note": "", "price": "150.000đ"},
      {"id": 23, "name": "Răng Hàm Mặt", "note": "", "price": "150.000đ"},
      {
        "id": 24,
        "name": "Vật lý trị liệu – Phục hồi chức năng",
        "note": "",
        "price": "120.000đ"
      },
    ],
  };

  // ============================================================
  // BUILD UI
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F9FB),
      appBar: AppBar(
        title: const Text("Chọn chuyên khoa"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        elevation: 0.3,
      ),
      body: Column(
        children: [
          // SEARCH BOX
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) => setState(() => search = v.toLowerCase()),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Tìm nhanh chuyên khoa",
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              "Nhấn vào chuyên khoa để chọn",
              style: TextStyle(color: Colors.orange.shade700, fontSize: 13),
            ),
          ),

          Expanded(
            child: ListView(
              children: specialtyGroups.entries
                  .map(
                    (g) => _groupSection(g.key, g.value),
                  )
                  .toList(),
            ),
          )
        ],
      ),
    );
  }

  // ============================================================
  // GROUP SECTION
  // ============================================================
  Widget _groupSection(String title, List<Map<String, dynamic>> list) {
    final filtered = list
        .where((e) => e["name"].toString().toLowerCase().contains(search))
        .toList();

    if (filtered.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xff003366),
            ),
          ),
        ),
        ...filtered.map((item) {
          final index = item.hashCode; // tránh trùng index
          return _itemTile(item, index);
        }).toList(),
      ],
    );
  }

  // ============================================================
  // CARD ITEM – CHỌN CHUYÊN KHOA
  // ============================================================
  Widget _itemTile(Map<String, dynamic> item, int index) {
    final bool isTapped = tapIndex == index;

    return GestureDetector(
      onTapDown: (_) => setState(() => tapIndex = index),
      onTapCancel: () => setState(() => tapIndex = -1),
      onTapUp: (_) {
        setState(() => tapIndex = -1);

        Navigator.pop(context, {
          "name": item["name"], // CHUẨN CHO SelectDoctorPage
          "specialtyName": item["name"], // BACKUP
          "departmentId": item["id"], // CHUẨN CHO API
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isTapped ? Colors.blue.withOpacity(.08) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.blue.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xffE6F0FF),
              ),
              child: const Icon(Icons.info, color: Colors.blue, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item["name"],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff0044AA),
                ),
              ),
            ),
            Text(
              item["price"],
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue)
          ],
        ),
      ),
    );
  }
}
