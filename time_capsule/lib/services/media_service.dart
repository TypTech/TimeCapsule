import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
// Removing photo_manager import
import 'image_processing_service.dart';
import 'package:time_capsule/models/capsule.dart';
import 'package:time_capsule/services/local_storage_service.dart';
// Remove flutter_easyloading import
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// Temporarily commented out due to dependency issues
// import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
// import 'package:ffmpeg_kit_flutter/return_code.dart';

class MediaService extends ChangeNotifier {
  // Singleton pattern
  static final MediaService _instance = MediaService._internal();
  factory MediaService() => _instance;
  MediaService._internal() {
    _initialize();
  }

  final ImagePicker _picker = ImagePicker();
  final ImageProcessingService _imageProcessingService =
      ImageProcessingService();
  final List<File> _selectedPhotos = [];
  bool _isLoading = false;
  String? _errorMessage;
  final LocalStorageService _storageService = LocalStorageService();
  bool _isCapsuleCreationMode = false;

  // Old photos for home screen display (simplified implementation)
  List<File> _oldPhotos = [];
  DateTime? _oldestPhotoDate;

  List<File> get selectedPhotos => _selectedPhotos;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isCapsuleCreationMode => _isCapsuleCreationMode;
  List<File> get oldPhotos => _oldPhotos;
  DateTime? get oldestPhotoDate => _oldestPhotoDate;

  // Get capsules from the storage service
  List<TimeCapsule> get capsules => _storageService.capsules;

  // Aktivieren des Kapsel-Erstellungsmodus
  void startCapsuleCreation() {
    _isCapsuleCreationMode = true;
    _selectedPhotos.clear();
    _errorMessage = null;
    notifyListeners();
  }

