import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// 1. MODEL (Nên để file riêng, nhưng để đây cho gọn cũng được)
class PaymentTransaction {
  final int id;
  final String patientCode;
  final double amount;
  final String status;
  final String createdAt;

  PaymentTransaction({
    required this.id,
    required this.patientCode,
    required this.amount,
    required this.status,
    required this.createdAt,
  });

  factory PaymentTransaction.fromJson(Map<String, dynamic> json) {
    return PaymentTransaction(
      id: json['id'] ?? 0,
      patientCode: json['patientCode'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] ?? '',
    );
  }
}

// 2. MÀN HÌNH THANH TOÁN
class PayFeePage extends StatefulWidget {
  const PayFeePage({super.key});

  @override
  State<PayFeePage> createState() => _PayFeePageState();
}

class _PayFeePageState extends State<PayFeePage> {
  final TextEditingController _amountCtrl = TextEditingController();
  final TextEditingController _patientCodeCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPatientCode();
  }

  // Tự động điền mã bệnh nhân nếu có
  Future<void> _loadPatientCode() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString("current_patient_code");
    if (savedCode != null && savedCode.isNotEmpty) {
      setState(() {
        _patientCodeCtrl.text = savedCode;
      });
    }
  }

  // --- LOGIC XỬ LÝ CHÍNH ---
  Future<void> _submitPayment() async {
    final amountText = _amountCtrl.text.trim();
    final code = _patientCodeCtrl.text.trim();

    if (amountText.isEmpty || code.isEmpty) {
      _showError("Vui lòng nhập đầy đủ thông tin");
      return;
    }

    final int? amount = int.tryParse(amountText);
    if (amount == null || amount <= 0) {
      _showError("Số tiền không hợp lệ");
      return;
    }

    setState(() => _isLoading = true);

    // Gọi API Backend
    final url = Uri.parse("http://10.0.2.2:5182/api/payment/create");
    final body = {
      "patientCode": code,
      "amount": amount,
      "method": "app",
      "status": "success",
    };

    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      setState(() => _isLoading = false);

      // Nếu API thành công (200) HOẶC tạo mới thành công (201)
      if (res.statusCode == 200 || res.statusCode == 201) {
        // QUAN TRỌNG: Lưu hóa đơn vào máy để trang Lịch sử đọc được
        await _saveInvoiceLocally(code, amount);

        _showSuccess();
      } else {
        _showError("Thanh toán thất bại: ${res.body}");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      // Lỗi mạng: Vẫn cho lưu offline (giả lập) nếu bạn muốn test
      _showError("Lỗi kết nối Server: $e");
    }
  }

  // Hàm lưu hóa đơn vào SharedPreferences
  Future<void> _saveInvoiceLocally(String code, int amount) async {
    final prefs = await SharedPreferences.getInstance();

    // Lấy danh sách cũ
    final List<String> history = prefs.getStringList('invoices') ?? [];

    // Tạo hóa đơn mới
    final newInvoice = {
      'id':
          'HD${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
      'patientCode': code,
      'amount': '$amount đ', // Lưu dạng chuỗi có đ để hiển thị luôn
      'date':
          "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
      'status': 'success'
    };

    // Chèn lên đầu danh sách
    history.insert(0, jsonEncode(newInvoice));

    // Lưu lại
    await prefs.setStringList('invoices', history);
  }

  // --- CÁC HÀM UI ---
  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  void _showSuccess() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 10),
            Text("Thành công"),
          ],
        ),
        content: const Text("Thanh toán thành công!\nHoá đơn đã được lưu."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Đóng Dialog
              Navigator.pop(context); // Quay về màn hình trước
            },
            child:
                const Text("OK", style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thanh toán viện phí"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        elevation: 0.5,
      ),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Nhập thông tin thanh toán",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Mã bệnh nhân
            TextField(
              controller: _patientCodeCtrl,
              decoration: const InputDecoration(
                labelText: "Mã bệnh nhân",
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            // Số tiền
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Số tiền (VND)",
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),

            const SizedBox(height: 30),

            // Nút bấm
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        "XÁC NHẬN THANH TOÁN",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
