import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HealthTrackingScreen extends StatefulWidget {
  const HealthTrackingScreen({super.key});

  @override
  State<HealthTrackingScreen> createState() => _HealthTrackingScreenState();
}

class _HealthTrackingScreenState extends State<HealthTrackingScreen> {
  final TextEditingController _sysCtrl = TextEditingController();
  final TextEditingController _diaCtrl = TextEditingController();

  // Dữ liệu mẫu: List các bản ghi {date, sys, dia}
  List<Map<String, dynamic>> records = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> data = prefs.getStringList('bp_records') ?? [];
    setState(() {
      records = data.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
    });
  }

  Future<void> _addRecord() async {
    final sys = int.tryParse(_sysCtrl.text);
    final dia = int.tryParse(_diaCtrl.text);

    if (sys == null || dia == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập số hợp lệ")),
      );
      return;
    }

    final newRecord = {
      'date': DateTime.now().toIso8601String(),
      'sys': sys,
      'dia': dia,
    };

    setState(() {
      records.insert(0, newRecord); // Thêm vào đầu danh sách
    });

    // Lưu vào máy
    final prefs = await SharedPreferences.getInstance();
    final List<String> data = records.map((e) => jsonEncode(e)).toList();
    await prefs.setStringList('bp_records', data);

    _sysCtrl.clear();
    _diaCtrl.clear();
    FocusScope.of(context).unfocus(); // Ẩn bàn phím
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F5), // Nền hồng nhạt
      appBar: AppBar(
        title: const Text("Theo dõi sức khoẻ",
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.redAccent)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.redAccent),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. CARD NHẬP LIỆU
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.red.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5)),
                ],
              ),
              child: Column(
                children: [
                  const Text("NHẬP CHỈ SỐ HUYẾT ÁP",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputBox(_sysCtrl, "Tâm thu (SYS)",
                            Icons.arrow_upward, Colors.red),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildInputBox(_diaCtrl, "Tâm trương (DIA)",
                            Icons.arrow_downward, Colors.blue),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _addRecord,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 5,
                        shadowColor: Colors.redAccent.withOpacity(0.4),
                      ),
                      icon: const Icon(Icons.add_circle_outline,
                          color: Colors.white),
                      label: const Text("THÊM MỚI",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 2. BIỂU ĐỒ (CHART)
            if (records.isNotEmpty) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Biểu đồ theo dõi (7 lần gần nhất)",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 15),
              Container(
                height: 250,
                padding: const EdgeInsets.fromLTRB(10, 20, 20, 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: LineChart(
                  _buildChartData(),
                ),
              ),
            ] else ...[
              // Empty State cho Chart
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.show_chart, size: 60, color: Colors.grey[300]),
                    const SizedBox(height: 10),
                    Text("Chưa có dữ liệu biểu đồ",
                        style: TextStyle(color: Colors.grey[500])),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 30),

            // 3. DANH SÁCH LỊCH SỬ
            if (records.isNotEmpty) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Lịch sử đo",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 10),
              ...records.map((item) => _buildHistoryItem(item)).toList(),
            ],
          ],
        ),
      ),
    );
  }

  // Widget ô nhập liệu nhỏ
  Widget _buildInputBox(
      TextEditingController ctrl, String label, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: color, fontSize: 18),
            decoration: InputDecoration(
              border: InputBorder.none,
              icon: Icon(icon, color: color, size: 20),
              hintText: "000",
              hintStyle: TextStyle(color: color.withOpacity(0.3)),
            ),
          ),
        ),
      ],
    );
  }

  // Widget item lịch sử
  Widget _buildHistoryItem(Map<String, dynamic> item) {
    final date = DateTime.parse(item['date']);
    final dateStr = DateFormat('dd/MM HH:mm').format(date);
    final sys = item['sys'];
    final dia = item['dia'];

    // Đánh giá sơ bộ (Tham khảo)
    String status = "Bình thường";
    Color statusColor = Colors.green;
    if (sys >= 140 || dia >= 90) {
      status = "Cao";
      statusColor = Colors.red;
    } else if (sys < 90 || dia < 60) {
      status = "Thấp";
      statusColor = Colors.orange;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(dateStr,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                          color: statusColor, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text(status,
                      style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                ],
              )
            ],
          ),
          Row(
            children: [
              _buildValueBadge("$sys", "SYS", Colors.red),
              const SizedBox(width: 10),
              _buildValueBadge("$dia", "DIA", Colors.blue),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildValueBadge(String val, String label, Color color) {
    return Column(
      children: [
        Text(val,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 18, color: color)),
        Text(label,
            style: TextStyle(fontSize: 10, color: color.withOpacity(0.6))),
      ],
    );
  }

  // Cấu hình biểu đồ
  LineChartData _buildChartData() {
    // Lấy tối đa 7 bản ghi gần nhất, đảo ngược để cũ bên trái, mới bên phải
    final data = records.take(7).toList().reversed.toList();

    return LineChartData(
      gridData: FlGridData(show: true, drawVerticalLine: false),
      titlesData: FlTitlesData(show: false), // Ẩn bớt title cho gọn
      borderData: FlBorderData(show: false),
      lineBarsData: [
        // Đường Tâm thu (Đỏ)
        LineChartBarData(
          spots: data
              .asMap()
              .entries
              .map((e) => FlSpot(e.key.toDouble(), e.value['sys'].toDouble()))
              .toList(),
          isCurved: true,
          color: Colors.redAccent,
          barWidth: 3,
          dotData: FlDotData(show: true),
          belowBarData:
              BarAreaData(show: true, color: Colors.redAccent.withOpacity(0.1)),
        ),
        // Đường Tâm trương (Xanh)
        LineChartBarData(
          spots: data
              .asMap()
              .entries
              .map((e) => FlSpot(e.key.toDouble(), e.value['dia'].toDouble()))
              .toList(),
          isCurved: true,
          color: Colors.blueAccent,
          barWidth: 3,
          dotData: FlDotData(show: true),
        ),
      ],
    );
  }
}
