import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CreateProfilePage extends StatefulWidget {
  const CreateProfilePage({super.key});

  @override
  State<CreateProfilePage> createState() => _CreateProfilePageState();
}

class _CreateProfilePageState extends State<CreateProfilePage> {
  final TextEditingController lastNameCtrl = TextEditingController();
  final TextEditingController firstNameCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController cccdCtrl = TextEditingController();
  final TextEditingController passportCtrl = TextEditingController();
  final TextEditingController personalIdCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  final TextEditingController jobCtrl = TextEditingController();

  DateTime? birthDate;

  // ===== VALUE CHUẨN =====
  String? gender; // 'nam' | 'nu'
  String? nationality;
  String? ethnicity;
  String? province;
  String? district;

  final List<String> nationalityList = [
    "Việt Nam",
    "Mỹ",
    "Nhật Bản",
    "Hàn Quốc"
  ];

  final List<String> ethnicityList = [
    "Kinh",
    "Tày",
    "Nùng",
    "Mường",
    "Khmer",
    "Hoa"
  ];

  final List<String> provinceList = [
    "TP. Hồ Chí Minh",
    "Hà Nội",
    "Đà Nẵng",
    "Cần Thơ",
    "Khánh Hòa"
  ];

  final Map<String, List<String>> districtMap = {
    "TP. Hồ Chí Minh": ["Quận 1", "Quận 3", "Quận 7", "Thủ Đức", "Bình Thạnh"],
    "Hà Nội": ["Hoàn Kiếm", "Ba Đình", "Đống Đa", "Cầu Giấy"],
    "Đà Nẵng": ["Hải Châu", "Thanh Khê", "Ngũ Hành Sơn"],
    "Cần Thơ": ["Ninh Kiều", "Bình Thủy"],
    "Khánh Hòa": ["Nha Trang", "Cam Ranh"],
  };

  // ================== VALIDATE PHONE ==================
  bool isValidPhone(String phone) {
    return RegExp(r'^[0-9]{9,11}$').hasMatch(phone);
  }

  // ================== SAVE PROFILE ==================
  Future<void> _saveProfile() async {
    final last = lastNameCtrl.text.trim();
    final first = firstNameCtrl.text.trim();
    final phone = phoneCtrl.text.trim();

    if (last.isEmpty ||
        first.isEmpty ||
        phone.isEmpty ||
        birthDate == null ||
        gender == null ||
        nationality == null ||
        ethnicity == null ||
        province == null ||
        district == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Vui lòng nhập đầy đủ thông tin bắt buộc")),
      );
      return;
    }

    if (!isValidPhone(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Số điện thoại không hợp lệ")),
      );
      return;
    }

    final patientCode =
        "BN${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}";

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString("profiles");
    final List list = raw == null ? [] : jsonDecode(raw);

    final newProfile = {
      "patientCode": patientCode,
      "fullName": "$last $first",
      "lastName": last,
      "firstName": first,
      "phone": phone,
      "email": emailCtrl.text.trim(),
      "cccd": cccdCtrl.text.trim(),
      "passport": passportCtrl.text.trim(),
      "personalId": personalIdCtrl.text.trim(),
      "gender": gender, // 'nam' | 'nu'
      "birth": birthDate!.toIso8601String(),
      "nationality": nationality,
      "ethnicity": ethnicity,
      "province": province,
      "district": district,
      "address": addressCtrl.text.trim(),
      "job": jobCtrl.text.trim(),
    };

    list.insert(0, newProfile);
    await prefs.setString("profiles", jsonEncode(list));

    Navigator.pop(context, true);
  }

  // ================== DATE PICKER ==================
  void _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 20),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) setState(() => birthDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      appBar: AppBar(
        title: const Text("Tạo hồ sơ khám bệnh"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        elevation: 0.6,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _title("Thông tin cá nhân"),
          _input("Họ và chữ lót", lastNameCtrl),
          _input("Tên", firstNameCtrl),
          _section("Giới tính"),
          Row(
            children: const [],
          ),
          _genderRadio(),
          _section("Ngày sinh"),
          _dateBox(),
          const SizedBox(height: 20),
          _title("Quốc tịch – Dân tộc – Địa chỉ"),
          _safeDropdown("Quốc gia", nationalityList, nationality,
              (v) => setState(() => nationality = v)),
          _safeDropdown("Dân tộc", ethnicityList, ethnicity,
              (v) => setState(() => ethnicity = v)),
          _safeDropdown("Tỉnh / Thành phố", provinceList, province, (v) {
            setState(() {
              province = v;
              district = null;
            });
          }),
          _safeDropdown(
            "Quận / Huyện",
            districtMap[province] ?? [],
            district,
            (v) => setState(() => district = v),
          ),
          _input("Địa chỉ cụ thể", addressCtrl),
          _input("Nghề nghiệp", jobCtrl),
          const SizedBox(height: 20),
          _title("Thông tin liên hệ"),
          _input("Số điện thoại", phoneCtrl, type: TextInputType.phone),
          _input("Email", emailCtrl),
          _input("CCCD", cccdCtrl, type: TextInputType.number),
          const SizedBox(height: 30),
          _submitButton(),
        ],
      ),
    );
  }

  // ================= UI COMPONENTS =================

  Widget _genderRadio() {
    return Row(
      children: [
        Expanded(
          child: RadioListTile<String>(
            value: 'nam',
            groupValue: gender,
            title: const Text("Nam"),
            onChanged: (v) => setState(() => gender = v),
            dense: true,
          ),
        ),
        Expanded(
          child: RadioListTile<String>(
            value: 'nu',
            groupValue: gender,
            title: const Text("Nữ"),
            onChanged: (v) => setState(() => gender = v),
            dense: true,
          ),
        ),
      ],
    );
  }

  Widget _safeDropdown(
    String hint,
    List<String> items,
    String? value,
    ValueChanged<String?> onChange,
  ) {
    final safeValue = (value != null && items.contains(value)) ? value : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: _boxStyle(),
      child: DropdownButtonFormField<String>(
        value: safeValue,
        decoration: const InputDecoration(border: InputBorder.none),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: items.isEmpty ? null : onChange,
        hint: Text(hint),
      ),
    );
  }

  Widget _input(String label, TextEditingController ctrl,
      {TextInputType type = TextInputType.text}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: _boxStyle(),
      child: TextField(
        controller: ctrl,
        keyboardType: type,
        decoration: InputDecoration(labelText: label, border: InputBorder.none),
      ),
    );
  }

  Widget _dateBox() {
    return InkWell(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: _boxStyle(),
        child: Row(
          children: [
            const Icon(Icons.calendar_month, color: Colors.blue),
            const SizedBox(width: 10),
            Text(
              birthDate == null
                  ? "Ngày sinh"
                  : "${birthDate!.day}/${birthDate!.month}/${birthDate!.year}",
            )
          ],
        ),
      ),
    );
  }

  Widget _title(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xff003366)),
        ),
      );

  Widget _section(String text) => Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 6),
        child: Text(
          text,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      );

  BoxDecoration _boxStyle() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.black12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget _submitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text("XÁC NHẬN", style: TextStyle(fontSize: 17)),
      ),
    );
  }
}
