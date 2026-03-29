import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vaccination.dart';
import '../services/vaccination_service.dart';

class VaccinationScreen extends StatefulWidget {
  const VaccinationScreen({super.key});

  @override
  State<VaccinationScreen> createState() => _VaccinationScreenState();
}

class _VaccinationScreenState extends State<VaccinationScreen> {
  late Future<List<Vaccination>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _future = _loadData();
    });
  }

  Future<List<Vaccination>> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final patientCode =
        prefs.getString('current_patient_code')?.trim().toUpperCase();
    final token = prefs.getString('token');

    if (patientCode == null || patientCode.isEmpty) {
      throw Exception('NO_PATIENT_CODE');
    }

    if (token == null || token.isEmpty) {
      throw Exception('NO_TOKEN');
    }

    return VaccinationService().getByPatient(patientCode, token);
  }

  // ================= ĐẶT LỊCH TIÊM =================
  Future<void> _bookVaccination() async {
    final prefs = await SharedPreferences.getInstance();
    final patientCode =
        prefs.getString('current_patient_code')?.trim().toUpperCase();
    final token = prefs.getString('token');

    if (patientCode == null || patientCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                '⚠ Không tìm thấy mã bệnh nhân. Vui lòng vào Hồ sơ trước.')),
      );
      return;
    }

    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('⚠ Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.')),
      );
      return;
    }

    final vaccineCtrl = TextEditingController();
    final doseCtrl = TextEditingController(text: "1");
    DateTime? pickedDate;

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("📅 Đặt lịch tiêm"),
          content: StatefulBuilder(
            builder: (ctx, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: vaccineCtrl,
                    decoration: const InputDecoration(
                        labelText: "Tên vaccine (ví dụ: COVID-19)"),
                  ),
                  TextField(
                    controller: doseCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Mũi số"),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    title: Text(
                      pickedDate == null
                          ? "Chọn ngày tiêm dự kiến"
                          : "Ngày tiêm: ${pickedDate!.toLocal().toString().split(' ')[0]}",
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final d = await showDatePicker(
                        context: ctx,
                        initialDate:
                            DateTime.now().add(const Duration(days: 7)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (d != null) {
                        setModalState(() => pickedDate = d);
                      }
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx), child: const Text("Huỷ")),
            ElevatedButton(
              onPressed: () async {
                // Validate
                if (vaccineCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng nhập tên vaccine')),
                  );
                  return;
                }
                if (pickedDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng chọn ngày tiêm')),
                  );
                  return;
                }

                // Đóng dialog trước khi gọi API
                Navigator.pop(ctx);

                // Hiển thị loading
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đang đặt lịch...')),
                );

                try {
                  await VaccinationService().createVaccination(
                    patientCode: patientCode,
                    vaccineName: vaccineCtrl.text.trim(),
                    doseNumber: int.tryParse(doseCtrl.text.trim()) ?? 1,
                    nextDueDate: pickedDate!,
                    token: token,
                    note: "Đặt lịch tiêm",
                  );

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('✅ Đặt lịch tiêm thành công!')),
                    );
                    _reload(); // Reload danh sách
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('❌ Đặt lịch thất bại\n${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text("ĐẶT LỊCH"),
            ),
          ],
        );
      },
    );
  }

  // ================= STATUS =================
  Color _statusColor(String status) {
    switch (status) {
      case 'DaTiem':
        return Colors.green;
      case 'SapDenHan':
        return Colors.orange;
      case 'ChuaTiem':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  String _statusText(String status) {
    switch (status) {
      case 'DaTiem':
        return 'Đã tiêm';
      case 'SapDenHan':
        return 'Sắp đến hạn';
      case 'ChuaTiem':
        return 'Chưa tiêm';
      default:
        return status;
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💉 Tiêm chủng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "Đặt lịch tiêm",
            onPressed: _bookVaccination,
          )
        ],
      ),
      body: FutureBuilder<List<Vaccination>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            final msg = snapshot.error.toString();

            if (msg.contains('NO_PATIENT_CODE')) {
              return const Center(
                child: Text(
                  'Chưa có mã bệnh nhân.\nVui lòng vào Hồ sơ sức khoẻ trước.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            if (msg.contains('NO_TOKEN')) {
              return const Center(
                child: Text(
                  'Chưa đăng nhập.\nVui lòng đăng nhập lại.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Lỗi: $msg'),
              ),
            );
          }

          final items = snapshot.data!;
          if (items.isEmpty) {
            return const Center(child: Text('Chưa có lịch tiêm nào'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final v = items[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Icon(
                    Icons.vaccines,
                    color: _statusColor(v.status),
                    size: 40,
                  ),
                  title: Text(
                    '${v.vaccineName} – Mũi ${v.doseNumber}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Trạng thái: ${_statusText(v.status)}'),
                      if (v.nextDueDate != null)
                        Text(
                            'Ngày hẹn: ${v.nextDueDate!.toLocal().toString().split(' ')[0]}'),
                      if (v.note != null && v.note!.isNotEmpty)
                        Text('Ghi chú: ${v.note}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
