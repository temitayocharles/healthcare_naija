import 'package:hive/hive.dart';

part 'appointment.g.dart';

@HiveType(typeId: 2)
class Appointment {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String patientId;

  @HiveField(2)
  final String providerId;

  @HiveField(3)
  final String providerName;

  @HiveField(4)
  final String providerType;

  @HiveField(5)
  final DateTime dateTime;

  @HiveField(6)
  final String status; // pending, confirmed, completed, cancelled

  @HiveField(7)
  final String? notes;

  @HiveField(8)
  final String? symptoms;

  @HiveField(9)
  final DateTime createdAt;

  @HiveField(10)
  final bool isEmergency;

  @HiveField(11)
  final String? appointmentType; // in_person, telemedicine

  Appointment({
    required this.id,
    required this.patientId,
    required this.providerId,
    required this.providerName,
    required this.providerType,
    required this.dateTime,
    required this.status,
    this.notes,
    this.symptoms,
    required this.createdAt,
    this.isEmergency = false,
    this.appointmentType,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] ?? '',
      patientId: json['patientId'] ?? '',
      providerId: json['providerId'] ?? '',
      providerName: json['providerName'] ?? '',
      providerType: json['providerType'] ?? '',
      dateTime: json['dateTime'] != null
          ? DateTime.parse(json['dateTime'])
          : DateTime.now(),
      status: json['status'] ?? 'pending',
      notes: json['notes'],
      symptoms: json['symptoms'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      isEmergency: json['isEmergency'] ?? false,
      appointmentType: json['appointmentType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'providerId': providerId,
      'providerName': providerName,
      'providerType': providerType,
      'dateTime': dateTime.toIso8601String(),
      'status': status,
      'notes': notes,
      'symptoms': symptoms,
      'createdAt': createdAt.toIso8601String(),
      'isEmergency': isEmergency,
      'appointmentType': appointmentType,
    };
  }

  Appointment copyWith({
    String? id,
    String? patientId,
    String? providerId,
    String? providerName,
    String? providerType,
    DateTime? dateTime,
    String? status,
    String? notes,
    String? symptoms,
    DateTime? createdAt,
    bool? isEmergency,
    String? appointmentType,
  }) {
    return Appointment(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      providerType: providerType ?? this.providerType,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      symptoms: symptoms ?? this.symptoms,
      createdAt: createdAt ?? this.createdAt,
      isEmergency: isEmergency ?? this.isEmergency,
      appointmentType: appointmentType ?? this.appointmentType,
    );
  }
}
