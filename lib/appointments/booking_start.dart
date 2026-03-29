// Folder: lib/appointments
// File: booking_start.dart
// FIX FULL – Loại bỏ AlertDialog tạo hồ sơ cũ. Chuyển sang CreateProfilePage.

import 'package:flutter/material.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final isActive = index == currentStep;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 16 : 10,
          height: isActive ? 16 : 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.blue : Colors.grey.shade300,
          ),
        );
      }),
    );
  }
}

class BookingStart extends StatelessWidget {
  const BookingStart({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        title: const Text(
          'Đặt khám',
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const StepIndicator(currentStep: 0),
              const SizedBox(height: 30),

              // IMAGE
              Expanded(
                child: Image.asset(
                  'assets/images/doctor.png',
                  width: 250,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.local_hospital,
                    size: 120,
                    color: Colors.blue,
                  ),
                ),
              ),

              const Text(
                'Bạn chưa có hồ sơ đặt khám, vui lòng tạo hồ sơ mới',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => showBookingBottomSheet(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Thêm mới hồ sơ'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showBookingBottomSheet(BuildContext context) {
  showModalBottomSheet(
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    context: context,
    builder: (sheetContext) => DraggableScrollableSheet(
      initialChildSize: 0.36,
      minChildSize: 0.3,
      maxChildSize: 0.7,
      builder: (_, controller) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(26),
            topRight: Radius.circular(26),
          ),
        ),
        child: ListView(
          controller: controller,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.pop(sheetContext),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Icon(Icons.close),
                ),
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Bạn đã từng khám tại Trạm Xá Di Động HUTECH chưa?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 20),

            // ------------------------------------------
            // Đã từng khám -> Nhập mã người bệnh
            // ------------------------------------------
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(sheetContext);
                  Navigator.pushNamed(context, "/enter_patient_code");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('ĐÃ TỪNG KHÁM, NHẬP MÃ NGƯỜI BỆNH'),
              ),
            ),

            const SizedBox(height: 12),

            // ------------------------------------------
            // Chưa từng khám -> Tạo hồ sơ mới (UI riêng)
            // ------------------------------------------
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  Navigator.pop(sheetContext); // đóng bottom sheet

                  // mở trang tạo hồ sơ riêng
                  final result =
                      await Navigator.pushNamed(context, "/create_profile");

                  if (result == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Đã tạo hồ sơ mới"),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.blue),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'CHƯA TỪNG KHÁM, TẠO HỒ SƠ MỚI',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
