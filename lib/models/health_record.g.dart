// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_record.dart';

class HealthRecordAdapter extends TypeAdapter<HealthRecord> {
  @override
  final int typeId = 4;

  @override
  HealthRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HealthRecord(
      id: fields[0] as String,
      userId: fields[1] as String,
      title: fields[2] as String,
      type: fields[3] as String,
      description: fields[4] as String?,
      fileUrl: fields[5] as String?,
      date: fields[6] as DateTime,
      providerName: fields[7] as String?,
      tags: (fields[8] as List?)?.cast<String>(),
      isShared: fields[9] as bool,
      createdAt: fields[10] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, HealthRecord obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.fileUrl)
      ..writeByte(6)
      ..write(obj.date)
      ..writeByte(7)
      ..write(obj.providerName)
      ..writeByte(8)
      ..write(obj.tags)
      ..writeByte(9)
      ..write(obj.isShared)
      ..writeByte(10)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
