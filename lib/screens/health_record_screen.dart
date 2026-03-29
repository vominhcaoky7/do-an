import 'package:flutter/material.dart';
import '../services/patient_profile_service.dart';

class HealthRecordScreen extends StatefulWidget {
  final String patientCode;

  const HealthRecordScreen({
    super.key,
    required this.patientCode,
  });

  @override
  State<HealthRecordScreen> createState() => _HealthRecordScreenState();
}

class _HealthRecordScreenState extends State<HealthRecordScreen> {
  // ===== STATE CHUẨN =====
  String? gender; // 'nam' | 'nu'
  String? bloodType; // 'O' | 'A' | 'B' | 'AB'

  // ===== CONTROLLERS =====
  final TextEditingController fullNameCtrl = TextEditingController();

  final Map<String, TextEditingController> controllers = {
    'dob': TextEditingController(),
    'address': TextEditingController(),
    'height': TextEditingController(),
    'weight': TextEditingController(),
    'allergies': TextEditingController(),
    'chronicDiseases': TextEditingController(),
    'medicalHistory': TextEditingController(),
  };

  final PatientProfileService service = PatientProfileService();

  @override
  void initState() {
    super.initState();
    _loadFromServer();
  }

  @override
  void dispose() {
    fullNameCtrl.dispose();
    controllers.values.forEach((c) => c.dispose());
    super.dispose();
  }

  // ======================
  // CONVERT DOB
  // ======================
  String? convertDob(String raw) {
    if (!raw.contains("/")) return raw;
    final p = raw.split("/");
    if (p.length != 3) return null;
    return "${p[2]}-${p[1].padLeft(2, '0')}-${p[0].padLeft(2, '0')}";
  }

  // ======================
  // LOAD SERVER
  // ======================
  Future<void> _loadFromServer() async {
    final data = await service.getProfile(widget.patientCode);

    if (data != null && data["exists"] == true) {
      setState(() {
        fullNameCtrl.text = data["fullName"] ?? "";

        final g = data["gender"];
        gender = (g == 'nam' || g == 'nu') ? g : null;

        final b = data["bloodType"];
        bloodType = ['O', 'A', 'B', 'AB'].contains(b) ? b : null;

        controllers['dob']!.text = data["dateOfBirth"] ?? "";
        controllers['address']!.text = data["address"] ?? "";
        controllers['height']!.text = data["height"]?.toString() ?? "";
        controllers['weight']!.text = data["weight"]?.toString() ?? "";
        controllers['allergies']!.text = data["allergies"] ?? "";
        controllers['chronicDiseases']!.text = data["chronic"] ?? "";
        controllers['medicalHistory']!.text = data["history"] ?? "";
      });
    }
  }

  // ======================
  // SAVE PROFILE
  // ======================
  Future<bool> _saveProfile() async {
    if (fullNameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập họ tên")),
      );
      return false;
    }

    // Kiểm tra PatientCode
    if (widget.patientCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mã bệnh nhân không hợp lệ")),
      );
      return false;
    }

    final data = {
      "userId": widget.patientCode, // Truyền PatientCode đúng cách
      "fullName": fullNameCtrl.text.trim(),
      "phone": "0342884664",
      "gender": gender,
      "dateOfBirth": convertDob(controllers['dob']!.text),
      "address": controllers['address']!.text,
      "bloodType": bloodType,
      "height": double.tryParse(controllers['height']!.text),
      "weight": double.tryParse(controllers['weight']!.text),
      "allergies": controllers['allergies']!.text,
      "chronicDiseases": controllers['chronicDiseases']!.text,
      "medicalHistory": controllers['medicalHistory']!.text,
      "patientCode":
          widget.patientCode, // Đảm bảo PatientCode được truyền đúng cách
    };

    try {
      final ok = await service.saveProfile(data);

      // Hiển thị thông báo sau khi lưu thành công hoặc thất bại
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? "Đã lưu hồ sơ!" : "Lưu thất bại"),
          backgroundColor: ok ? Colors.green : Colors.red,
        ),
      );

      return ok;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi lưu hồ sơ: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  // ======================
  // RESET FORM
  // ======================
  void _resetForm() {
    fullNameCtrl.clear();
    gender = null;
    bloodType = null;
    controllers.forEach((_, c) => c.clear());
  }

  String _newPatientCode() {
    return "BN${DateTime.now().millisecondsSinceEpoch}";
  }

  // ======================
  // UI
  // ======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hồ sơ sức khỏe — ${widget.patientCode}"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _field("Họ và tên", fullNameCtrl),
            _genderRadio(),
            _bloodTypeDropdown(),
            _field("Ngày sinh (DD/MM/YYYY)", controllers['dob']!),
            _field("Địa chỉ", controllers['address']!),
            _field("Chiều cao (cm)", controllers['height']!),
            _field("Cân nặng (kg)", controllers['weight']!),
            _field("Dị ứng thuốc", controllers['allergies']!),
            _field("Bệnh mạn tính", controllers['chronicDiseases']!),
            _field("Tiền sử bệnh", controllers['medicalHistory']!),

            const SizedBox(height: 20),

            // ===== NÚT LƯU =====
            ElevatedButton.icon(
              onPressed: _saveProfile,
              icon: const Icon(Icons.save),
              label: const Text("LƯU"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),

            const SizedBox(height: 12),

            // ===== LƯU & TẠO MỚI =====
            ElevatedButton.icon(
              onPressed: () async {
                final ok = await _saveProfile();
                if (!ok) return;

                setState(() => _resetForm());

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HealthRecordScreen(
                      patientCode: _newPatientCode(),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text("LƯU & TẠO HỒ SƠ MỚI"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ======================
  // WIDGETS
  // ======================
  Widget _genderRadio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Giới tính", style: TextStyle(fontWeight: FontWeight.w600)),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                value: 'nam',
                groupValue: gender,
                title: const Text("Nam"),
                onChanged: (v) => setState(() => gender = v),
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                value: 'nu',
                groupValue: gender,
                title: const Text("Nữ"),
                onChanged: (v) => setState(() => gender = v),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _bloodTypeDropdown() {
    const bloods = ['O', 'A', 'B', 'AB'];
    final safeValue = bloods.contains(bloodType) ? bloodType : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: safeValue,
        items: bloods
            .map((b) => DropdownMenuItem(value: b, child: Text(b)))
            .toList(),
        onChanged: (v) => setState(() => bloodType = v),
        decoration: InputDecoration(
          labelText: "Nhóm máu",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
        ),
      ),
    );
  }
}
