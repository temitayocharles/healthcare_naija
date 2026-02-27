// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'symptom_record.dart';

class SymptomRecordAdapter extends TypeAdapter<SymptomRecord> {
  @override
  final int typeId = 3;

  @override
  SymptomRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SymptomRecord(
      id: fields[0] as String,
      userId: fields[1] as String,
      symptoms: (fields[2] as List).cast<String>(),
      aiDiagnosis: fields[3] as String?,
      severity: fields[4] as String,
      recommendedAction: fields[5] as String?,
      possibleConditions: (fields[6] as List?)?.cast<String>(),
      timestamp: fields[7] as DateTime,
      isRead: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SymptomRecord obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.symptoms)
      ..writeByte(3)
      ..write(obj.aiDiagnosis)
      ..writeByte(4)
      ..write(obj.severity)
      ..writeByte(5)
      ..write(obj.recommendedAction)
      ..writeByte(6)
      ..write(obj.possibleConditions)
      ..writeByte(7)
      ..write(obj.timestamp)
      ..writeByte(8)
      ..write(obj.isRead);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SymptomRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
