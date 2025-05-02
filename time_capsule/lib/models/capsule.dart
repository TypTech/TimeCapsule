import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'capsule.g.dart';

@HiveType(typeId: 0)
class Capsule extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String theme;

  @HiveField(4)
  final List<String> imagePaths;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime? lastViewedAt;

  Capsule({
    String? id,
    required this.title,
    required this.description,
    required this.theme,
    required this.imagePaths,
    DateTime? createdAt,
    this.lastViewedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  Capsule copyWith({
    String? title,
    String? description,
    String? theme,
    List<String>? imagePaths,
    DateTime? lastViewedAt,
  }) {
    return Capsule(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      theme: theme ?? this.theme,
      imagePaths: imagePaths ?? this.imagePaths,
      createdAt: createdAt,
      lastViewedAt: lastViewedAt ?? this.lastViewedAt,
    );
  }
}
