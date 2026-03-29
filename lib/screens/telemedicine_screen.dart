import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

// ⚠️ ĐỪNG QUÊN THAY APP ID & APP SIGN CỦA BẠN VÀO ĐÂY
const int yourAppID = 424067148;
const String yourAppSign =
    "4c4c7fea0c68c28b6ec5b9104946d1b117634118dc94e042ef943b8f8767c947";

class TelemedicineScreen extends StatelessWidget {
  final String callID;
  final String userID;
  final String userName;
  final double currentHeartRate;

  const TelemedicineScreen({
    super.key,
    required this.callID,
    required this.userID,
    required this.userName,
    required this.currentHeartRate,
  });

  @override
  Widget build(BuildContext context) {
    Color heartRateColor = currentHeartRate > 100 || currentHeartRate < 60
        ? Colors.redAccent
        : Colors.greenAccent;
    String statusText = currentHeartRate > 100
        ? "Nhịp tim CAO"
        : (currentHeartRate < 60 ? "Nhịp tim THẤP" : "Ổn định");

    return SafeArea(
      child: ZegoUIKitPrebuiltCall(
        appID: yourAppID,
        appSign: yourAppSign,
        userID: userID,
        userName: userName,
        callID: callID,

        // CẤU HÌNH GIAO DIỆN CƠ BẢN
        config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
          ..foreground = Stack(
            children: [
              Positioned(
                top: 20,
                left: 20,
                child: _buildHealthDataCard(heartRateColor, statusText),
              ),
              const Positioned(
                top: 20,
                right: 20,
                child: _DoctorInfoChip(),
              ),
              Positioned(
                top: 10,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(20)),
                    child: const Text("Tư vấn Y tế Từ xa",
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ),
                ),
              )
            ],
          ),

        // 👇 SỬA LỖI: DÙNG 'events' ĐỂ XỬ LÝ KẾT THÚC CUỘC GỌI
        events: ZegoUIKitPrebuiltCallEvents(
          onCallEnd: (event, defaultAction) {
            Navigator.of(context).pop(); // Thoát màn hình khi kết thúc
          },
        ),
      ),
    );
  }

  // --- WIDGET CON: BẢNG DỮ LIỆU SỨC KHỎE ---
  Widget _buildHealthDataCard(Color hrColor, String status) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.monitor_heart,
                      color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text("DỮ LIỆU SINH TỒN (LIVE)",
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite, color: hrColor, size: 28),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${currentHeartRate.toInt()} BPM",
                          style: TextStyle(
                              color: hrColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 22)),
                      Text(status,
                          style: TextStyle(
                              color: hrColor.withOpacity(0.8), fontSize: 12)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: 10),
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bloodtype_outlined,
                      color: Colors.blueAccent, size: 24),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("120/80 mmHg",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      Text("Huyết áp (Gần đây)",
                          style:
                              TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- WIDGET CON: THÔNG TIN BÁC SĨ ---
class _DoctorInfoChip extends StatelessWidget {
  const _DoctorInfoChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.indigo.withOpacity(0.8),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 18, color: Colors.indigo),
          ),
          SizedBox(width: 8),
          Text("BS. Trực Tuyến",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
          SizedBox(width: 4),
          Icon(Icons.verified, color: Colors.lightBlueAccent, size: 14)
        ],
      ),
    );
  }
}
