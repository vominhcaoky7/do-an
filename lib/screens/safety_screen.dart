import 'dart:async'; // Cần để dùng Timer đếm ngược
import 'dart:io'; // Cần để xử lý File
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle; // Để lấy ảnh từ assets
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart'; // Để tạo file ảnh tạm gửi đi

// 👇 Import màn hình gọi video bác sĩ
import 'telemedicine_screen.dart';

class SafetyScreen extends StatefulWidget {
  const SafetyScreen({super.key});

  @override
  State<SafetyScreen> createState() => _SafetyScreenState();
}

class _SafetyScreenState extends State<SafetyScreen> {
  // ⚠️ CẤU HÌNH SERVER
  static const String _serverIp = "10.0.2.2";
  final String baseUrl = "http://$_serverIp:5182/api/safety";

  String? _userCode;
  bool _isTracking = false;
  bool _isLoading = false;
  String _statusText = "Chưa kích hoạt";

  // 1. BIẾN LOẠI XE
  String _selectedVehicle = "MOTO";

  // 2. BIẾN GIẢ LẬP & LOGIC
  double _heartRate = 80.0;
  bool _isMoving = false; // Giả lập cảm biến gia tốc

  // Biến xác định nguyên nhân SOS
  String _triggerReason = "HEART"; // "HEART" hoặc "CRASH"

  Timer? _countdownTimer;
  Timer? _resetModeTimer;
  int _secondsRemaining = 10;
  bool _isCountingDown = false;

