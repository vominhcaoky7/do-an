// =========================
// File: main.dart
// Bản FULL FIX – Chuẩn Flutter + Khởi tạo Locale
// =========================

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

// Screens cấp cao
import 'login_screen.dart';
import 'register_screen.dart';

// Appointments
import 'appointments/booking_start.dart';
import 'appointments/create_profile.dart';
import 'appointments/enter_patient_code.dart';
import 'appointments/select_profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // FIX LOCALE FORMAT ERROR
  await initializeDateFormatting('vi_VN', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: "/welcome",
      routes: {
        "/welcome": (context) => const WelcomeScreen(),
        "/login": (context) => const LoginScreen(),
        "/register": (context) => const RegisterScreen(),

        "/home": (context) => const HomeScreen(),

        // Appointments flow
        "/booking_start": (context) => const BookingStart(),
        "/create_profile": (context) => const CreateProfilePage(),
        "/enter_patient_code": (context) => const EnterPatientCode(),
        "/select_profile": (context) => const SelectProfilePage(),
      },
    );
  }
}

// =================== WELCOME SCREEN ===================

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF5F9FF),
              Color(0xFFE0F2F1),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo
                Row(
                  children: [
                    Image.asset(
                      'assets/images/hutech_logo.png',
                      height: 50,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.local_hospital,
                        size: 50,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.local_hospital,
                        size: 80,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'HUTECH Mobile Clinic',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF003566),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ứng dụng hỗ trợ đặt khám, theo dõi sức khoẻ\ncho sinh viên & người bệnh.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "/login");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Đăng nhập",
                          style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "/register");
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Colors.blue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Đăng ký",
                        style: TextStyle(fontSize: 16, color: Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =================== HOME SCREEN ===================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> menuItems = [
    {'icon': Icons.calendar_month, 'title': 'Đặt khám', 'color': Colors.red},
    {
      'icon': Icons.history,
      'title': 'Lịch sử đặt khám',
      'color': Colors.orange
    },
    {
      'icon': Icons.payment,
      'title': 'Thanh toán viện phí',
      'color': Colors.purple
    },
    {
      'icon': Icons.receipt_long,
      'title': 'Hoá đơn điện tử',
      'color': Colors.blue
    },
    {
      'icon': Icons.health_and_safety,
      'title': 'Hồ sơ sức khoẻ',
      'color': Colors.green
    },
    {
      'icon': Icons.monitor_heart,
      'title': 'Theo dõi sức khoẻ',
      'color': Colors.redAccent
    },
    {'icon': Icons.vaccines, 'title': 'Tiêm chủng', 'color': Colors.pink},
    {'icon': Icons.groups, 'title': 'CLB người bệnh', 'color': Colors.teal},
    {
      'icon': Icons.medical_services,
      'title': 'Kết quả CLS',
      'color': Colors.indigo
    },
    {
      'icon': Icons.support_agent,
      'title': 'CSKH',
      'color': Colors.orangeAccent
    },
    {'icon': Icons.support, 'title': 'Hỗ trợ', 'color': Colors.blueGrey},
    {
      'icon': Icons.local_hospital,
      'title': 'Đăng ký nhập viện',
      'color': Colors.red
    },
    {'icon': Icons.smart_toy, 'title': 'Chatbot AI', 'color': Colors.grey},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5F9FF), Color(0xFFE0F2F1)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 22, color: Colors.black),
                      children: [
                        TextSpan(text: 'Chào mừng đến với '),
                        TextSpan(
                          text: 'HUTECH Mobile Clinic',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.5,
                  ),
                  itemCount: menuItems.length,
                  itemBuilder: (context, index) {
                    return _buildMenuCard(menuItems[index]);
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: 'Thông báo'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Cá nhân'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Chức năng'),
        ],
      ),
    );
  }

  Widget _buildMenuCard(Map<String, dynamic> item) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () {
          if (item['title'] == 'Đặt khám') {
            Navigator.pushNamed(context, "/booking_start");
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (item['color'] as Color).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(item['icon'], color: item['color'], size: 24),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item['title'],
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF003566),
                  ),
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
