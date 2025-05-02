import 'dart:io';

class TimeCapsuleModel {
  final String id;
  final String title;
  final DateTime createdAt;
  final List<File> photos;
  final String? musicPath;
  final String? videoPath;
  final ThemeStyle themeStyle;

  TimeCapsuleModel({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.photos,
    this.musicPath,
    this.videoPath,
    this.themeStyle = ThemeStyle.minimal,
  });

  TimeCapsuleModel copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    List<File>? photos,
    String? musicPath,
    String? videoPath,
    ThemeStyle? themeStyle,
  }) {
    return TimeCapsuleModel(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      photos: photos ?? this.photos,
      musicPath: musicPath ?? this.musicPath,
      videoPath: videoPath ?? this.videoPath,
      themeStyle: themeStyle ?? this.themeStyle,
    );
  }

  // Convert model to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'photoPaths': photos.map((photo) => photo.path).toList(),
      'musicPath': musicPath,
      'videoPath': videoPath,
      'themeStyle': themeStyle.index,
    };
  }

  // Create model from JSON
  factory TimeCapsuleModel.fromJson(Map<String, dynamic> json) {
    return TimeCapsuleModel(
      id: json['id'],
      title: json['title'],
      createdAt: DateTime.parse(json['createdAt']),
      photos:
          (json['photoPaths'] as List<dynamic>)
              .map((path) => File(path))
              .toList(),
      musicPath: json['musicPath'],
      videoPath: json['videoPath'],
      themeStyle: ThemeStyle.values[json['themeStyle']],
    );
  }
}

// Available theme styles for TimeCapsule
enum ThemeStyle {
  minimal,
  retro,
  summer,
  romantic,
  winter,
  neon,
  vintage,
  blackAndWhite,
}

// Extensions for ThemeStyle enum
extension ThemeStyleExtension on ThemeStyle {
  String get displayName {
    switch (this) {
      case ThemeStyle.minimal:
        return 'Minimal';
      case ThemeStyle.retro:
        return 'Retro';
      case ThemeStyle.summer:
        return 'Summer';
      case ThemeStyle.romantic:
        return 'Romantic';
      case ThemeStyle.winter:
        return 'Winter';
      case ThemeStyle.neon:
        return 'Neon';
      case ThemeStyle.vintage:
        return 'Vintage';
      case ThemeStyle.blackAndWhite:
        return 'Black & White';
    }
  }
}
