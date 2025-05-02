import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

class ImageProcessingService extends ChangeNotifier {
  // Singleton pattern
  static final ImageProcessingService _instance =
      ImageProcessingService._internal();
  factory ImageProcessingService() => _instance;
  ImageProcessingService._internal();

  bool _compressPhotos = true;
  String _selectedQuality = 'Medium';

  // Compression quality levels (0-100)
  final Map<String, int> _qualityLevels = {
    'Low': 30,
    'Medium': 60,
    'High': 85,
    'Original': 100,
  };

  // Getters
  bool get compressPhotos => _compressPhotos;
  String get selectedQuality => _selectedQuality;

  Future<void> init() async {
    await loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _compressPhotos = prefs.getBool('compressPhotos') ?? true;
    _selectedQuality = prefs.getString('photoQuality') ?? 'Medium';
    notifyListeners();
  }

  Future<void> updateSettings({
    required bool compressPhotos,
    required String photoQuality,
  }) async {
    _compressPhotos = compressPhotos;
    _selectedQuality = photoQuality;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('compressPhotos', _compressPhotos);
    await prefs.setString('photoQuality', _selectedQuality);

    notifyListeners();
  }

  // Process image files according to compression settings
  Future<List<File>> processImages(List<File> originalFiles) async {
    // If compression is disabled or quality is set to Original, return the original files
    if (!_compressPhotos || _selectedQuality == 'Original') {
      return originalFiles;
    }

    final List<File> processedFiles = [];
    final tempDir = await getTemporaryDirectory();
    final quality = _qualityLevels[_selectedQuality] ?? 60; // Default to Medium

    for (final originalFile in originalFiles) {
      try {
        // For now, we'll just copy the file to simulate compression
        // In a real implementation, you would use a package like flutter_image_compress
        // to actually compress the image

        final String fileName =
            '${const Uuid().v4()}${path.extension(originalFile.path)}';
        final String filePath = '${tempDir.path}/$fileName';

        // Copy with "compression" (simulated)
        final File newFile = await originalFile.copy(filePath);

        // In a real implementation, you would compress the image here
        // For example:
        // final compressedFile = await FlutterImageCompress.compressAndGetFile(
        //   originalFile.path,
        //   filePath,
        //   quality: quality,
        // );

        processedFiles.add(newFile);
        debugPrint('Processed image with quality: $quality% - $filePath');
      } catch (e) {
        debugPrint('Error processing image: $e');
        // If processing fails, use the original file
        processedFiles.add(originalFile);
      }
    }

    return processedFiles;
  }
}
