// lib/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart'; // ← Quay về đây sau khi đăng ký

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _isObscure = true;
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final contact = _contactController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || contact.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Vui lòng điền đầy đủ thông tin!"),
            backgroundColor: Colors.red),
      );
      return;
    }

    // LƯU THÔNG TIN ĐĂNG KÝ
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    await prefs.setString('user_contact', contact);
    await prefs.setString('user_password', password);

    // HIỆN THÔNG BÁO THÀNH CÔNG + QUAY VỀ MÀN HÌNH ĐĂNG NHẬP
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Đăng ký thành công! Vui lòng đăng nhập"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    // Quay về màn hình đăng nhập
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color darkBlue = Color(0xFF0056D2);
    const Color lightBlue = Color(0xFF00B0FF);

    return Scaffold(
      backgroundColor: darkBlue,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Image.asset(
                  'assets/images/hutech_logo.png',
                  height: 80,
                  errorBuilder: (_, __, ___) => const Icon(Icons.local_hospital,
                      size: 80, color: Colors.white),
                ),
                const SizedBox(height: 16),
                const Text("Tạo tài khoản mới",
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const Text("Điền thông tin để bắt đầu sử dụng ứng dụng",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.white70)),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 16,
                          offset: const Offset(0, 8))
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                            labelText: "Họ và tên",
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Colors.grey[50]),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _contactController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                            labelText: "Số điện thoại",
                            prefixIcon: const Icon(Icons.phone),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Colors.grey[50]),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: _isObscure,
                        decoration: InputDecoration(
                            labelText: "Mật khẩu",
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_isObscure
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: () =>
                                  setState(() => _isObscure = !_isObscure),
                            ),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Colors.grey[50]),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _register,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12))),
                          child: const Text("ĐĂNG KÝ NGAY",
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Đã có tài khoản? ",
                              style: TextStyle(color: Colors.grey)),
                          GestureDetector(
                            onTap: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const LoginScreen())),
                            child: const Text("Đăng nhập",
                                style: TextStyle(
                                    color: lightBlue,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
