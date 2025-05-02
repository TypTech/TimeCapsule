// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'liked_video.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LikedVideoAdapter extends TypeAdapter<LikedVideo> {
  @override
  final int typeId = 2;

  @override
  LikedVideo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LikedVideo(
      id: fields[0] as String?,
      videoPath: fields[1] as String,
      likedAt: fields[2] as DateTime?,
      isLiked: fields[3] as bool,
      thumbnailPath: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, LikedVideo obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.videoPath)
      ..writeByte(2)
      ..write(obj.likedAt)
      ..writeByte(3)
      ..write(obj.isLiked)
      ..writeByte(4)
      ..write(obj.thumbnailPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LikedVideoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
