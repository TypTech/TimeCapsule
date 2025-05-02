import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';

class MediaService extends ChangeNotifier {
  // Singleton pattern
  static final MediaService _instance = MediaService._internal();
  factory MediaService() => _instance;
  MediaService._internal() {
    _initialize();
  }

  final ImagePicker _picker = ImagePicker();
  List<File> _selectedPhotos = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<File> get selectedPhotos => _selectedPhotos;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> _initialize() async {
    await requestPermission();
  }

  Future<bool> requestPermission() async {
    final permissionStatus = await Permission.photos.request();
    return permissionStatus.isGranted;
  }

  Future<File?> pickSingleImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile == null) return null;

      final File imageFile = File(pickedFile.path);
      _selectedPhotos.add(imageFile);
      notifyListeners();
      return imageFile;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  Future<List<File>> pickMultipleImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage();

      if (pickedFiles.isEmpty) return [];

      final List<File> imageFiles =
          pickedFiles.map((xFile) => File(xFile.path)).toList();

      _selectedPhotos.addAll(imageFiles);
      notifyListeners();
      return imageFiles;
    } catch (e) {
      debugPrint('Error picking multiple images: $e');
      return [];
    }
  }

  Future<File?> takePhoto() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
      );

      if (pickedFile == null) return null;

      final File imageFile = File(pickedFile.path);
      _selectedPhotos.add(imageFile);
      notifyListeners();
      return imageFile;
    } catch (e) {
      debugPrint('Error taking photo: $e');
      return null;
    }
  }

  void removePhoto(int index) {
    if (index >= 0 && index < _selectedPhotos.length) {
      _selectedPhotos.removeAt(index);
      notifyListeners();
    }
  }

  void clearSelectedPhotos() {
    _selectedPhotos.clear();
    notifyListeners();
  }
}
