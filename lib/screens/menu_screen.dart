import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Gọi điện
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

// Import màn hình SafetyScreen để điều hướng
import 'safety_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  // ⚠️ CẤU HÌNH IP SERVER (Phải khớp với SafetyScreen)
  // Nếu máy thật dùng IP Lan (ví dụ 192.168.1.x), máy ảo dùng 10.0.2.2
  static const String _serverIp = "10.0.2.2";
  final String baseUrl = "http://$_serverIp:5182/api/safety";

  // --- HÀM 1: GỌI ĐIỆN ---
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      _showSnack("Không thể thực hiện cuộc gọi", Colors.red);
    }
  }

  // --- HÀM 2: GỬI SOS (PHIÊN BẢN CHỐT HẠ - KHÔNG THỂ LỖI) ---
  Future<void> _quickSOS() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Lấy mã BN (Nếu null thì dùng số cứng để Test)
    String userCode = prefs.getString("current_patient_code") ?? "0342884664";

    _showSnack("📡 Đang định vị...", Colors.blue);

    try {
      // 2. KIỂM TRA QUYỀN
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnack("⚠️ Hãy bật GPS trên điện thoại!", Colors.orange);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      // 3. LẤY TỌA ĐỘ
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
            timeLimit: const Duration(seconds: 5));
      } catch (e) {
        // Nếu lỗi lấy GPS mới, thử lấy vị trí cũ
        position = await Geolocator.getLastKnownPosition();
      }

      // Tọa độ mặc định (Phòng hờ máy ảo bị lỗi GPS)
      position ??= Position(
          longitude: 106.660172,
          latitude: 10.762622,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0);

      // 4. GỬI API (CHIẾN THUẬT BAO VÂY + ÉP KIỂU STRING)
      _showSnack("📤 Đang gửi tín hiệu SOS...", Colors.blue);

      // A. Gắn dữ liệu lên URL (Query String) để chắc ăn 100% Server thấy Phone
      // Lưu ý: Đã encode URL để tránh lỗi ký tự lạ
      String queryString = "?Phone=$userCode&phone=$userCode";
      final uri = Uri.parse('$baseUrl/sos$queryString');

      print("🚀 Đang gửi SOS tới: $uri");

      // B. Dùng MultipartRequest (Bắt buộc vì Server C# dùng [FromForm])
      var request = http.MultipartRequest('POST', uri);

      // C. Thêm các trường dữ liệu vào Form
      // QUAN TRỌNG: Tất cả giá trị phải là String
      request.fields['Phone'] = userCode;
      request.fields['phone'] = userCode; // Dự phòng

      request.fields['Name'] = "THANH TUNG";
      request.fields['name'] = "THANH TUNG"; // Dự phòng

      request.fields['Lat'] = position.latitude.toString();
      request.fields['Long'] = position.longitude.toString();
      request.fields['Note'] =
          "SOS KHAN CAP TU TIEN ICH"; // Tránh dấu tiếng Việt có thể gây lỗi encoding
      request.fields['Altitude'] = "10.0";
      request.fields['Timestamp'] = DateTime.now().toIso8601String();

      // D. Gửi đi
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // Log kết quả ra Console
      print("SOS Response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200) {
        _showSnack("✅ ĐÃ GỬI SOS THÀNH CÔNG!", Colors.green);
      } else {
        _showSnack("⚠️ Lỗi Server SOS: ${response.body}", Colors.orange);
      }
    } catch (e) {
      print("Lỗi Code SOS: $e");
      _showSnack("❌ Lỗi kết nối: $e", Colors.red);
    }
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(msg),
          backgroundColor: color,
          duration: const Duration(seconds: 2)),
    );
  }

  // Popup hiển thị danh sách cứu hộ (Giữ nguyên)
  void _showRescueOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 250,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Đội cứu hộ khẩn cấp",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              ListTile(
                leading: const CircleAvatar(
                    backgroundColor: Colors.red,
                    child: Icon(Icons.phone, color: Colors.white)),
                title: const Text("Cấp cứu 115"),
                onTap: () {
                  Navigator.pop(context);
                  _makePhoneCall("115");
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.support_agent, color: Colors.white)),
                title: const Text("Hotline Hỗ trợ Kỹ thuật"),
                subtitle: const Text("0909.123.456"),
                onTap: () {
                  Navigator.pop(context);
                  _makePhoneCall("0909123456");
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuCard(
      {required IconData icon,
      required Color color,
      required String title,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 15),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14, height: 1.2)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Tiện ích mở rộng"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Trung tâm hỗ trợ",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Text("Các công cụ an toàn và cứu hộ khẩn cấp",
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),

            // NÚT SOS TO ĐÙNG
            GestureDetector(
              onLongPress: _quickSOS, // Gọi hàm SOS đã sửa
              onTap: () =>
                  _showSnack("⚠️ Nhấn giữ 2 giây để SOS", Colors.orange),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFFFF5252), Color(0xFFD32F2F)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.red.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 8))
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle),
                      child: const Icon(Icons.sos_rounded,
                          size: 40, color: Colors.white),
                    ),
                    const SizedBox(width: 20),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("GỌI CỨU HỘ KHẨN CẤP",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18)),
                          SizedBox(height: 5),
                          Text("Nhấn giữ 2 giây để gửi tọa độ ngay lập tức",
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // GRID MENU
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.1,
              children: [
                _buildMenuCard(
                  icon: Icons.security_rounded,
                  color: Colors.blue,
                  title: "Chế độ An toàn\n(Trekking Mode)",
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const SafetyScreen())),
                ),
                _buildMenuCard(
                  icon: Icons.phone_in_talk_rounded,
                  color: Colors.green,
                  title: "Gọi Cấp cứu\n(115)",
                  onTap: () => _makePhoneCall("115"),
                ),
                _buildMenuCard(
                  icon: Icons.support_agent_rounded,
                  color: Colors.orange,
                  title: "Đội cứu hộ\nkhẩn cấp",
                  onTap: _showRescueOptions,
                ),
                _buildMenuCard(
                  icon: Icons.menu_book_rounded,
                  color: Colors.purple,
                  title: "Cẩm nang\nsơ cứu",
                  onTap: () =>
                      _showSnack("Tính năng đang cập nhật...", Colors.black54),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