  // Biến hiển thị trạng thái giao diện
  String _dangerLevelText = "Bình thường";
  Color _dangerColor = Colors.green;
  int _currentLevel = 0; // Biến lưu cấp độ số (0, 1, 2, 3) để gửi lên Server

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _resetModeTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _userCode = prefs.getString("current_patient_code");
      _isTracking = prefs.getBool("is_tracking") ?? false;
      _statusText = _isTracking ? "Đang được giám sát" : "Chưa kích hoạt";
      _selectedVehicle = prefs.getString("vehicle_type") ?? "MOTO";
    });
  }

  // --- HÀM 1: BẬT/TẮT THEO DÕI ---
  Future<void> _toggleTracking(bool value) async {
    setState(() => _isLoading = true);
    try {
      final endpoint = value ? "start" : "stop";
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("vehicle_type", _selectedVehicle);

      await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        body: {
          "Phone": "0342884664",
          "Name": "THANH TUNG",
          "Timestamp": DateTime.now().toIso8601String(),
          "Lat": "16.187372",
          "Long": "108.122398",
          "VehicleType": _selectedVehicle,
          "HeartRate": _heartRate.toString()
        },
      ).timeout(const Duration(seconds: 10));

      if (!mounted) return;
      await prefs.setBool("is_tracking", value);
      setState(() {
        _isTracking = value;
        _statusText =
            value ? "Đang giám sát ($_selectedVehicle)" : "Đã tắt theo dõi";
      });
      _showSnack(value ? "Đã bật chế độ an toàn" : "Đã tắt",
          value ? Colors.blue : Colors.grey);
    } catch (e) {
      if (mounted) _showSnack("Lỗi kết nối server", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- HÀM 2: CHECK-IN AN TOÀN ---
  Future<void> _checkIn() async {
    if (!_isTracking) {
      _showSnack("Bạn chưa bật chế độ an toàn!", Colors.orange);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/checkin'),
        body: {
          "Phone": "0342884664",
          "Lat": "16.183542",
          "Long": "108.126832",
          "Altitude": "496.0",
          "Note": "Check-in an toàn ($_selectedVehicle)",
          "HeartRate": _heartRate.toString()
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        _showSnack("✅ Đã báo an toàn tại Đèo Hải Vân!", Colors.green);
      }
    } catch (e) {
      if (mounted) _showSnack("Lỗi mạng", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- HÀM 3: GỬI SOS (ĐÃ FIX LOGIC CẤP ĐỘ) ---
  Future<void> _sendSOS({bool isAuto = false}) async {
    _countdownTimer?.cancel();
    _countdownTimer = null;

    setState(() {
      _isLoading = true;
      _isCountingDown = false;
    });

    try {
      final byteData = await rootBundle.load('assets/images/accident.png');
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/accident_evidence.png');
      await file.writeAsBytes(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/sos'));
      request.files
          .add(await http.MultipartFile.fromPath('EvidenceImage', file.path));

      request.fields['Phone'] = "0342884664";
      request.fields['Name'] = "THANH TUNG";
      request.fields['Lat'] = "16.187372";
      request.fields['Long'] = "108.122398";

      // --- LOGIC TẠO GHI CHÚ THÔNG MINH (ĐỒNG BỘ WEB) ---
      if (isAuto) {
        String reason = "";
        String levelPrefix = "[CẤP ĐỘ $_currentLevel]"; // Lấy cấp độ thực tế

        if (_triggerReason == "CRASH") {
          reason = "PHÁT HIỆN VA CHẠM MẠNH (Gia tốc kế)";
        } else {
          // Logic mô tả lý do dựa trên tim
          if (_heartRate >= 140)
            reason = "Nhịp tim QUÁ CAO (Nguy cơ đột quỵ/Sốc)";
          else if (_heartRate > 120)
            reason = "Nhịp tim CAO BẤT THƯỜNG (Cảnh báo)";
          else if (_heartRate < 45)
            reason = "Nhịp tim QUÁ THẤP (Nguy cơ ngừng tim)";
        }

        String motion = _isMoving ? "(Đang di chuyển)" : "(BẤT ĐỘNG)";

        request.fields['Note'] =
            "$levelPrefix KHẨN CẤP: $reason. Nạn nhân $motion.";
      } else {
        request.fields['Note'] = "SOS Chủ động (Người dùng bấm nút)";
      }

      request.fields['Altitude'] = "496.5";
      request.fields['Timestamp'] = DateTime.now().toIso8601String();
      request.fields['VehicleType'] = _selectedVehicle;
      request.fields['HeartRate'] = _heartRate.toString();

      var streamedResponse =
          await request.send().timeout(const Duration(seconds: 15));
      var response = await http.Response.fromStream(streamedResponse);

      if (mounted && response.statusCode == 200) {
        _showDialogSuccess(isAuto);
      } else {
        if (mounted) _showSnack("Lỗi Server: ${response.body}", Colors.red);
      }
    } catch (e) {
      if (mounted) _showDialogError("Lỗi kết nối hoặc lỗi ảnh: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- LOGIC PHÂN TÍCH THÔNG MINH (ĐÃ ĐỒNG BỘ WEB) ---
  void _onHeartRateChanged(double value) {
    setState(() {
      _heartRate = value;
      _triggerReason = "HEART";
      _analyzeDangerStatus();
    });
  }

  void _onMovingChanged(bool value) {
    setState(() {
      _isMoving = value;
      _triggerReason = "HEART";
      _analyzeDangerStatus();
    });
  }

  void _analyzeDangerStatus() {
    // 1. AN TOÀN TUYỆT ĐỐI (Đang chạy bộ)
    if (_isMoving && _heartRate > 100) {
      _dangerLevelText = "Đang vận động (An toàn)";
      _dangerColor = Colors.blue;
      _currentLevel = 0;
      if (_isCountingDown) _cancelAutoSOS();
      return;
    }

    // 2. PHÂN TÍCH THEO NGƯỠNG WEB SERVER

    // --- CẤP 3: KHẨN CẤP (Web đang set >= 140) ---
    if (_heartRate >= 140 || _heartRate <= 45) {
      _dangerLevelText = "Cấp 3: KHẨN CẤP (Nguy hiểm tột độ!)";
      _dangerColor = const Color(0xFF8B0000); // Đỏ đậm (Dark Red)
      _currentLevel = 3;
      if (!_isCountingDown) _startAutoSOSCountdown();
    }
    // --- CẤP 2: NGHI NGỜ / CẢNH BÁO CAO ---
    else if (_heartRate > 120 && _heartRate < 140) {
      _dangerLevelText = "Cấp 2: CẢNH BÁO CAO (Nghi ngờ)";
      _dangerColor = Colors.red;
      _currentLevel = 2;
      if (!_isCountingDown) _startAutoSOSCountdown();
    }
    // --- CẤP 1: THEO DÕI ---
    else if ((_heartRate >= 46 && _heartRate < 60) ||
        (_heartRate > 100 && _heartRate <= 120)) {
      _dangerLevelText = "Cấp 1: Theo dõi (Hơi bất thường)";
      _dangerColor = Colors.orange;
      _currentLevel = 1;
      if (_isCountingDown) _cancelAutoSOS();
    }
    // --- CẤP 0: BÌNH THƯỜNG ---
    else {
      _dangerLevelText = "Bình thường";
      _dangerColor = Colors.green;
      _currentLevel = 0;
      if (_isCountingDown) _cancelAutoSOS();
    }
  }

  // --- LOGIC ĐẾM NGƯỢC ---
  void _startAutoSOSCountdown() {
    setState(() {
      _isCountingDown = true;
      _secondsRemaining = 10;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            _countdownTimer ??=
                Timer.periodic(const Duration(seconds: 1), (timer) {
              if (_secondsRemaining > 0) {
                setStateDialog(() => _secondsRemaining--);
              } else {
                timer.cancel();
                Navigator.pop(context);
                _sendSOS(isAuto: true);
              }
            });

            // Tiêu đề Dialog dựa trên Cấp độ
            String titleMsg;
            if (_triggerReason == "CRASH") {
              titleMsg = "PHÁT HIỆN VA CHẠM!";
            } else {
              titleMsg = _currentLevel == 3
                  ? "CẢNH BÁO CẤP 3 (CỰC KỲ NGUY HIỂM)!"
                  : "CẢNH BÁO SỨC KHỎE";
            }

            String bodyMsg =
                "Phát hiện chỉ số sinh tồn bất thường.\nNhịp tim: ${_heartRate.toInt()} BPM";

            return AlertDialog(
              backgroundColor: Colors.red[50],
              title: Row(children: [
                const Icon(Icons.warning, color: Colors.red),
                const SizedBox(width: 10),
                Expanded(
                    child: Text(titleMsg,
                        style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)))
              ]),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(bodyMsg,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text("Gửi SOS sau: $_secondsRemaining s",
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.red)),
                  const SizedBox(height: 10),
                  const Text("Nếu bạn ổn, hãy bấm HỦY ngay."),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _handleUserCancel();
                  },
                  child: const Text("TÔI ỔN (HỦY)",
                      style: TextStyle(color: Colors.green, fontSize: 18)),
                )
              ],
            );
          },
        );
      },
    );
  }

  // --- LOGIC SNOOZE (TẠM DỪNG 15 GIÂY) ---
  void _handleUserCancel() {
    _cancelAutoSOS();

    if (_heartRate > 100 || _heartRate < 60 || _triggerReason == "CRASH") {
      setState(() {
        _isMoving = true;
        _dangerLevelText = "Tạm dừng cảnh báo (15s)";
        _dangerColor = Colors.blue;
      });

      _showSnack("Đã hiểu. Tạm dừng cảnh báo trong 15s để bạn nghỉ ngơi.",
          Colors.blue);

      _resetModeTimer?.cancel();
      _resetModeTimer = Timer(const Duration(seconds: 15), () {
        if (!mounted) return;
        setState(() {
          _isMoving = false;
          _analyzeDangerStatus();
        });
        _showSnack(
            "Hết thời gian tạm dừng. Kích hoạt lại giám sát!", Colors.orange);
      });
    }
  }

  void _cancelAutoSOS() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    setState(() => _isCountingDown = false);
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: color,
        duration: const Duration(seconds: 2)));
  }

  void _showDialogSuccess(bool isAuto) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
                title: const Text("ĐÃ GỬI SOS!",
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold)),
                content: Text(isAuto
                    ? "Hệ thống đã gửi SOS tự động [Cấp $_currentLevel].\nBác sĩ sẽ liên hệ ngay."
                    : "Đã gửi tín hiệu cứu hộ."),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("OK"))
                ]));
  }

  void _showDialogError(String errorMsg) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
                title: const Text("Lỗi"),
                content: Text(errorMsg),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Đóng"))
                ]));
  }

  Widget _buildVehicleSelector() {
    return Row(children: [
      Expanded(child: _buildOption("MOTO", Icons.motorcycle, "Xe Máy")),
      const SizedBox(width: 15),
      Expanded(child: _buildOption("CAR", Icons.directions_car, "Ô Tô"))
    ]);
  }

  Widget _buildOption(String type, IconData icon, String label) {
    bool isSelected = _selectedVehicle == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedVehicle = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey.shade300),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        color: Colors.blue.withOpacity(0.3), blurRadius: 8)
                  ]
                : []),
        child: Column(children: [
          Icon(icon, color: isSelected ? Colors.white : Colors.grey, size: 30),
          const SizedBox(height: 5),
          Text(label,
              style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.bold))
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text("Trung tâm An toàn"), centerTitle: true),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text("Phương tiện di chuyển:",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 10),
                _buildVehicleSelector(),
                const SizedBox(height: 20),

                // CARD 1: TIM MẠCH
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      children: [
                        const Text("GIẢ LẬP SINH TỒN (DEMO)",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey)),
                        const SizedBox(height: 10),
                        SwitchListTile(
                          title: const Text("Đang di chuyển",
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          subtitle:
                              const Text("Gia tốc kế phát hiện chuyển động"),
                          value: _isMoving,
                          onChanged: _onMovingChanged,
                          activeColor: Colors.blue,
                        ),
                        const Divider(),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.favorite,
                                  color: _dangerColor, size: 40),
                              const SizedBox(width: 10),
                              Text("${_heartRate.toInt()} BPM",
                                  style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: _dangerColor)),
                            ]),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 8),
                          decoration: BoxDecoration(
                              color: _dangerColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: _dangerColor)),
                          child: Text(_dangerLevelText,
                              style: TextStyle(
                                  color: _dangerColor,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center),
                        ),
                        Slider(
                          value: _heartRate,
                          min: 30,
                          max: 180,
                          divisions: 150,
                          activeColor: _dangerColor,
                          label: _heartRate.round().toString(),
                          onChanged: _onHeartRateChanged,
                        ),
                        const Text("Ngưỡng KHẨN CẤP: >= 140 BPM",
                            style: TextStyle(
                                fontSize: 12, fontStyle: FontStyle.italic)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // CARD 2: NÚT GIẢ LẬP VA CHẠM
                Card(
                  elevation: 4,
                  color: Colors.orange.shade50,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      children: [
                        const Text("CHẾ ĐỘ ĐIỆN THOẠI (KHÔNG ĐỒNG HỒ)",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.brown)),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _triggerReason = "CRASH";
                              _dangerLevelText = "PHÁT HIỆN VA CHẠM MẠNH!";
                              _dangerColor = Colors.red;
                              _currentLevel = 3; // Va chạm luôn là cấp 3
                            });
                            _startAutoSOSCountdown();
                          },
                          icon:
                              const Icon(Icons.car_crash, color: Colors.white),
                          label: const Text("GIẢ LẬP: VA CHẠM / TÉ NGÃ"),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              foregroundColor: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                if (_isTracking)
                  ElevatedButton.icon(
                      onPressed: _checkIn,
                      icon: const Icon(Icons.check_circle),
                      label: const Text("BÁO TÔI AN TOÀN"),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15))),

                const SizedBox(height: 15),

                // NÚT GỌI BÁC SĨ
                ElevatedButton.icon(
                  onPressed: () {
                    String callId = "bac_si_cap_cuu_01";
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TelemedicineScreen(
                          callID: callId,
                          userID: _userCode ??
                              "user_${DateTime.now().millisecondsSinceEpoch}",
                          userName: "Bệnh nhân ${_userCode ?? 'Demo'}",
                          currentHeartRate: _heartRate,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.video_call, size: 28),
                  label: const Text("TƯ VẤN BÁC SĨ TỪ XA",
                      style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 5,
                  ),
                ),

                const SizedBox(height: 30),
                GestureDetector(
                  onLongPress: () => _sendSOS(isAuto: false),
                  onTap: () =>
                      _showSnack("⚠️ Nhấn giữ 2s để SOS", Colors.orange),
                  child: Container(
                    height: 160,
                    width: 160,
                    margin: const EdgeInsets.symmetric(horizontal: 80),
                    decoration: BoxDecoration(
                        color: Colors.red[50],
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.red, width: 3),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.red.withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 5)
                        ]),
                    child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('assets/images/accident.png',
                                  height: 70,
                                  fit: BoxFit.contain,
                                  errorBuilder: (c, o, s) => const Icon(
                                      Icons.warning,
                                      size: 50,
                                      color: Colors.red)),
                              const SizedBox(height: 5),
                              const Text("BÁO TAI NẠN",
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16))
                            ])),
                  ),
                ),
                const SizedBox(height: 15),
                const Center(
                    child: Text("Nhấn giữ nút trên để gửi vị trí",
                        style: TextStyle(color: Colors.grey))),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(children: [
                        Text("Trạng thái: $_statusText",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color:
                                    _isTracking ? Colors.green : Colors.grey)),
                        SwitchListTile(
                            title: const Text("Chế độ đi Tour/Trekking"),
                            value: _isTracking,
                            onChanged: _toggleTracking)
                      ])),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
                color: Colors.black45,
                child: const Center(
                    child: CircularProgressIndicator(color: Colors.white))),
        ],
      ),
    );
  }
}
