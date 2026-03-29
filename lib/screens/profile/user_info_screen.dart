import 'package:flutter/material.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final _nameCtrl = TextEditingController(text: "Nguyễn Văn A");
  final _emailCtrl = TextEditingController(text: "nguyenvana@gmail.com");
  final _phoneCtrl = TextEditingController(text: "0909123456");
  bool isEditing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thông tin cá nhân"),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              if (isEditing) {
                // Lưu thông tin (Giả lập)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Đã cập nhật thông tin thành công!")),
                );
              }
              setState(() => isEditing = !isEditing);
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage:
                  AssetImage("assets/images/doctor.png"), // Ảnh demo
            ),
            const SizedBox(height: 30),
            _buildTextField("Họ và tên", _nameCtrl, Icons.person),
            const SizedBox(height: 15),
            _buildTextField("Email", _emailCtrl, Icons.email),
            const SizedBox(height: 15),
            _buildTextField("Số điện thoại", _phoneCtrl, Icons.phone,
                isNumber: true),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController ctrl, IconData icon,
      {bool isNumber = false}) {
    return TextField(
      controller: ctrl,
      enabled: isEditing, // Chỉ cho nhập khi đang ở chế độ sửa
      keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        filled: !isEditing,
        fillColor: Colors.grey[100],
      ),
    );
  }
}
