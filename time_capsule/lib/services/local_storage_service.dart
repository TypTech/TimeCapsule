import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;
import 'image_processing_service.dart';

class TimeCapsule {
  final String id;
  final String title;
  final String description;
  final String theme;
  final List<String> photoFilePaths; // Local file paths
  final List<String> photoUrls; // For backward compatibility with old code
  final DateTime createdAt;

  TimeCapsule({
    required this.id,
    required this.title,
    this.description = '',
    required this.theme,
    required this.photoFilePaths,
    DateTime? createdAt,
  }) : photoUrls = photoFilePaths, // Same as photoFilePaths for compatibility
       createdAt = createdAt ?? DateTime.now();

  // For Hive storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'theme': theme,
      'photoFilePaths': photoFilePaths,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from json map
  factory TimeCapsule.fromJson(Map<String, dynamic> json) {
    return TimeCapsule(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      theme: json['theme'],
      photoFilePaths: List<String>.from(json['photoFilePaths']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class LocalStorageService extends ChangeNotifier {
  static const String _boxName = 'timeCapsules';
  Box<dynamic>? _box;
  List<TimeCapsule> _capsules = [];
  String? _error;
  bool _isLoading = false;
  bool _initialized = false;

  // Getters
  List<TimeCapsule> get capsules => _capsules;
  String? get error => _error;
  bool get isLoading => _isLoading;

  // No user in local storage mode
  User? get currentUser => null;

  // Singleton pattern to ensure only one instance exists
  static final LocalStorageService _instance = LocalStorageService._internal();

  // Factory constructor to return the same instance
  factory LocalStorageService() {
    return _instance;
  }

  // Private constructor for singleton
  LocalStorageService._internal();

  // Initialize Hive and open box
  Future<void> init() async {
    if (_initialized) return;

    try {
      _setLoading(true);
      _clearError();

      // Initialize Hive
      await Hive.initFlutter();

      // Open the box
      _box = await Hive.openBox(_boxName);
      debugPrint('Hive box opened: $_boxName');

      // Load the capsules
      await loadCapsules();

      _initialized = true;
    } catch (e) {
      debugPrint('Error initializing Hive: $e');
      _setError('Failed to initialize storage: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Make sure the box is open
  Future<void> _ensureBoxOpen() async {
    if (_box == null || !(_box!.isOpen)) {
      await init();
    }
  }

  // Load capsules from storage
  Future<void> loadCapsules() async {
    try {
      _setLoading(true);
      _clearError();

      await _ensureBoxOpen();

      _capsules = [];

      // Get all data from the box
      final data = _box!.values.toList();
      debugPrint('Loaded ${data.length} capsules from storage');

      for (var item in data) {
        try {
          final Map<String, dynamic> capsuleMap;
          if (item is Map) {
            capsuleMap = Map<String, dynamic>.from(item);
          } else {
            debugPrint('Invalid item in box: $item');
            continue;
          }

          final capsule = TimeCapsule.fromJson(capsuleMap);
          _capsules.add(capsule);
          debugPrint('Loaded capsule: ${capsule.id} - ${capsule.title}');
        } catch (e) {
          debugPrint('Error parsing capsule: $e');
        }
      }

      // Sort by creation date (newest first)
      _capsules.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading capsules: $e');
      _setError('Failed to load capsules: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Alias for loadCapsules to maintain compatibility
  Future<void> fetchUserCapsules() => loadCapsules();

  // Save photos locally and create a capsule
  Future<bool> createCapsule({
    required String title,
    required String theme,
    required List<File> photos,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      await _ensureBoxOpen();

      // Create a unique ID for the capsule
      final uuid = const Uuid().v4();

      // Get the app's documents directory for storing photos
      final appDir = await getApplicationDocumentsDirectory();
      final capsuleDir = Directory('${appDir.path}/timecapsules/$uuid');

      // Create the directory if it doesn't exist
      if (!await capsuleDir.exists()) {
        await capsuleDir.create(recursive: true);
      }

      // Process photos according to user settings
      List<File> processedPhotos = photos;
      try {
        // Try to get the ImageProcessingService if available
        final imageProcessingService = ImageProcessingService();
        processedPhotos = await imageProcessingService.processImages(photos);
        debugPrint(
          'Processed ${photos.length} photos based on user preferences',
        );
      } catch (e) {
        debugPrint('Error processing photos: $e - using originals');
        // Continue with original photos if processing fails
      }

      // Save the processed photos to the capsule directory
      final List<String> photoFilePaths = [];
      for (int i = 0; i < processedPhotos.length; i++) {
        final File photo = processedPhotos[i];
        final String fileName = '${i}_${path.basename(photo.path)}';
        final String filePath = '${capsuleDir.path}/$fileName';

        // Copy the file to the capsule directory
        final File newFile = await photo.copy(filePath);
        if (await newFile.exists()) {
          photoFilePaths.add(filePath);
          debugPrint('Saved photo to: $filePath');
        } else {
          debugPrint('Failed to save photo to: $filePath');
        }
      }

      // Create the capsule
      final capsule = TimeCapsule(
        id: uuid,
        title: title,
        description: '',
        theme: theme,
        photoFilePaths: photoFilePaths,
        createdAt: DateTime.now(),
      );

      // Convert to JSON
      final capsuleJson = capsule.toJson();

      // Save to Hive
      await _box!.add(capsuleJson);
      debugPrint('Added capsule to box: ${capsule.id}');

      // Reload capsules
      await loadCapsules();
      return true;
    } catch (e) {
      debugPrint('Error creating capsule: $e');
      _setError('Failed to create capsule: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete a capsule and its photos
  Future<bool> deleteCapsule(String capsuleId) async {
    try {
      _setLoading(true);
      _clearError();

      await _ensureBoxOpen();

      // Find the capsule
      final capsuleIndex = _capsules.indexWhere(
        (capsule) => capsule.id == capsuleId,
      );
      if (capsuleIndex == -1) {
        throw Exception('Capsule not found');
      }

      final capsule = _capsules[capsuleIndex];

      // Delete photo files
      for (final filePath in capsule.photoFilePaths) {
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
          debugPrint('Deleted photo: $filePath');
        }
      }

      // Try to delete the capsule directory
      final appDir = await getApplicationDocumentsDirectory();
      final capsuleDir = Directory('${appDir.path}/timecapsules/$capsuleId');
      if (await capsuleDir.exists()) {
        await capsuleDir.delete(recursive: true);
        debugPrint('Deleted directory: $capsuleDir');
      }

      // Find the key in the box
      int? boxIndex;
      final boxValues = _box!.values.toList();
      for (int i = 0; i < boxValues.length; i++) {
        final Map<dynamic, dynamic> item =
            boxValues[i] as Map<dynamic, dynamic>;
        if (item['id'] == capsuleId) {
          boxIndex = i;
          break;
        }
      }

      if (boxIndex != null) {
        await _box!.deleteAt(boxIndex);
        debugPrint('Deleted capsule from box at index: $boxIndex');
      }

      // Reload capsules
      await loadCapsules();
      return true;
    } catch (e) {
      debugPrint('Error deleting capsule: $e');
      _setError('Failed to delete capsule: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Clear all data - delete all capsules and photos
  Future<bool> clearAllData() async {
    try {
      _setLoading(true);
      _clearError();

      await _ensureBoxOpen();

      // Delete all photo files and directories
      final appDir = await getApplicationDocumentsDirectory();
      final baseDir = Directory('${appDir.path}/timecapsules');

      if (await baseDir.exists()) {
        await baseDir.delete(recursive: true);
        debugPrint('Deleted all TimeCapsule directories');
      }

      // Clear the Hive box
      await _box!.clear();
      debugPrint('Cleared all data from Hive box');

      // Reload (empty) capsules
      _capsules = [];
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('Error clearing data: $e');
      _setError('Failed to clear data: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Stub method for compatibility - no login needed for local storage
  Future<void> logout() async {
    // Does nothing in local storage mode
    return;
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}

// Placeholder class for backward compatibility
class User {
  final String email = "Local User";
}
