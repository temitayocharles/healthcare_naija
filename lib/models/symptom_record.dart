import 'package:hive/hive.dart';

part 'symptom_record.g.dart';

@HiveType(typeId: 3)
class SymptomRecord {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final List<String> symptoms;

  @HiveField(3)
  final String? aiDiagnosis;

  @HiveField(4)
  final String severity; // emergency, urgent, normal

  @HiveField(5)
  final String? recommendedAction;

  @HiveField(6)
  final List<String>? possibleConditions;

  @HiveField(7)
  final DateTime timestamp;

  @HiveField(8)
  final bool isRead;

  SymptomRecord({
    required this.id,
    required this.userId,
    required this.symptoms,
    this.aiDiagnosis,
    required this.severity,
    this.recommendedAction,
    this.possibleConditions,
    required this.timestamp,
    this.isRead = false,
  });

  factory SymptomRecord.fromJson(Map<String, dynamic> json) {
    return SymptomRecord(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      symptoms: json['symptoms'] != null
          ? List<String>.from(json['symptoms'])
          : [],
      aiDiagnosis: json['aiDiagnosis'],
      severity: json['severity'] ?? 'normal',
      recommendedAction: json['recommendedAction'],
      possibleConditions: json['possibleConditions'] != null
          ? List<String>.from(json['possibleConditions'])
          : null,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'symptoms': symptoms,
      'aiDiagnosis': aiDiagnosis,
      'severity': severity,
      'recommendedAction': recommendedAction,
      'possibleConditions': possibleConditions,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }
}
