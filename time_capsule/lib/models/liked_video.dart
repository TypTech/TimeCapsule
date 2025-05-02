import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'liked_video.g.dart';

@HiveType(typeId: 2)
class LikedVideo {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String videoPath;

  @HiveField(2)
  final DateTime likedAt;

  @HiveField(3)
  bool isLiked;

  @HiveField(4)
  final String? thumbnailPath;

  LikedVideo({
    String? id,
    required this.videoPath,
    DateTime? likedAt,
    this.isLiked = true,
    this.thumbnailPath,
  }) : id = id ?? const Uuid().v4(),
       likedAt = likedAt ?? DateTime.now();
}
