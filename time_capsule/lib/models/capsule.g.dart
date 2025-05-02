// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'capsule.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CapsuleAdapter extends TypeAdapter<Capsule> {
  @override
  final int typeId = 0;

  @override
  Capsule read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Capsule(
      id: fields[0] as String?,
      title: fields[1] as String,
      description: fields[2] as String,
      theme: fields[3] as String,
      imagePaths: (fields[4] as List).cast<String>(),
      createdAt: fields[5] as DateTime?,
      lastViewedAt: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Capsule obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.theme)
      ..writeByte(4)
      ..write(obj.imagePaths)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.lastViewedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CapsuleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