  // Deaktivieren des Kapsel-Erstellungsmodus
  void endCapsuleCreation() {
    _isCapsuleCreationMode = false;
    _selectedPhotos.clear();
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _initialize() async {
    await requestPermission();
    await loadOldPhotos();
  }

  Future<bool> requestPermission() async {
    try {
      final photosStatus = await Permission.photos.request();
      final storageStatus = await Permission.storage.request();

      final granted = photosStatus.isGranted || storageStatus.isGranted;

      if (!granted) {
        _errorMessage = 'Permission to access photos is required';
        notifyListeners();
      }

      return granted;
    } catch (e) {
      _errorMessage = 'Error requesting permissions: $e';
      notifyListeners();
      return false;
    }
  }

  // Modified method to load old photos for home screen display
  Future<void> loadOldPhotos() async {
    try {
      _setLoading(true);
      _oldPhotos = [];

      // Check if we have permission
      if (!(await Permission.photos.isGranted)) {
        debugPrint('No permission to access photos');
        return;
      }

      // First, try to use photos from existing capsules
      if (_storageService.capsules.isNotEmpty) {
        debugPrint('Using photos from existing time capsules for home display');
        final allCapsulePhotos = <File>[];
        final Map<File, DateTime> photoDateMap = {};

        // Collect photos from all capsules with their creation dates
        for (final capsule in _storageService.capsules) {
          for (final photoPath in capsule.photoUrls) {
            final photoFile = File(photoPath);
            if (await photoFile.exists()) {
              allCapsulePhotos.add(photoFile);
              // Use capsule creation date as a proxy for photo date
              photoDateMap[photoFile] = capsule.createdAt;
            }
          }
        }

        // Sort photos by date (oldest first)
        allCapsulePhotos.sort(
          (a, b) =>
              photoDateMap[a]?.compareTo(photoDateMap[b] ?? DateTime.now()) ??
              0,
        );

        // Use up to 10 photos from capsules
        if (allCapsulePhotos.isNotEmpty) {
          _oldPhotos = allCapsulePhotos.take(10).toList();
          _oldestPhotoDate = photoDateMap[_oldPhotos.first];
          debugPrint(
            'Added ${_oldPhotos.length} old photos to home screen, oldest from: ${_oldestPhotoDate?.toString() ?? "unknown date"}',
          );
        }
      }

      // If we still have no photos, prompt the user to select some
      if (_oldPhotos.isEmpty) {
        debugPrint('No old photos found, prompting user to select photos');
        // Don't use EasyLoading as it's causing initialization issues

        // Let the user pick some photos
        final List<XFile> pickedPhotos = await _picker.pickMultiImage();
        if (pickedPhotos.isNotEmpty) {
          // Try to get creation date from image properties (this is simplified)
          // In a real implementation, we would use exif data to get actual photo dates
          final now = DateTime.now();
          final sixMonthsAgo = now.subtract(const Duration(days: 180));

          _oldPhotos =
              pickedPhotos.take(10).map((xFile) => File(xFile.path)).toList();

          // Set a date for display purposes
          _oldestPhotoDate = sixMonthsAgo;
          debugPrint(
            'Added ${_oldPhotos.length} user-selected photos to home screen',
          );
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading old photos: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Simplified method to get a thumbnail for a photo
  Future<Uint8List?> getOldPhotoThumbnail(File photo, {int size = 200}) async {
    try {
      // Read the file into memory
      final bytes = await photo.readAsBytes();
      return bytes;
    } catch (e) {
      debugPrint('Error loading thumbnail: $e');
      return null;
    }
  }

  Future<File?> pickSingleImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile == null) return null;

      final File imageFile = File(pickedFile.path);
      final processedFiles = await _imageProcessingService.processImages([
        imageFile,
      ]);

      if (processedFiles.isNotEmpty) {
        _selectedPhotos.add(processedFiles.first);
        notifyListeners();
        return processedFiles.first;
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  Future<List<File>> pickMultipleImages() async {
    try {
      if (!_isCapsuleCreationMode) {
        debugPrint('Cannot pick images outside of capsule creation mode');
        return [];
      }

      final List<XFile> pickedFiles = await _picker.pickMultiImage();

      if (pickedFiles.isEmpty) return [];

      final List<File> imageFiles =
          pickedFiles.map((xFile) => File(xFile.path)).toList();
      final processedFiles = await _imageProcessingService.processImages(
        imageFiles,
      );

      _selectedPhotos.addAll(processedFiles);
      notifyListeners();
      return processedFiles;
    } catch (e) {
      debugPrint('Error picking multiple images: $e');
      return [];
    }
  }

  Future<File?> takePhoto() async {
    try {
      if (!_isCapsuleCreationMode) {
        debugPrint('Cannot take photo outside of capsule creation mode');
        _errorMessage = 'Photos can only be added when creating a capsule';
        notifyListeners();
        return null;
      }

      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
      );

      if (pickedFile == null) return null;

      final File imageFile = File(pickedFile.path);
      final processedFiles = await _imageProcessingService.processImages([
        imageFile,
      ]);

      if (processedFiles.isNotEmpty) {
        _selectedPhotos.add(processedFiles.first);
        notifyListeners();
        return processedFiles.first;
      }
      return null;
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

  // Clear all selected photos
  void clearPhotos() {
    _selectedPhotos.clear();
    notifyListeners();
  }

  Future<List<String>> saveSelectedPhotos() async {
    final List<String> savedPaths = [];

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final String timeCapsuleDir = '${appDir.path}/time_capsule_photos';

      // Create directory if it doesn't exist
      final directory = Directory(timeCapsuleDir);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Save each photo
      for (final File photo in _selectedPhotos) {
        final String fileName =
            '${const Uuid().v4()}${path.extension(photo.path)}';
        final String destPath = '$timeCapsuleDir/$fileName';

        final File savedFile = await photo.copy(destPath);
        savedPaths.add(savedFile.path);
      }

      return savedPaths;
    } catch (e) {
      debugPrint('Error saving photos: $e');
      return savedPaths;
    }
  }

  Future<File?> createVideoCollage({
    required List<File> photos,
    required String musicPath,
    required String outputPath,
    Duration photoDuration = const Duration(seconds: 3),
  }) async {
    if (photos.isEmpty) {
      _setError('No photos selected');
      return null;
    }

    try {
      _setLoading(true);
      _clearError();

      // Temporarily replaced with placeholder implementation
      await Future.delayed(Duration(seconds: 2)); // Simulate processing time

      // Just return the first photo as a placeholder
      // In a real implementation, this would create a video
      _setError('Video creation temporarily disabled');
      return photos.first;

      /* Original implementation commented out
      final tempDir = await getTemporaryDirectory();
      final outputFile = File('$tempDir/time_capsule_video.mp4');

      // Build FFmpeg command to create video from images
      // This is a basic implementation; a real app would have more advanced options

      final inputFiles = photos.map((photo) => '-i "${photo.path}"').join(' ');
      final filterComplex = _buildFilterComplex(photos.length, photoDuration);

      final command =
          '$inputFiles -i "$musicPath" $filterComplex '
          '-map "[v]" -map 1:a -shortest -c:v libx264 -c:a aac -pix_fmt yuv420p '
          '"${outputFile.path}"';

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        return outputFile;
      } else {
        final log = await session.getOutput();
        _setError('Failed to create video: $log');
        return null;
      }
      */
    } catch (e) {
      _setError('Failed to create video: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  String _buildFilterComplex(int photoCount, Duration photoDuration) {
    // This is a simplified filter complex for FFmpeg
    // Real implementation would be more sophisticated
    final transitions = <String>[];
    final duration = photoDuration.inSeconds;

    for (int i = 0; i < photoCount; i++) {
      transitions.add(
        '[$i:v]scale=1280:720:force_original_aspect_ratio=decrease,'
        'pad=1280:720:(ow-iw)/2:(oh-ih)/2,setsar=1,fade=t=in:st=0:d=0.5,'
        'fade=t=out:st=${duration - 0.5}:d=0.5[v$i]',
      );
    }

    String concat = '';
    for (int i = 0; i < photoCount; i++) {
      concat += '[v$i]';
    }

    concat += 'concat=n=$photoCount:v=1:a=0[v]';

    return '-filter_complex "${transitions.join('; ')};$concat"';
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Initialize storage
  Future<void> initialize() async {
    if (_isLoading) return;

    try {
      _setLoading(true);

      // Initialize storage service first
      await _storageService.init();

      // Load existing capsules
      await _storageService.loadCapsules();

      debugPrint('MediaService initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize MediaService: $e');
      _errorMessage = 'Failed to initialize: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Save a new capsule with selected photos
  Future<bool> saveCapsule({
    required String title,
    required String description,
    required String theme,
  }) async {
    if (_selectedPhotos.isEmpty) {
      _errorMessage = 'Please select at least one photo';
      notifyListeners();
      return false;
    }

    try {
      _setLoading(true);

      // Debug logs
      debugPrint('=== SAVING CAPSULE ===');
      debugPrint('Title: $title');
      debugPrint('Description: $description');
      debugPrint('Theme: $theme');
      debugPrint('Photos count: ${_selectedPhotos.length}');

      // Ensure storage service is initialized
      try {
        debugPrint('Initializing storage service...');
        await _storageService.init();
        debugPrint('Storage service initialized successfully');
      } catch (e) {
        debugPrint('Error initializing storage service: $e');
      }

      // Make a copy of the selected photos to avoid concurrent modification issues
      final List<File> photosToSave = List<File>.from(_selectedPhotos);
      debugPrint('Prepared photos for saving: ${photosToSave.length}');

      // Create the capsule using the storage service
      final success = await _storageService.createCapsule(
        title: title,
        description: description,
        theme: theme,
        photos: photosToSave,
      );

      if (success) {
        debugPrint('✅ Capsule created successfully');

        // Explicitly reload the capsules list after creating a new one
        debugPrint('Reloading capsules list...');
        await _storageService.loadCapsules();

        // Print the number of loaded capsules
        final capsuleCount = _storageService.capsules.length;
        debugPrint('✅ Loaded $capsuleCount capsules after saving');

        // Clear the selected photos
        clearPhotos();
        debugPrint('Selected photos cleared');

        notifyListeners(); // Notify listeners that data has changed
        return true;
      } else {
        debugPrint('❌ Failed to create capsule');
        _errorMessage = 'Failed to create capsule';
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error creating capsule: $e');
      _errorMessage = 'Error creating capsule: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete a capsule
  Future<bool> deleteCapsule(String capsuleId) async {
    try {
      _setLoading(true);

      final success = await _storageService.deleteCapsule(capsuleId);

      return success;
    } catch (e) {
      _errorMessage = 'Error deleting capsule: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Refresh capsules list
  Future<void> refreshCapsules() async {
    if (_isLoading) return;

    try {
      _setLoading(true);
      await _storageService.loadCapsules();
    } catch (e) {
      _errorMessage = 'Failed to refresh capsules: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Get newest capsules
  List<TimeCapsule> getNewestCapsules([int limit = 5]) {
    return _storageService.getNewestCapsules(limit);
  }
}
