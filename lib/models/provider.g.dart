// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

class HealthcareProviderAdapter extends TypeAdapter<HealthcareProvider> {
  @override
  final int typeId = 1;

  @override
  HealthcareProvider read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HealthcareProvider(
      id: fields[0] as String,
      name: fields[1] as String,
      type: fields[2] as String,
      specialty: fields[3] as String?,
      description: fields[4] as String?,
      phone: fields[5] as String,
      email: fields[6] as String?,
      profileImageUrl: fields[7] as String?,
      state: fields[8] as String,
      lga: fields[9] as String?,
      address: fields[10] as String?,
      latitude: fields[11] as double,
      longitude: fields[12] as double,
      rating: fields[13] as double,
      reviewCount: fields[14] as int,
      priceMin: fields[15] as double?,
      priceMax: fields[16] as double?,
      isAvailable: fields[17] as bool,
      workingDays: (fields[18] as List?)?.cast<String>(),
      workingHours: fields[19] as String?,
      services: (fields[20] as List?)?.cast<String>(),
      acceptedInsurance: (fields[21] as List?)?.cast<String>(),
      createdAt: fields[22] as DateTime,
      isVerified: fields[23] as bool,
      licenseNumber: fields[24] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, HealthcareProvider obj) {
    writer
      ..writeByte(25)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.specialty)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.phone)
      ..writeByte(6)
      ..write(obj.email)
      ..writeByte(7)
      ..write(obj.profileImageUrl)
      ..writeByte(8)
      ..write(obj.state)
      ..writeByte(9)
      ..write(obj.lga)
      ..writeByte(10)
      ..write(obj.address)
      ..writeByte(11)
      ..write(obj.latitude)
      ..writeByte(12)
      ..write(obj.longitude)
      ..writeByte(13)
      ..write(obj.rating)
      ..writeByte(14)
      ..write(obj.reviewCount)
      ..writeByte(15)
      ..write(obj.priceMin)
      ..writeByte(16)
      ..write(obj.priceMax)
      ..writeByte(17)
      ..write(obj.isAvailable)
      ..writeByte(18)
      ..write(obj.workingDays)
      ..writeByte(19)
      ..write(obj.workingHours)
      ..writeByte(20)
      ..write(obj.services)
      ..writeByte(21)
      ..write(obj.acceptedInsurance)
      ..writeByte(22)
      ..write(obj.createdAt)
      ..writeByte(23)
      ..write(obj.isVerified)
      ..writeByte(24)
      ..write(obj.licenseNumber);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthcareProviderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
