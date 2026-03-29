import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/vaccination_service.dart';

class VaccinationBookingScreen extends StatefulWidget {
  const VaccinationBookingScreen({super.key});

  @override
  State<VaccinationBookingScreen> createState() =>
      _VaccinationBookingScreenState();
}

class _VaccinationBookingScreenState extends State<VaccinationBookingScreen> {
  final _vaccineCtrl = TextEditingController();
  final _doseCtrl = TextEditingController(text: "1");
  DateTime? _date;
  bool _loading = false;

  // =======================
  // Submit Form and Send Data to API
  // =======================
  Future<void> _submit() async {
    final prefs = await SharedPreferences.getInstance();
    final patientCode = prefs.getString("current_patient_code");
    final token = prefs.getString("token");

    if (patientCode == null || token == null || _date == null) {
      _toast("Thiếu thông tin, vui lòng kiểm tra lại.");
      return;
    }

    setState(() => _loading = true); // Set loading to true when submitting

    try {
      // Gửi yêu cầu API để tạo lịch tiêm
      await VaccinationService().createVaccination(
        patientCode: patientCode,
        vaccineName: _vaccineCtrl.text.trim(),
        doseNumber: int.parse(_doseCtrl.text),
        nextDueDate: _date!,
        token: token,
        note: "Đặt lịch tiêm từ Flutter", // Ghi chú mặc định
      );

      if (!mounted) return;
      Navigator.pop(context, true); // Đóng màn hình sau khi thành công

      // Hiển thị thông báo thành công
      _toast("Lịch tiêm đã được đặt thành công!");
    } catch (e) {
      _toast("Đặt lịch thất bại. Vui lòng thử lại.");
    } finally {
      setState(() =>
          _loading = false); // Set loading to false after the request completes
    }
  }

  // =======================
  // Helper function to show Toast messages
  // =======================
  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // =======================
  // Build the UI for Vaccination Booking Screen
  // =======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("📅 Đặt lịch tiêm")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Vaccine Name Field
            TextField(
              controller: _vaccineCtrl,
              decoration: const InputDecoration(labelText: "Tên vaccine"),
            ),
            // Dose Number Field
            TextField(
              controller: _doseCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Số mũi"),
            ),
            const SizedBox(height: 12),
            // Date Picker for nextDueDate
            ListTile(
              title: Text(_date == null
                  ? "Chọn ngày tiêm"
                  : "Ngày tiêm: ${_date!.toLocal().toString().split(' ')[0]}"),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                // Show DatePicker to select a date
                _date = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  initialDate: DateTime.now(),
                );
                setState(() {}); // Refresh the screen to show selected date
              },
            ),
            const SizedBox(height: 24),
            // Submit Button to submit the form
            ElevatedButton(
              onPressed:
                  _loading ? null : _submit, // Disable button while loading
              child: _loading
                  ? const CircularProgressIndicator() // Show progress while loading
                  : const Text("ĐẶT LỊCH TIÊM"),
            ),
          ],
        ),
      ),
    );
  }
}
