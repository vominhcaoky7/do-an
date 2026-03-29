// File: lib/appointments/appointment_history_model.dart

import 'package:flutter/foundation.dart';

class AppointmentHistory {
  final int? id; // cho phép null vì test local không có id
  final String? patientName; // cho phép null vì test local không cần
  final String doctorName;
  final String specialty;
  final String clinicName;
  final DateTime date;
  final String slot;
  final String status;

  AppointmentHistory({
    this.id,
    this.patientName,
    required this.doctorName,
    required this.specialty,
    required this.clinicName,
    required this.date,
    required this.slot,
    required this.status,
  });

  // THÊM HÀM toJson() – BẮT BUỘC ĐỂ LƯU LOCAL
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientName': patientName,
      'doctorName': doctorName,
      'specialty': specialty,
      'clinicName': clinicName,
      'date': date.toIso8601String(),
      'slot': slot,
      'status': status,
    };
  }

  // Sửa fromJson để hỗ trợ cả API thật và local test
  factory AppointmentHistory.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    try {
      // API thật trả về 'Date', local test trả về 'date'
      final dateStr = json['Date'] ?? json['date'];
      parsedDate = DateTime.parse(dateStr as String);
    } catch (e) {
      parsedDate = DateTime.now();
    }

    return AppointmentHistory(
      id: json['Id'] ?? json['id'],
      patientName: json['PatientName'] ?? json['patientName'],
      doctorName:
          json['DoctorName'] ?? json['doctorName'] ?? 'Chưa có tên bác sĩ',
      specialty:
          json['Specialty'] ?? json['specialty'] ?? 'Chưa chọn chuyên khoa',
      clinicName:
          json['ClinicName'] ?? json['clinicName'] ?? 'Trạm Xá Di Động HUTECH',
      date: parsedDate,
      slot: json['Slot'] ?? json['slot'] ?? 'Chưa chọn khung giờ',
      status: json['Status'] ?? json['status'] ?? 'Sắp khám',
    );
  }
}
