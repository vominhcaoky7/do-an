// Folder: lib/appointments
// File: select_slot.dart
// FINAL FIX – Không lỗi Null, Regex tách giờ an toàn 100%, API chuẩn ASP.NET Core

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SelectSlotPage extends StatefulWidget {
  final int doctorId;
  final int departmentId;
  final DateTime date;

  const SelectSlotPage({
    super.key,
    required this.doctorId,
    required this.departmentId,
    required this.date,
  });

  @override
  State<SelectSlotPage> createState() => _SelectSlotPageState();
}

class _SelectSlotPageState extends State<SelectSlotPage> {
  List<dynamic> slots = [];
  bool isLoading = true;
  int selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    loadSlots();
  }

  Future<void> loadSlots() async {
    final dateStr = widget.date.toIso8601String().split('T').first;
    final url = Uri.parse(
      "http://10.0.2.2:5182/api/AppointmentApi/GetSlots?doctorId=${widget.doctorId}&date=$dateStr",
    );

    print("CALL API: $url");

    try {
      final response = await http.get(url);

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List) {
          slots = data;
        }
      } else {
        _showMessage("Lỗi server: ${response.statusCode}");
      }
    } catch (e) {
      _showMessage("Không thể tải slot: $e");
    }

    if (mounted) setState(() => isLoading = false);
  }

  void _showMessage(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: Colors.red, content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateStr =
        "${widget.date.day}/${widget.date.month}/${widget.date.year}";

    return Scaffold(
      appBar: AppBar(
        title: Text("Chọn giờ khám ($dateStr)"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : slots.isEmpty
              ? const Center(
                  child: Text(
                    "Không có slot trống trong ngày này",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: slots.length,
                  itemBuilder: (context, i) {
                    final s = slots[i];

                    final int slotId = s["id"] is int
                        ? s["id"]
                        : int.tryParse("${s["id"]}") ?? 0;

                    final String timeRange =
                        (s["timeRange"] as String?) ?? "Không xác định";

                    final bool isSelected = selectedIndex == i;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.blue.withOpacity(.12)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              isSelected ? Colors.blue : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.access_time,
                            color: isSelected ? Colors.blue : Colors.grey),
                        title: Text(
                          timeRange,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                        subtitle: Text("Mã slot: $slotId"),
                        trailing: Icon(Icons.chevron_right,
                            color: isSelected ? Colors.blue : Colors.grey),
                        onTap: () {
                          setState(() => selectedIndex = i);

                          // ============================
                          // FIX TUYỆT ĐỐI – TÁCH GIỜ AN TOÀN BẰNG REGEX
                          // ============================

                          final regex = RegExp(r'(\d{2}):(\d{2})');
                          final match = regex.firstMatch(timeRange);

                          if (match == null) {
                            _showMessage("Không đọc được giờ từ: $timeRange");
                            return;
                          }

                          final int startHour = int.parse(match.group(1)!);
                          final int startMinute = int.parse(match.group(2)!);

                          // ============================

                          Future.delayed(const Duration(milliseconds: 150), () {
                            Navigator.pop(context, {
                              "slotId": slotId,
                              "timeRange": timeRange,
                              "startHour": startHour,
                              "startMinute": startMinute,
                            });
                          });
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
