import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- APPOINTMENT FLOW ---
import '../appointments/booking_start.dart';
import '../appointments/select_profile_page.dart';
import '../appointments/appointment_history_page.dart';

// --- FEATURES ---
import '../features/pay_fee_page.dart';
import '../features/payment_history_page.dart';

// --- HEALTH SCREENS ---
import '../screens/health_record_screen.dart';
import '../screens/health_tracking_screen.dart';
import '../screens/vaccination_screen.dart';
import '../screens/community_screen.dart';
import '../screens/hospital_admission_screen.dart';
import '../screens/support_screen.dart';
import '../screens/notification_screen.dart';
import '../screens/user_profile_screen.dart';

// --- SAFETY & MENU ---
import '../screens/safety_screen.dart'; // Import màn hình An toàn
import '../screens/menu_screen.dart'; // Import màn hình Menu mở rộng

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Màu chủ đạo
  final Color primaryColor = const Color(0xFF1E88E5);
  final Color bgColor = const Color(0xFFF5F7FA);

  // Danh sách màn hình cho Bottom Navigation Bar
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeTab(), // 0. Trang chủ (Chứa Grid Menu)
      const NotificationScreen(), // 1. Thông báo
      const UserProfileScreen(), // 2. Cá nhân
      const MenuScreen(), // 3. Menu Tiện ích (Đã thay thế Text cũ)
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, -5)),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.grey[400],
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          onTap: (i) => setState(() => _selectedIndex = i),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded), label: "Trang chủ"),
            BottomNavigationBarItem(
                icon: Icon(Icons.notifications_rounded), label: "Thông báo"),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded), label: "Cá nhân"),
            BottomNavigationBarItem(
                icon: Icon(Icons.grid_view_rounded), label: "Menu"),
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// WIDGET TRANG CHỦ RIÊNG BIỆT (HomeTab)
// =========================================================================
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  // Dữ liệu Menu (Grid chính)
  final List<Map<String, dynamic>> menuItems = [
    // --- CÁC MỤC CŨ ---
    {
      'icon': Icons.calendar_month_rounded,
      'title': 'Đặt khám',
      'color': Color(0xFF448AFF)
    },
    {
      'icon': Icons.history_rounded,
      'title': 'Lịch sử khám',
      'color': Color(0xFFFF9800)
    },
    {
      'icon': Icons.payments_rounded,
      'title': 'Thanh toán',
      'color': Color(0xFF9C27B0)
    },
    {
      'icon': Icons.receipt_long_rounded,
      'title': 'Hoá đơn',
      'color': Color(0xFF3F51B5)
    },
    {
      'icon': Icons.medical_services_rounded,
      'title': 'Hồ sơ SK',
      'color': Color(0xFF4CAF50)
    },
    {
      'icon': Icons.monitor_heart_rounded,
      'title': 'Theo dõi SK',
      'color': Color(0xFFE91E63)
    },
    {
      'icon': Icons.vaccines_rounded,
      'title': 'Tiêm chủng',
      'color': Color(0xFF009688)
    },
    {
      'icon': Icons.groups_rounded,
      'title': 'Cộng đồng',
      'color': Color(0xFFE91E63)
    },
    {
      'icon': Icons.local_hospital_rounded,
      'title': 'Nhập viện',
      'color': Color(0xFFF44336)
    },

    // --- MỤC MỚI THÊM VÀO ---
    {
      'icon': Icons.security_rounded,
      'title': 'An toàn & SOS',
      'color': Colors.redAccent // Màu đỏ nổi bật
    },

    {
      'icon': Icons.support_agent_rounded,
      'title': 'Hỗ trợ',
      'color': Color(0xFF607D8B)
    },
  ];

  void _showEnterPatientCodeDialog() {
    final codeCtrl = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text("Nhập mã bệnh nhân"),
          content: TextField(
            controller: codeCtrl,
            decoration: InputDecoration(
              labelText: "Mã bệnh nhân (VD: BN000123)",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx), child: const Text("HỦY")),
            ElevatedButton(
              onPressed: () async {
                final code = codeCtrl.text.trim().toUpperCase();
                if (code.isEmpty) return;
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString("current_patient_code", code);
                Navigator.pop(ctx);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => HealthRecordScreen(patientCode: code)));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text("XÁC NHẬN"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openHealthRecordFromMenu() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString("current_patient_code");
    if (code == null || code.isEmpty) {
      _showEnterPatientCodeDialog();
      return;
    }
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => HealthRecordScreen(patientCode: code)));
  }

  void _onMenuTap(String title) async {
    switch (title) {
      case 'Đặt khám':
        final prefs = await SharedPreferences.getInstance();
        final raw = prefs.getString("profiles");
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => raw != null && raw.isNotEmpty
                    ? const SelectProfilePage()
                    : const BookingStart()));
        break;
      case 'Lịch sử khám':
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => AppointmentHistoryPage(
                    patientCode: "LOCAL", forceLocalMode: true)));
        break;
      case 'Thanh toán':
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const PayFeePage()));
        break;
      case 'Hoá đơn':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const PaymentHistoryPage()));
        break;
      case 'Hồ sơ SK':
        _openHealthRecordFromMenu();
        break;
      case 'Theo dõi SK':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const HealthTrackingScreen()));
        break;
      case 'Tiêm chủng':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const VaccinationScreen()));
        break;
      case 'Cộng đồng':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const CommunityScreen()));
        break;
      case 'Nhập viện':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const HospitalAdmissionScreen()));
        break;

      // --- XỬ LÝ NÚT AN TOÀN ---
      case 'An toàn & SOS':
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const SafetyScreen()));
        break;

      case 'Hỗ trợ':
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const SupportScreen()));
        break;
      default:
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("$title đang cập nhật...")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          // 1. CUSTOM HEADER
          _buildHeader(),

          // 2. BODY CONTENT
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner quảng cáo
                  _buildPromoBanner(),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    child: Text(
                      "Dịch vụ tiện ích",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                  ),

                  // Grid Menu
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: menuItems.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.9,
                      ),
                      itemBuilder: (_, i) => _buildModernMenuCard(menuItems[i]),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 25),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Xin chào,",
                      style: TextStyle(color: Colors.white70, fontSize: 16)),
                  SizedBox(height: 4),
                  Text("Trần Tùng Minh",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                child: const CircleAvatar(
                  radius: 24,
                  backgroundImage: AssetImage("assets/images/hutech_logo.png"),
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.blue),
                ),
              )
            ],
          ),
          const SizedBox(height: 20),
          // Fake Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: const [
                Icon(Icons.search, color: Colors.white70),
                SizedBox(width: 10),
                Text("Tìm kiếm bác sĩ, chuyên khoa...",
                    style: TextStyle(color: Colors.white70)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFFFF8A65), Color(0xFFFF5722)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.orange.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Khám tổng quát",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
                SizedBox(height: 5),
                Text("Giảm ngay 20% cho thành viên mới",
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: const Text("Đặt ngay",
                style: TextStyle(
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
          )
        ],
      ),
    );
  }

  Widget _buildModernMenuCard(Map<String, dynamic> item) {
    return InkWell(
      onTap: () => _onMenuTap(item['title']),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (item['color'] as Color).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(item['icon'], size: 28, color: item['color']),
            ),
            const SizedBox(height: 10),
            Text(
              item['title'],
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
