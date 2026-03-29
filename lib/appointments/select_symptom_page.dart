import 'package:flutter/material.dart';

class SelectSymptomPage extends StatefulWidget {
  const SelectSymptomPage({super.key});

  @override
  State<SelectSymptomPage> createState() => _SelectSymptomPageState();
}

class _SelectSymptomPageState extends State<SelectSymptomPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nhập triệu chứng"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Mô tả triệu chứng hiện tại:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Ví dụ: ho, sốt nhẹ, đau họng...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, _controller.text.trim());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Tiếp tục"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
