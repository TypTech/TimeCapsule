import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;
import 'image_processing_service.dart';
import 'package:time_capsule/models/capsule.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

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

  // Convert to Capsule model
  Capsule toCapsule() {
    return Capsule(
      id: id,
      title: title,
      description: description,
      theme: theme,
      imagePaths: photoFilePaths,
      createdAt: createdAt,
    );
  }
}

class LocalStorageService extends ChangeNotifier {
  static const String _boxName = 'timeCapsules';
  static const String _capsulesBoxName = 'capsules';

  Box<dynamic>? _box;
  Box<Capsule>? _capsulesBox;

  List<TimeCapsule> _capsules = [];
  String? _error;
  bool _isLoading = false;
  bool _initialized = false;

  // Getters
  List<TimeCapsule> get capsules => _capsules;
  String? get error => _error;
  bool get isLoading => _isLoading;

  // No user in local storage mode

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

      // Register adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(CapsuleAdapter());
      }

      // Open the old box for backward compatibility
      _box = await Hive.openBox(_boxName);
      debugPrint('Hive box opened: $_boxName');

      // Open the new box for Capsule objects
      _capsulesBox = await Hive.openBox<Capsule>(_capsulesBoxName);
      debugPrint('Hive box opened: $_capsulesBoxName');

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

  // Force reinitialization by closing and reopening boxes
  Future<void> reinitialize() async {
    try {
      _setLoading(true);
      _clearError();

      // Close boxes if they're open
      if (_box != null && _box!.isOpen) {
        await _box!.close();
        debugPrint('Closed box: $_boxName');
      }

      if (_capsulesBox != null && _capsulesBox!.isOpen) {
        await _capsulesBox!.close();
        debugPrint('Closed box: $_capsulesBoxName');
      }

      // Reset initialized flag
      _initialized = false;

      // Reinitialize
      await init();

      debugPrint('Storage service reinitialized successfully');
    } catch (e) {
      debugPrint('Error reinitializing storage: $e');
      _setError('Failed to reinitialize storage: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Make sure the box is open
  Future<void> _ensureBoxOpen() async {
    if (_box == null ||
        !(_box!.isOpen) ||
        _capsulesBox == null ||
        !_capsulesBox!.isOpen) {
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

      // Get all data from the old box
      final data = _box!.values.toList();
      debugPrint('Loaded ${data.length} legacy capsules from storage');

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
          debugPrint('Loaded legacy capsule: ${capsule.id} - ${capsule.title}');
        } catch (e) {
          debugPrint('Error parsing legacy capsule: $e');
        }
      }

      // Get all capsules from the new box
      if (_capsulesBox != null) {
        final capsules = _capsulesBox!.values.toList();
        debugPrint('Loaded ${capsules.length} new capsules from storage');

        // Convert Capsule to TimeCapsule for backward compatibility
        for (var capsule in capsules) {
          final timeCapsule = TimeCapsule(
            id: capsule.id,
            title: capsule.title,
            description: capsule.description,
            theme: capsule.theme,
            photoFilePaths: capsule.imagePaths,
            createdAt: capsule.createdAt,
          );

          // Replace any existing capsule with the same ID or add it
          final existingIndex = _capsules.indexWhere((c) => c.id == capsule.id);
          if (existingIndex >= 0) {
            _capsules[existingIndex] = timeCapsule;
          } else {
            _capsules.add(timeCapsule);
          }
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
    String description = '',
  }) async {
    try {
      _setLoading(true);
      _clearError();

      await _ensureBoxOpen();
      debugPrint('Hive boxes ensured open for saving capsule');

      // Create a unique ID for the capsule
      final uuid = const Uuid().v4();
      debugPrint('Generated UUID for new capsule: $uuid');

      // Get the app's public directory for storing photos
      Directory? baseDir;
      if (Platform.isAndroid) {
        // Für Android: Speichere in einem öffentlichen Verzeichnis
        baseDir = await getExternalStorageDirectory();

        // Falls das fehlschlägt, versuche eine Alternative
        if (baseDir == null) {
          baseDir = await getApplicationDocumentsDirectory();
          debugPrint(
            'Verwende Anwendungsverzeichnis als Fallback: ${baseDir.path}',
          );
        } else {
          debugPrint('Verwende externes Speicherverzeichnis: ${baseDir.path}');
        }
      } else {
        // Für iOS und andere: Verwende das Dokumente-Verzeichnis
        baseDir = await getApplicationDocumentsDirectory();
        debugPrint('Verwende Anwendungsverzeichnis: ${baseDir.path}');
      }

      // Erstelle ein Verzeichnis für alle TimeCapsules
      final timecapsuleBaseDir = Directory('${baseDir.path}/TimeCapsule');
      if (!await timecapsuleBaseDir.exists()) {
        await timecapsuleBaseDir.create(recursive: true);
        debugPrint(
          'TimeCapsule-Basisverzeichnis erstellt: ${timecapsuleBaseDir.path}',
        );
      } else {
        debugPrint(
          'TimeCapsule-Basisverzeichnis existiert bereits: ${timecapsuleBaseDir.path}',
        );
      }

      // Erstelle ein Verzeichnis für diese spezifische Capsule
      final capsuleDir = Directory('${timecapsuleBaseDir.path}/$uuid');
      if (!await capsuleDir.exists()) {
        await capsuleDir.create(recursive: true);
        debugPrint('Capsule-Verzeichnis erstellt: ${capsuleDir.path}');
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

      // Erstelle eine JSON-Datei mit den Capsule-Metadaten im Verzeichnis
      final metadataFile = File('${capsuleDir.path}/metadata.json');
      final metadata = {
        'id': uuid,
        'title': title,
        'description': description,
        'theme': theme,
        'photoFilePaths': photoFilePaths,
        'createdAt': DateTime.now().toIso8601String(),
      };
      await metadataFile.writeAsString(jsonEncode(metadata));
      debugPrint('Metadata-Datei gespeichert: ${metadataFile.path}');

      // Create the capsule
      final timeCapsule = TimeCapsule(
        id: uuid,
        title: title,
        description: description,
        theme: theme,
        photoFilePaths: photoFilePaths,
        createdAt: DateTime.now(),
      );

      // Convert to new Capsule model
      final capsule = Capsule(
        id: uuid,
        title: title,
        description: description,
        theme: theme,
        imagePaths: photoFilePaths,
        createdAt: DateTime.now(),
      );

      // Save to old storage for backward compatibility
      final capsuleJson = timeCapsule.toJson();
      try {
        await _box!.add(capsuleJson);
        debugPrint('Added legacy capsule to box: ${timeCapsule.id}');
      } catch (e) {
        debugPrint('Error adding legacy capsule to box: $e');
      }

      // Save to new storage
      try {
        if (_capsulesBox != null) {
          await _capsulesBox!.put(capsule.id, capsule);
          debugPrint('Added capsule to new box: ${capsule.id}');
        } else {
          debugPrint('_capsulesBox is null, could not save capsule');
        }
      } catch (e) {
        debugPrint('Error adding capsule to new box: $e');
      }

      // Reload capsules
      try {
        await loadCapsules();
        debugPrint('Capsules reloaded after adding new capsule');
        debugPrint('Current capsule count: ${_capsules.length}');
      } catch (e) {
        debugPrint('Error reloading capsules: $e');
      }

      debugPrint('Capsule erfolgreich erstellt mit ID: $uuid');
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
      final capsuleIndex = _capsules.indexWhere((c) => c.id == capsuleId);
      if (capsuleIndex < 0) {
        _setError('Capsule not found');
        return false;
      }

      final capsule = _capsules[capsuleIndex];

      // Delete the photos
      try {
        for (final photoPath in capsule.photoFilePaths) {
          final file = File(photoPath);
          if (await file.exists()) {
            await file.delete();
            debugPrint('Deleted photo: $photoPath');
          }
        }

        // Delete the directory
        final appDir = await getApplicationDocumentsDirectory();
        final capsuleDir = Directory('${appDir.path}/timecapsules/$capsuleId');
        if (await capsuleDir.exists()) {
          await capsuleDir.delete(recursive: true);
          debugPrint('Deleted capsule directory: ${capsuleDir.path}');
        }
      } catch (e) {
        debugPrint('Error deleting photos: $e');
        // Continue even if photo deletion fails
      }

      // Delete from old box
      for (int i = 0; i < _box!.length; i++) {
        final item = _box!.getAt(i);
        if (item != null && item is Map && item['id'] == capsuleId) {
          await _box!.deleteAt(i);
          debugPrint('Deleted legacy capsule from box: $capsuleId');
          break;
        }
      }

      // Delete from new box
      if (_capsulesBox != null) {
        await _capsulesBox!.delete(capsuleId);
        debugPrint('Deleted capsule from new box: $capsuleId');
      }

      // Update the list
      _capsules.removeAt(capsuleIndex);
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('Error deleting capsule: $e');
      _setError('Failed to delete capsule: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get list of newest capsules
  List<TimeCapsule> getNewestCapsules([int limit = 5]) {
    return _capsules.take(limit).toList();
  }

  // Helper methods for loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}

// Placeholder class for backward compatibility
class User {
  final String email = "Local User";
}
