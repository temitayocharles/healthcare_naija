// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 0;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      id: fields[0] as String,
      email: fields[1] as String?,
      phone: fields[2] as String,
      name: fields[3] as String,
      role: fields[4] as String,
      profileImageUrl: fields[5] as String?,
      state: fields[6] as String?,
      lga: fields[7] as String?,
      address: fields[8] as String?,
      latitude: fields[9] as double?,
      longitude: fields[10] as double?,
      createdAt: fields[11] as DateTime,
      isVerified: fields[12] as bool,
      medicalHistory: (fields[13] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.phone)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.role)
      ..writeByte(5)
      ..write(obj.profileImageUrl)
      ..writeByte(6)
      ..write(obj.state)
      ..writeByte(7)
      ..write(obj.lga)
      ..writeByte(8)
      ..write(obj.address)
      ..writeByte(9)
      ..write(obj.latitude)
      ..writeByte(10)
      ..write(obj.longitude)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.isVerified)
      ..writeByte(13)
      ..write(obj.medicalHistory);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
