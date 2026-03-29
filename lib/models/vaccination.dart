class Vaccination {
  final String vaccineName;
  final int doseNumber;
  final String status;
  final DateTime? vaccinationDate;
  final DateTime? nextDueDate;
  final String? note;

  Vaccination({
    required this.vaccineName,
    required this.doseNumber,
    required this.status,
    this.vaccinationDate,
    this.nextDueDate,
    this.note,
  });

  factory Vaccination.fromJson(Map<String, dynamic> json) {
    return Vaccination(
      vaccineName: json['vaccineName'],
      doseNumber: json['doseNumber'],
      status: json['status'],
      vaccinationDate: json['vaccinationDate'] != null
          ? DateTime.parse(json['vaccinationDate'])
          : null,
      nextDueDate: json['nextDueDate'] != null
          ? DateTime.parse(json['nextDueDate'])
          : null,
      note: json['note'],
    );
  }
}
