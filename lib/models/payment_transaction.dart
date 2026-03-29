class PaymentTransaction {
  final int id;
  final String patientCode;
  final double amount;
  final String status;
  final String createdAt;

  PaymentTransaction({
    required this.id,
    required this.patientCode,
    required this.amount,
    required this.status,
    required this.createdAt,
  });

  factory PaymentTransaction.fromJson(Map<String, dynamic> json) {
    return PaymentTransaction(
      id: json['id'] ?? 0,
      patientCode: json['patientCode'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] ?? '',
    );
  }
}
