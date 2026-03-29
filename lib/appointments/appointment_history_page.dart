import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'appointment_history_model.dart';

class AppointmentHistoryPage extends StatefulWidget {
  final String patientCode;
  final bool forceLocalMode;
  final AppointmentHistory? localNewAppointment;

  const AppointmentHistoryPage({
    super.key,
    required this.patientCode,
    this.forceLocalMode = false,
    this.localNewAppointment,
  });

  @override
  State<AppointmentHistoryPage> createState() => _AppointmentHistoryPageState();
}

class _AppointmentHistoryPageState extends State<AppointmentHistoryPage> {
  List<AppointmentHistory> _appointmentHistory = [];

  @override
  void initState() {
    super.initState();
    _loadFromLocal().then((_) {
      if (widget.localNewAppointment != null && mounted) {
        setState(() {
          _appointmentHistory.insert(0, widget.localNewAppointment!);
        });
      }
    });
  }

  Future<void> _loadFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList =
        prefs.getStringList('local_appointment_history') ?? [];

    final List<AppointmentHistory> list = jsonList
        .map((jsonStr) => AppointmentHistory.fromJson(jsonDecode(jsonStr)))
        .toList()
        .reversed
        .toList();

    if (mounted) {
      setState(() {
        _appointmentHistory = list;
      });
    }
  }

  Future<void> _refresh() async => await _loadFromLocal();

  // TỰ ĐỘNG KIỂM TRA ĐÃ KHÁM XONG CHƯA
  String _getDisplayStatus(AppointmentHistory item) {
    try {
      final endTimeStr = item.slot.split('-')[1].trim();
      final endHour = int.parse(endTimeStr.split(':')[0]);
      final endMinute = int.parse(endTimeStr.split(':')[1].split(' ')[0]);
      final endDateTime =
          item.date.add(Duration(hours: endHour, minutes: endMinute));

      if (DateTime.now().isAfter(endDateTime)) {
        return "Đã khám";
      }
    } catch (e) {
      // Nếu lỗi parse → giữ nguyên status cũ
    }
    return item.status;
  }

  Color _getStatusColor(String status) {
    if (status == "Đã khám") return Colors.grey.shade600;
    if (status.contains('hủy')) return Colors.redAccent;
    if (status.contains('hoàn thành')) return Colors.green;
    return Colors.orange.shade700;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử đặt khám'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _appointmentHistory.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 200),
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.history_toggle_off,
                            size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Chưa có lịch sử đặt khám',
                          style: TextStyle(fontSize: 17, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _appointmentHistory.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = _appointmentHistory[index];
                  final displayStatus = _getDisplayStatus(item);

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7E6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orange.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon trạng thái
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.orange.shade100,
                          ),
                          child: Icon(
                            displayStatus == "Đã khám"
                                ? Icons.check_circle
                                : Icons.access_time,
                            color: displayStatus == "Đã khám"
                                ? Colors.grey.shade600
                                : Colors.orange.shade700,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Nội dung chính – ĐÃ FIX 100% KHÔNG TRÀN MÀN HÌNH
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // TÊN BÁC SĨ – KHÔNG TRÀN NỮA
                              Text(
                                item.doctorName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                softWrap: true,
                              ),
                              const SizedBox(height: 4),

                              // CHUYÊN KHOA – KHÔNG TRÀN NỮA
                              Text(
                                "Khám ${item.specialty}",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey.shade700),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                softWrap: true,
                              ),
                              const SizedBox(height: 10),

                              // NGÀY
                              Row(
                                children: [
                                  Icon(Icons.calendar_today,
                                      size: 16, color: Colors.grey.shade600),
                                  const SizedBox(width: 6),
                                  Text(
                                    DateFormat('dd/MM/yyyy').format(item.date),
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),

                              // GIỜ
                              Row(
                                children: [
                                  Icon(Icons.access_time,
                                      size: 16, color: Colors.grey.shade600),
                                  const SizedBox(width: 6),
                                  Text(
                                    item.slot,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),

                              // ĐỊA ĐIỂM
                              Row(
                                children: [
                                  Icon(Icons.location_on,
                                      size: 16, color: Colors.grey.shade600),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      item.clinicName,
                                      style: const TextStyle(fontSize: 13),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              // TRẠNG THÁI + THÔNG TIN THÊM
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(displayStatus)
                                          .withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      displayStatus,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: _getStatusColor(displayStatus),
                                      ),
                                    ),
                                  ),
                                  if (displayStatus == "Sắp khám")
                                    Text(
                                      "Còn ${item.date.difference(DateTime.now()).inDays.abs() + 1} ngày",
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
