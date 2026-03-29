import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // ⚠️ QUAN TRỌNG: Đổi IP này thành IP máy tính chạy Backend của bạn
  // Nếu chạy máy ảo Android: 10.0.2.2
  // Nếu chạy điện thoại thật: Nhập IP LAN (ví dụ 192.168.1.x)
  final String baseUrl = "http://10.0.2.2:5182/api/safety";

  // Các biến UI mặc định
  bool _notiEnabled = true;
  bool _faceIdEnabled = false;

  // Các biến cho Chế độ An toàn
  bool _safeTourMode = false;
  String? _userCode; // Mã bệnh nhân hoặc SĐT
  String _lastCheckInTime = "Chưa cập nhật";

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  // 1. Tải thông tin từ bộ nhớ máy
  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userCode = prefs.getString("current_patient_code");
      // Lấy trạng thái cũ xem có đang bật chế độ an toàn không
      _safeTourMode = prefs.getBool("safety_mode_active") ?? false;
    });
  }

  // 2. Hàm Bật/Tắt chế độ (Sửa thành void để không bị lỗi onChanged)
  void _toggleSafeMode(bool value) async {
    if (_userCode == null) {
      _showSnack("Vui lòng đăng nhập để dùng tính năng này", Colors.orange);
      return;
    }

    // Cập nhật giao diện NGAY LẬP TỨC cho mượt (Optimistic UI)
    setState(() => _safeTourMode = value);

    try {
      final endpoint = value ? "start" : "stop";
      final body = value
          ? jsonEncode({"phone": _userCode, "name": "BN $_userCode"})
          : jsonEncode({"phone": _userCode});

      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        // Nếu thành công: Lưu trạng thái vào máy
        final prefs = await SharedPreferences.getInstance();
        prefs.setBool("safety_mode_active", value);

        if (value) {
          setState(() => _lastCheckInTime = "Vừa xong");
          _showSafetyDialog(); // Hiện hướng dẫn
        }
      } else {
        // Nếu Server lỗi: Hoàn tác lại nút Switch
        setState(() => _safeTourMode = !value);
        _showSnack("Lỗi Server: ${response.body}", Colors.red);
      }
    } catch (e) {
      // Nếu mất mạng: Hoàn tác lại nút Switch
      setState(() => _safeTourMode = !value);
      _showSnack("Không kết nối được Server!", Colors.red);
      print("Lỗi: $e");
    }
  }

  // 3. Hàm Báo An Toàn (Check-in)
  Future<void> _sendSafeSignal() async {
    if (_userCode == null) return;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/checkin'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phone": _userCode}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _lastCheckInTime = "${DateTime.now().hour}:${DateTime.now().minute}";
        });
        _showSnack("✅ Đã báo an toàn thành công!", Colors.green);
      } else {
        _showSnack("⚠️ Server không nhận: ${response.body}", Colors.orange);
      }
    } catch (e) {
      _showSnack("❌ Lỗi kết nối mạng", Colors.red);
    }
  }

  // Hàm hiện thông báo nhỏ bên dưới
  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(msg),
          backgroundColor: color,
          duration: const Duration(seconds: 2)),
    );
  }

  void _showSafetyDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange),
          SizedBox(width: 10),
          Text("Lưu ý An toàn"),
        ]),
        content: const Text(
            "Hệ thống sẽ giám sát bạn.\n\nVui lòng bấm nút 'BÁO TÔI AN TOÀN' ít nhất mỗi 2 tiếng.\nNếu không, hệ thống sẽ gửi CẢNH BÁO KHẨN CẤP đến Admin."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Đã hiểu",
                style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text("Cài đặt"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: ListView(
        children: [
          // --- CÁC MỤC CÀI ĐẶT CŨ ---
          SwitchListTile(
            title: const Text("Nhận thông báo"),
            subtitle: const Text("Nhận tin tức, nhắc lịch khám"),
            value: _notiEnabled,
            onChanged: (val) => setState(() => _notiEnabled = val),
            activeColor: Colors.blue,
          ),
          const Divider(),
          SwitchListTile(
            title: const Text("Đăng nhập bằng vân tay/FaceID"),
            value: _faceIdEnabled,
            onChanged: (val) => setState(() => _faceIdEnabled = val),
            activeColor: Colors.blue,
          ),
          const Divider(),

          // --- PHẦN CHẾ ĐỘ AN TOÀN (MỚI) ---
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            color: _safeTourMode
                ? const Color(0xFFFFF3E0)
                : const Color(0xFFF9FAFB),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Icon(Icons.security,
                      color: _safeTourMode ? Colors.red : Colors.grey),
                  title: Text(
                    "Chế độ An toàn (Tour/Trekking)",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _safeTourMode ? Colors.red : Colors.black87,
                    ),
                  ),
                  subtitle:
                      const Text("Cảnh báo SOS nếu không phản hồi sau 2h"),
                  value: _safeTourMode,
                  onChanged: _toggleSafeMode, // Đã fix lỗi kiểu dữ liệu ở đây
                  activeColor: Colors.red,
                ),

                // Chỉ hiện nút Check-in khi chế độ đang bật
                if (_safeTourMode) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _sendSafeSignal,
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text("BÁO TÔI AN TOÀN (CHECK-IN)"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Text(
                      "Lần cập nhật cuối: $_lastCheckInTime",
                      style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic),
                    ),
                  ),
                ]
              ],
            ),
          ),
          const Divider(),

          // --- CÁC MỤC KHÁC ---
          ListTile(
            title: const Text("Ngôn ngữ"),
            subtitle: const Text("Tiếng Việt"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            title: const Text("Phiên bản ứng dụng"),
            subtitle: const Text("v1.0.0"),
          ),
        ],
      ),
    );
  }
}
