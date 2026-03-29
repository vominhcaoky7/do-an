// File: lib/appointments/enter_patient_code.dart
// FLOW FIXED: Nhập mã bệnh nhân → clear cache cũ → lưu → mở HealthRecordScreen

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/health_record_screen.dart';

class EnterPatientCode extends StatefulWidget {
  const EnterPatientCode({super.key});

  @override
  State<EnterPatientCode> createState() => _EnterPatientCodeState();
}

class _EnterPatientCodeState extends State<EnterPatientCode> {
  final codeCtrl = TextEditingController();

  @override
  void dispose() {
    codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        elevation: 0,
        title: const Text('Nhập mã người bệnh'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nhập mã người bệnh đã được cấp ở lần khám trước.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: codeCtrl,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: 'Mã người bệnh',
                hintText: 'VD: BN123456789',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Tiếp tục',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ======================================================
  // FIXED FLOW:
  // 1. Nhập patientCode
  // 2. CLEAR cache hồ sơ cũ theo code
  // 3. Lưu patientCode mới
  // 4. Mở HealthRecordScreen
  // ======================================================
  Future<void> _handleContinue() async {
    final code = codeCtrl.text.trim().toUpperCase();

    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập mã người bệnh')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    // ===== FIX QUAN TRỌNG: CLEAR CACHE HỒ SƠ CŨ =====
    final keysToRemove =
        prefs.getKeys().where((k) => k.startsWith("health_")).toList();

    for (final k in keysToRemove) {
      await prefs.remove(k);
    }

    // ===== LƯU MÃ NGƯỜI BỆNH MỚI =====
    await prefs.setString("current_patient_code", code);

    debugPrint('====== ĐÃ RESET CACHE & LƯU MÃ BỆNH NHÂN: $code ======');

    // ===== MỞ HỒ SƠ SỨC KHỎE =====
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HealthRecordScreen(patientCode: code),
      ),
    );
  }
}
