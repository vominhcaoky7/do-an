import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SupportScreen extends StatefulWidget {
  const SupportScreen({Key? key}) : super(key: key);

  @override
  _SupportScreenState createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  // ⚠️ SỬA IP
  final String baseUrl = "http://10.0.2.2:5182/api/support";

  // --- Bảng màu chủ đạo (Teal / Xanh Ngọc) ---
  final Color primaryColor = const Color(0xFF009688);
  final Color lightPrimaryColor = const Color(0xFFE0F2F1);
  final Color bgColor = const Color(0xFFF8F9FA);

  // Hàm gọi điện hoặc mở web
  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Không thể mở liên kết: $urlString"),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Hàm hiện dialog Gửi phản hồi đẹp hơn
  void _showFeedbackDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final contentCtrl = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.feedback_rounded, color: primaryColor),
            const SizedBox(width: 10),
            const Text("Gửi góp ý / Báo lỗi"),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Ý kiến của bạn giúp chúng tôi cải thiện dịch vụ tốt hơn.",
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              _buildDialogTextField(nameCtrl, "Tên của bạn", Icons.person),
              const SizedBox(height: 15),
              _buildDialogTextField(phoneCtrl, "SĐT liên hệ", Icons.phone,
                  inputType: TextInputType.phone),
              const SizedBox(height: 15),
              _buildDialogTextField(
                  contentCtrl, "Nội dung cần hỗ trợ", Icons.message,
                  maxLines: 3),
            ],
          ),
        ),
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
            child: const Text("Hủy",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
            ),
            onPressed: () async {
              if (contentCtrl.text.isEmpty || phoneCtrl.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Vui lòng nhập SĐT và nội dung.")),
                );
                return;
              }
              Navigator.pop(ctx);
              await _sendFeedbackToApi(
                  nameCtrl.text, phoneCtrl.text, contentCtrl.text);
            },
            child: const Text("Gửi ngay", style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  // Helper xây dựng TextField trong Dialog
  Widget _buildDialogTextField(
      TextEditingController controller, String label, IconData icon,
      {TextInputType inputType = TextInputType.text, int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryColor.withOpacity(0.7)),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      ),
    );
  }

  Future<void> _sendFeedbackToApi(
      String name, String phone, String content) async {
    try {
      // Hiển thị loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Đang gửi..."), duration: Duration(seconds: 1)),
      );

      final res = await http.post(
        Uri.parse('$baseUrl/send'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(
            {"senderName": name, "phoneNumber": phone, "content": content}),
      );
      if (res.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text("Đã gửi phản hồi thành công!")
              ]),
              backgroundColor: primaryColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Lỗi gửi tin. Vui lòng thử lại sau.")),
          );
        }
      }
    } catch (e) {
      print(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lỗi kết nối máy chủ.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      // Sử dụng CustomScrollView để tạo hiệu ứng header
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160.0,
            floating: false,
            pinned: true,
            backgroundColor: primaryColor,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primaryColor, primaryColor.withOpacity(0.8)],
                  ),
                  // Bo tròn góc dưới của header
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle),
                      child: const Icon(Icons.support_agent,
                          size: 50, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Trung tâm Hỗ trợ",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "Kênh liên hệ nhanh",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                  ),

                  // Các nút chức năng (Sử dụng cùng 1 màu chủ đạo)
                  _buildSupportCard(
                    icon: Icons.phone_in_talk_rounded,
                    title: "Tổng đài tư vấn",
                    subtitle: "1900 1234 (Hoạt động 24/7)",
                    onTap: () => _launchUrl("tel:19001234"),
                  ),
                  _buildSupportCard(
                    icon: Icons.chat_bubble_rounded,
                    title: "Chat Zalo OA",
                    subtitle: "Nhắn tin trực tiếp với CSKH",
                    onTap: () => _launchUrl("https://zalo.me/0901234567"),
                  ),
                  _buildSupportCard(
                    icon: Icons.language_rounded,
                    title: "Website Bệnh viện",
                    subtitle: "Thông tin, tin tức, đặt lịch",
                    onTap: () => _launchUrl("https://google.com"),
                  ),

                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "Phản hồi & Góp ý",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                  ),
                  // Card gửi phản hồi nổi bật hơn một chút
                  _buildFeedbackCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Card chức năng thông thường
  Widget _buildSupportCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ]),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: lightPrimaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: primaryColor, size: 28),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87)),
                      const SizedBox(height: 4),
                      Text(subtitle,
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 18, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget Card Gửi phản hồi (Thiết kế riêng để nổi bật)
  Widget _buildFeedbackCard() {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [primaryColor.withOpacity(0.9), primaryColor]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: primaryColor.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6))
          ]),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _showFeedbackDialog,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.mail_outline_rounded,
                      color: Colors.white, size: 30),
                ),
                const SizedBox(width: 15),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Gửi góp ý / Báo lỗi",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Colors.white)),
                      SizedBox(height: 4),
                      Text("Gửi trực tiếp đến Ban quản lý",
                          style:
                              TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_rounded, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
