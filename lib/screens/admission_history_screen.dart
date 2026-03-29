import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/hospital_admission.dart';

// 1. Import màn hình Home để quay về
import '/home_screen.dart';

class AdmissionHistoryScreen extends StatefulWidget {
  final String phoneNumber;

  const AdmissionHistoryScreen({Key? key, required this.phoneNumber})
      : super(key: key);

  @override
  _AdmissionHistoryScreenState createState() => _AdmissionHistoryScreenState();
}

class _AdmissionHistoryScreenState extends State<AdmissionHistoryScreen> {
  // ⚠️ SỬA IP CHO ĐÚNG
  final String baseUrl = "http://10.0.2.2:5182/api/admission";

  List<HospitalAdmission> history = [];
  bool isLoading = true;

  final Color primaryColor = const Color(0xFF0D47A1);
  final Color bgColor = const Color(0xFFF5F7FA);

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/history?phone=${widget.phoneNumber}'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          history = data.map((e) => HospitalAdmission.fromJson(e)).toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Lỗi: $e");
      setState(() => isLoading = false);
    }
  }

  Widget _buildStatusBadge(String status) {
    bool isApproved = status == 'DaDuyet';
    Color badgeBg =
        isApproved ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0);
    Color badgeText =
        isApproved ? const Color(0xFF2E7D32) : const Color(0xFFEF6C00);
    String label = isApproved ? "Đã tiếp nhận" : "Chờ duyệt";
    IconData icon = isApproved ? Icons.check_circle : Icons.hourglass_top;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeText.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: badgeText),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
                color: badgeText, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String rawDate) {
    try {
      DateTime dt = DateTime.parse(rawDate);
      return "${dt.day}/${dt.month}/${dt.year} • ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("Lịch sử đăng ký",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,

        // --- 2. TÙY CHỈNH NÚT BACK ---
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Thay vì pop (quay lại form), ta đẩy về Home và xóa lịch sử cũ
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false, // Xóa sạch các màn hình trước đó
            );
          },
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : history.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: history.length,
                  separatorBuilder: (ctx, i) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final item = history[index];
                    return _buildHistoryCard(item);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(25),
            decoration:
                BoxDecoration(color: Colors.grey[200], shape: BoxShape.circle),
            child: Icon(Icons.history_toggle_off,
                size: 70, color: Colors.grey[400]),
          ),
          const SizedBox(height: 20),
          Text("Không tìm thấy lịch sử nào",
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text("Số điện thoại: ${widget.phoneNumber}",
              style: TextStyle(fontSize: 14, color: Colors.grey[500])),
          const SizedBox(height: 30),

          // Thêm nút về trang chủ ở màn hình trống cho tiện
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.home),
            label: const Text("Về Trang Chủ"),
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
          )
        ],
      ),
    );
  }

  Widget _buildHistoryCard(HospitalAdmission item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 6),
                    Text(_formatDateTime(item.createdAt),
                        style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
                _buildStatusBadge(item.status),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.person, color: Colors.blue, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.patientName,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87)),
                      const SizedBox(height: 2),
                      Text("SĐT: ${item.phoneNumber}",
                          style:
                              TextStyle(fontSize: 13, color: Colors.grey[500])),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFFE0B2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Lý do / Triệu chứng:",
                      style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFBF360C),
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(item.reason,
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xFF3E2723), height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
