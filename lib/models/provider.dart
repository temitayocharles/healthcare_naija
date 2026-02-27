import 'package:hive/hive.dart';

part 'provider.g.dart';

@HiveType(typeId: 1)
class HealthcareProvider {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String type; // physician, nurse, caregiver, pharmacy, hospital

  @HiveField(3)
  final String? specialty;

  @HiveField(4)
  final String? description;

  @HiveField(5)
  final String phone;

  @HiveField(6)
  final String? email;

  @HiveField(7)
  final String? profileImageUrl;

  @HiveField(8)
  final String state;

  @HiveField(9)
  final String? lga;

  @HiveField(10)
  final String? address;

  @HiveField(11)
  final double latitude;

  @HiveField(12)
  final double longitude;

  @HiveField(13)
  final double rating;

  @HiveField(14)
  final int reviewCount;

  @HiveField(15)
  final double? priceMin;

  @HiveField(16)
  final double? priceMax;

  @HiveField(17)
  final bool isAvailable;

  @HiveField(18)
  final List<String>? workingDays;

  @HiveField(19)
  final String? workingHours;

  @HiveField(20)
  final List<String>? services;

  @HiveField(21)
  final List<String>? acceptedInsurance;

  @HiveField(22)
  final DateTime createdAt;

  @HiveField(23)
  final bool isVerified;

  @HiveField(24)
  final String? licenseNumber;

  Provider({
    required this.id,
    required this.name,
    required this.type,
    this.specialty,
    this.description,
    required this.phone,
    this.email,
    this.profileImageUrl,
    required this.state,
    this.lga,
    this.address,
    required this.latitude,
    required this.longitude,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.priceMin,
    this.priceMax,
    this.isAvailable = true,
    this.workingDays,
    this.workingHours,
    this.services,
    this.acceptedInsurance,
    required this.createdAt,
    this.isVerified = false,
    this.licenseNumber,
  });

  factory HealthcareProvider.fromJson(Map<String, dynamic> json) {
    return HealthcareProvider(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      specialty: json['specialty'],
      description: json['description'],
      phone: json['phone'] ?? '',
      email: json['email'],
      profileImageUrl: json['profileImageUrl'],
      state: json['state'] ?? '',
      lga: json['lga'],
      address: json['address'],
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      rating: json['rating']?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] ?? 0,
      priceMin: json['priceMin']?.toDouble(),
      priceMax: json['priceMax']?.toDouble(),
      isAvailable: json['isAvailable'] ?? true,
      workingDays: json['workingDays'] != null
          ? List<String>.from(json['workingDays'])
          : null,
      workingHours: json['workingHours'],
      services:
          json['services'] != null ? List<String>.from(json['services']) : null,
      acceptedInsurance: json['acceptedInsurance'] != null
          ? List<String>.from(json['acceptedInsurance'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      isVerified: json['isVerified'] ?? false,
      licenseNumber: json['licenseNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'specialty': specialty,
      'description': description,
      'phone': phone,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'state': state,
      'lga': lga,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'rating': rating,
      'reviewCount': reviewCount,
      'priceMin': priceMin,
      'priceMax': priceMax,
      'isAvailable': isAvailable,
      'workingDays': workingDays,
      'workingHours': workingHours,
      'services': services,
      'acceptedInsurance': acceptedInsurance,
      'createdAt': createdAt.toIso8601String(),
      'isVerified': isVerified,
      'licenseNumber': licenseNumber,
    };
  }

  HealthcareProvider copyWith({
    String? id,
    String? name,
    String? type,
    String? specialty,
    String? description,
    String? phone,
    String? email,
    String? profileImageUrl,
    String? state,
    String? lga,
    String? address,
    double? latitude,
    double? longitude,
    double? rating,
    int? reviewCount,
    double? priceMin,
    double? priceMax,
    bool? isAvailable,
    List<String>? workingDays,
    String? workingHours,
    List<String>? services,
    List<String>? acceptedInsurance,
    DateTime? createdAt,
    bool? isVerified,
    String? licenseNumber,
  }) {
    return HealthcareProvider(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      specialty: specialty ?? this.specialty,
      description: description ?? this.description,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      state: state ?? this.state,
      lga: lga ?? this.lga,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      priceMin: priceMin ?? this.priceMin,
      priceMax: priceMax ?? this.priceMax,
      isAvailable: isAvailable ?? this.isAvailable,
      workingDays: workingDays ?? this.workingDays,
      workingHours: workingHours ?? this.workingHours,
      services: services ?? this.services,
      acceptedInsurance: acceptedInsurance ?? this.acceptedInsurance,
      createdAt: createdAt ?? this.createdAt,
      isVerified: isVerified ?? this.isVerified,
      licenseNumber: licenseNumber ?? this.licenseNumber,
    );
  }
}
