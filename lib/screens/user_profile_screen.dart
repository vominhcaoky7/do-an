import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- IMPORT CÁC MÀN HÌNH CON ---
import 'profile/user_info_screen.dart';
import 'profile/medical_records_screen.dart';
import 'profile/change_password_screen.dart';
import 'profile/settings_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  // Màu chủ đạo
  final Color primaryColor = const Color(0xFF1E88E5);
  final Color bgColor = const Color(0xFFF5F7FA);

  String? _userCode;
  String _userName = "Khách";

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  // 1. Tải thông tin người dùng từ bộ nhớ
  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userCode = prefs.getString("current_patient_code");
      // Nếu có mã thì hiện tên giả định, không thì hiện "Chưa đăng nhập"
      _userName = _userCode != null ? "Trần Tùng Minh" : "Chưa đăng nhập";
    });
  }

  // 2. Hàm Fake Login (Để FIX LỖI NHANH)
  Future<void> _fakeLogin() async {
    final prefs = await SharedPreferences.getInstance();
    // Lưu cứng mã bệnh nhân để test
    await prefs.setString("current_patient_code", "BN_0342884664");

    _loadUser(); // Load lại giao diện ngay lập tức
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content:
            Text("✅ Đã kích hoạt tài khoản Test! Giờ bạn có thể dùng SOS."),
        backgroundColor: Colors.green,
      ),
    );
  }

  // 3. Hàm Đăng xuất
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("current_patient_code"); // Xóa mã
    await prefs.remove("safety_mode_active"); // Xóa trạng thái an toàn

    setState(() {
      _userCode = null;
      _userName = "Chưa đăng nhập";
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Đã đăng xuất thành công!")),
    );

    // Điều hướng về màn hình Login (nếu có)
    // Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // 1. HEADER PROFILE
            _buildHeader(),

            const SizedBox(height: 20),

            // ⚠️ NÚT FIX LỖI (CHỈ HIỆN KHI CHƯA CÓ MÃ)
            if (_userCode == null)
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _fakeLogin, // <--- BẤM VÀO ĐÂY ĐỂ FIX LỖI
                  icon: const Icon(Icons.login),
                  label: const Text("KÍCH HOẠT TÀI KHOẢN (TEST)"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 2,
                  ),
                ),
              ),

            // 2. CHỈ SỐ SỨC KHỎE (Demo)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildStatCard(
                      "Chiều cao", "170 cm", Icons.height, Colors.blue),
                  const SizedBox(width: 15),
                  _buildStatCard(
                      "Cân nặng", "65 kg", Icons.monitor_weight, Colors.orange),
                  const SizedBox(width: 15),
                  _buildStatCard("Nhóm máu", "A+", Icons.bloodtype, Colors.red),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // 3. MENU TÙY CHỌN
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    context,
                    icon: Icons.person_outline,
                    title: "Thông tin cá nhân",
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const UserInfoScreen()));
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    context,
                    icon: Icons.history_edu,
                    title: "Hồ sơ bệnh án",
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MedicalRecordsScreen()));
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    context,
                    icon: Icons.lock_outline,
                    title: "Đổi mật khẩu",
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ChangePasswordScreen()));
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    context,
                    icon: Icons.settings_outlined,
                    title: "Cài đặt ứng dụng",
                    color: Colors.grey,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SettingsScreen()));
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // 4. NÚT ĐĂNG XUẤT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _logout, // Gọi hàm đăng xuất
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.redAccent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side:
                          BorderSide(color: Colors.redAccent.withOpacity(0.2)),
                    ),
                  ),
                  child: const Text(
                    "Đăng xuất",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- CÁC WIDGET CON ---

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1565C0), primaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
              color: primaryColor.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle),
                child: const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 60, color: Colors.blueGrey),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.edit, color: Colors.blue, size: 18),
                ),
              )
            ],
          ),
          const SizedBox(height: 15),
          Text(_userName, // Dùng biến _userName đã load
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20)),
            child: Text(
              _userCode != null
                  ? "Mã BN: $_userCode"
                  : "Chưa có mã BN", // Hiện mã BN hoặc thông báo
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 10),
            Text(value,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.black87),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Divider(height: 1, color: Color(0xFFF0F0F0)),
    );
  }
}
