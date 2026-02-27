import 'package:hive/hive.dart';

part 'health_record.g.dart';

@HiveType(typeId: 4)
class HealthRecord {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String type; // lab_result, prescription, scan, vaccination, other

  @HiveField(4)
  final String? description;

  @HiveField(5)
  final String? fileUrl;

  @HiveField(6)
  final DateTime date;

  @HiveField(7)
  final String? providerName;

  @HiveField(8)
  final List<String>? tags;

  @HiveField(9)
  final bool isShared;

  @HiveField(10)
  final DateTime createdAt;

  HealthRecord({
    required this.id,
    required this.userId,
    required this.title,
    required this.type,
    this.description,
    this.fileUrl,
    required this.date,
    this.providerName,
    this.tags,
    this.isShared = false,
    required this.createdAt,
  });

  factory HealthRecord.fromJson(Map<String, dynamic> json) {
    return HealthRecord(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      type: json['type'] ?? 'other',
      description: json['description'],
      fileUrl: json['fileUrl'],
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      providerName: json['providerName'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      isShared: json['isShared'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'type': type,
      'description': description,
      'fileUrl': fileUrl,
      'date': date.toIso8601String(),
      'providerName': providerName,
      'tags': tags,
      'isShared': isShared,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
