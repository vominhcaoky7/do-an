import 'package:flutter/material.dart';

class MedicalRecordsScreen extends StatelessWidget {
  const MedicalRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dữ liệu giả lập
    final records = [
      {
        "date": "15/12/2023",
        "doctor": "BS. Lê Văn B",
        "diagnosis": "Viêm họng cấp"
      },
      {
        "date": "10/11/2023",
        "doctor": "BS. Trần Thị C",
        "diagnosis": "Khám tổng quát"
      },
      {
        "date": "05/09/2023",
        "doctor": "BS. Nguyễn Văn A",
        "diagnosis": "Sốt xuất huyết"
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Hồ sơ bệnh án")),
      backgroundColor: Colors.grey[100],
      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: records.length,
        itemBuilder: (context, index) {
          final item = records[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 15),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.description, color: Colors.blue),
              ),
              title: Text(item['diagnosis']!,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Text("Bác sĩ: ${item['doctor']}"),
                  Text("Ngày khám: ${item['date']}"),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward_ios,
                  size: 16, color: Colors.grey),
              onTap: () {
                // Xem chi tiết (có thể mở rộng sau)
              },
            ),
          );
        },
      ),
    );
  }
}
