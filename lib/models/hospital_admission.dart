class HospitalAdmission {
  final int id;
  final String patientName;
  final String phoneNumber;
  final String reason;
  final String status;
  final String createdAt;

  HospitalAdmission({
    required this.id,
    required this.patientName,
    required this.phoneNumber,
    required this.reason,
    required this.status,
    required this.createdAt,
  });

  factory HospitalAdmission.fromJson(Map<String, dynamic> json) {
    return HospitalAdmission(
      id: json['id'],
      patientName: json['patientName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'ChoDuyet',
      createdAt: json['createdAt'] ?? '',
    );
  }
}
