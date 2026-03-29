import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Import màn hình lịch sử
import 'admission_history_screen.dart';

class HospitalAdmissionScreen extends StatefulWidget {
  const HospitalAdmissionScreen({Key? key}) : super(key: key);

  @override
  _HospitalAdmissionScreenState createState() =>
      _HospitalAdmissionScreenState();
}

class _HospitalAdmissionScreenState extends State<HospitalAdmissionScreen> {
  // ⚠️ SỬA IP CHO ĐÚNG MÁY BẠN
  final String baseUrl = "http://10.0.2.2:5182/api/admission";

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _reasonController = TextEditingController();
  bool _isLoading = false;

  // Màu chủ đạo cho màn hình này
  final Color primaryColor =
      const Color(0xFF0D47A1); // Xanh dương đậm chuyên nghiệp
  final Color accentColor = const Color(0xFFFF5252); // Đỏ cam nổi bật cho nút

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> submitForm() async {
    // (Giữ nguyên logic cũ của bạn)
    if (_nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng điền đầy đủ thông tin"),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/create'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "patientName": _nameController.text.trim(),
          "phoneNumber": _phoneController.text.trim(),
          "reason": _reasonController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        _showSuccessDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: ${response.statusCode}")),
        );
      }
    } catch (e) {
      print("Lỗi: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Lỗi kết nối đến máy chủ. Vui lòng kiểm tra lại.")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[600]),
            const SizedBox(width: 10),
            const Text("Thành công!"),
          ],
        ),
        content: const Text(
            "Đơn đăng ký nhập viện của bạn đã được gửi.\nBệnh viện sẽ liên hệ lại sớm nhất."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Đóng Dialog
              Navigator.pop(context); // Quay về Home
            },
            child:
                const Text("OK", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // Hàm helper để tạo kiểu cho ô nhập liệu đẹp hơn
  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[600]),
      prefixIcon: Icon(icon, color: primaryColor.withOpacity(0.7)),
      filled: true,
      fillColor: Colors.grey[50], // Nền xám nhẹ
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none, // Ẩn viền mặc định
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Sử dụng CustomScrollView để tạo hiệu ứng header đẹp mắt
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            backgroundColor: primaryColor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              // Nút xem lịch sử với thiết kế mới
              Container(
                margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12)),
                child: IconButton(
                  icon: const Icon(Icons.history, color: Colors.white),
                  tooltip: "Xem lịch sử",
                  onPressed: () {
                    if (_phoneController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text("Vui lòng nhập SĐT bên dưới để xem lịch sử"),
                          backgroundColor: Colors.orange,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdmissionHistoryScreen(
                            phoneNumber: _phoneController.text.trim()),
                      ),
                    );
                  },
                ),
              )
            ],
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              titlePadding: EdgeInsets.zero,
              title: const SizedBox(), // Ẩn title mặc định khi thu nhỏ
              background: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryColor, const Color(0xFF1565C0)],
                )),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Icon(Icons.local_hospital_rounded,
                        size: 60, color: Colors.white.withOpacity(0.9)),
                    const SizedBox(height: 10),
                    const Text(
                      "Đăng Ký Nhập Viện",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Điền thông tin để được hỗ trợ nhanh nhất",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Phần Form nhập liệu
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                // Tạo hiệu ứng bo tròn góc trên để trùm lên header
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 30, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Thông tin người bệnh",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Nhập Tên
                    TextField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: _buildInputDecoration(
                          "Họ và tên", Icons.person_outline),
                    ),
                    const SizedBox(height: 20),

                    // Nhập SĐT
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: _buildInputDecoration("Số điện thoại liên hệ",
                          Icons.phone_android_outlined),
                    ),
                    const SizedBox(height: 20),

                    // Nhập Lý do
                    TextField(
                      controller: _reasonController,
                      maxLines: 4,
                      decoration: _buildInputDecoration(
                              "Triệu chứng / Lý do nhập viện",
                              Icons.sick_outlined)
                          .copyWith(
                              alignLabelWithHint:
                                  true), // Căn label lên trên cùng
                    ),
                    const SizedBox(height: 40),

                    // Nút Gửi (Thiết kế Gradient)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [accentColor, const Color(0xFFFF8A65)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: accentColor.withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              )
                            ]),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2.5))
                              : const Text(
                                  "GỬI ĐĂNG KÝ NGAY",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 1),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        "Bệnh viện sẽ liên hệ lại qua SĐT bạn cung cấp.",
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
