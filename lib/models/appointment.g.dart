// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment.dart';

class AppointmentAdapter extends TypeAdapter<Appointment> {
  @override
  final int typeId = 2;

  @override
  Appointment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Appointment(
      id: fields[0] as String,
      patientId: fields[1] as String,
      providerId: fields[2] as String,
      providerName: fields[3] as String,
      providerType: fields[4] as String,
      dateTime: fields[5] as DateTime,
      status: fields[6] as String,
      notes: fields[7] as String?,
      symptoms: fields[8] as String?,
      createdAt: fields[9] as DateTime,
      isEmergency: fields[10] as bool,
      appointmentType: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Appointment obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.patientId)
      ..writeByte(2)
      ..write(obj.providerId)
      ..writeByte(3)
      ..write(obj.providerName)
      ..writeByte(4)
      ..write(obj.providerType)
      ..writeByte(5)
      ..write(obj.dateTime)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.notes)
      ..writeByte(8)
      ..write(obj.symptoms)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.isEmergency)
      ..writeByte(11)
      ..write(obj.appointmentType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppointmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
