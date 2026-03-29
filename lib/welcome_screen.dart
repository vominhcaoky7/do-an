// Folder: lib
// File path: lib/welcome_screen.dart
// File name: welcome_screen.dart
// Class: WelcomeScreen
// Label: A - Welcome-Modern-UI

import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  // Định nghĩa màu sắc chủ đạo
  final Color primaryBlue = const Color(0xFF1E88E5); // Xanh dương đậm đà hơn
  final Color lightBlue = const Color(0xFFE3F2FD); // Xanh nền rất nhạt

  @override
  Widget build(BuildContext context) {
    // Lấy kích thước màn hình để căn chỉnh responsive
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // 1. Nền Gradient nhẹ nhàng
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFF0F8FF), // Alice Blue
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // 2. Logo Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/hutech_logo.png',
                      height: 40,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.local_hospital_rounded,
                        size: 40,
                        color: primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "HUTECH CLINIC",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: size.height * 0.05), // Khoảng cách động

                // 3. Ảnh minh họa (Hero Image) với hiệu ứng đổ bóng
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle, // Hình nền tròn phía sau ảnh
                    boxShadow: [
                      BoxShadow(
                        color: primaryBlue.withOpacity(0.15),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Image.asset(
                        'assets/images/doctor.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.medical_services_outlined,
                          size: 100,
                          color: primaryBlue.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: size.height * 0.05),

                // 4. Tiêu đề & Mô tả
                Text(
                  "Chăm sóc sức khỏe\ntoàn diện",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                    color: Colors.blueGrey[900],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Đặt lịch khám nhanh chóng, theo dõi\nhồ sơ sức khỏe mọi lúc mọi nơi.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.blueGrey[600],
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 40),

                // 5. Dots Indicator (Trang trí)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildDot(isActive: true),
                    _buildDot(isActive: false),
                    _buildDot(isActive: false),
                  ],
                ),

                const SizedBox(height: 40),

                // 6. Các nút bấm (Buttons)
                // Nút Đăng nhập (Nổi bật)
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 8,
                      shadowColor: primaryBlue.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Đăng nhập",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Nút Đăng ký (Viền)
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RegisterScreen()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: primaryBlue, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      "Tạo tài khoản mới",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget con để vẽ các chấm tròn trang trí
  Widget _buildDot({required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? primaryBlue : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
