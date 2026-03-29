import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PaymentAmountPage extends StatefulWidget {
  final Function(int money) onPaid;

  const PaymentAmountPage({super.key, required this.onPaid});

  @override
  State<PaymentAmountPage> createState() => _PaymentAmountPageState();
}

class _PaymentAmountPageState extends State<PaymentAmountPage> {
  final TextEditingController _moneyCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thanh toán QR"),
        foregroundColor: Colors.blue,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Quét mã QR để thanh toán",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),

            // ⭐ QR GIẢ LẬP
            QrImageView(
              data: "HUTECH_CLINIC_FAKE_PAYMENT",
              version: QrVersions.auto,
              size: 220,
            ),

            const SizedBox(height: 25),

            const Text(
              "Sau khi chuyển khoản, nhập số tiền đã thanh toán",
              style: TextStyle(fontSize: 15, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _moneyCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Số tiền (VNĐ)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.payments),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle),
                label: const Text("Xác nhận thanh toán",
                    style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _handlePayment,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handlePayment() {
    final text = _moneyCtrl.text.trim();

    if (text.isEmpty || int.tryParse(text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng nhập số tiền hợp lệ!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final int amount = int.parse(text);

    widget.onPaid(amount); // Trả số tiền về ConfirmBookingPage
    Navigator.pop(context);
  }
}
