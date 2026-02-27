import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String? email;

  @HiveField(2)
  final String phone;

  @HiveField(3)
  final String name;

  @HiveField(4)
  final String role;

  @HiveField(5)
  final String? profileImageUrl;

  @HiveField(6)
  final String? state;

  @HiveField(7)
  final String? lga;

  @HiveField(8)
  final String? address;

  @HiveField(9)
  final double? latitude;

  @HiveField(10)
  final double? longitude;

  @HiveField(11)
  final DateTime createdAt;

  @HiveField(12)
  final bool isVerified;

  @HiveField(13)
  final Map<String, dynamic>? medicalHistory;

  User({
    required this.id,
    this.email,
    required this.phone,
    required this.name,
    required this.role,
    this.profileImageUrl,
    this.state,
    this.lga,
    this.address,
    this.latitude,
    this.longitude,
    required this.createdAt,
    this.isVerified = false,
    this.medicalHistory,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'],
      phone: json['phone'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? 'patient',
      profileImageUrl: json['profileImageUrl'],
      state: json['state'],
      lga: json['lga'],
      address: json['address'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      isVerified: json['isVerified'] ?? false,
      medicalHistory: json['medicalHistory'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'name': name,
      'role': role,
      'profileImageUrl': profileImageUrl,
      'state': state,
      'lga': lga,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt.toIso8601String(),
      'isVerified': isVerified,
      'medicalHistory': medicalHistory,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? phone,
    String? name,
    String? role,
    String? profileImageUrl,
    String? state,
    String? lga,
    String? address,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    bool? isVerified,
    Map<String, dynamic>? medicalHistory,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      role: role ?? this.role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      state: state ?? this.state,
      lga: lga ?? this.lga,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      isVerified: isVerified ?? this.isVerified,
      medicalHistory: medicalHistory ?? this.medicalHistory,
    );
  }
}
