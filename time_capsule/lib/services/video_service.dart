import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive/hive.dart';
import 'package:time_capsule/models/liked_video.dart';

class VideoService extends ChangeNotifier {
  // Singleton pattern
  static final VideoService _instance = VideoService._internal();
  factory VideoService() => _instance;
  VideoService._internal() {
    _initialize();
  }

  final ImagePicker _picker = ImagePicker();
  final List<File> _deviceVideos = [];
  final List<LikedVideo> _likedVideos = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _currentVideoIndex = 0;
  late Box<LikedVideo> _likedVideosBox;
  bool _permissionsGranted = false;

  List<File> get deviceVideos => _deviceVideos;
  List<LikedVideo> get likedVideos => _likedVideos;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get currentVideoIndex => _currentVideoIndex;
  File? get currentVideo =>
      _deviceVideos.isNotEmpty ? _deviceVideos[_currentVideoIndex] : null;
  bool get permissionsGranted => _permissionsGranted;

  Future<void> _initialize() async {
    await _openHiveBox();
    await loadLikedVideos();
    // Don't request permissions immediately - wait for user to navigate to For You tab
  }

  Future<void> _openHiveBox() async {
    try {
      _likedVideosBox = await Hive.openBox<LikedVideo>('likedVideos');
      debugPrint('Liked videos box opened successfully');
    } catch (e) {
      debugPrint('Error opening liked videos box: $e');
      _errorMessage = 'Failed to initialize video storage: $e';
    }
  }

  Future<bool> requestPermission() async {
    try {
      _setLoading(true);

      // For Android 13+ (SDK 33+)
      final mediaVideoStatus = await Permission.videos.request();
      final mediaImagesStatus = await Permission.photos.request();

      // For Android 12 and below
      final storageStatus = await Permission.storage.request();

      // Check if any permission is granted
      final bool granted =
          mediaVideoStatus.isGranted ||
          storageStatus.isGranted ||
          mediaImagesStatus.isGranted;

      debugPrint('Video permissions request result:');
      debugPrint('- videos: ${mediaVideoStatus.isGranted}');
      debugPrint('- photos: ${mediaImagesStatus.isGranted}');
      debugPrint('- storage: ${storageStatus.isGranted}');

      _permissionsGranted = granted;

      if (!granted) {
        _errorMessage = 'Permission to access videos is required';
        debugPrint('❌ Video permissions denied');
      } else {
        debugPrint('✅ Video permissions granted');
        _errorMessage = null;
      }

      notifyListeners();
      return granted;
    } catch (e) {
      debugPrint('❌ Error requesting permissions: $e');
      _errorMessage = 'Error requesting permissions: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadDeviceVideos() async {
    try {
      _setLoading(true);
      _deviceVideos.clear();

      // Request permissions if not already granted
      if (!_permissionsGranted) {
        final permissionsGranted = await requestPermission();
        if (!permissionsGranted) {
          debugPrint('Cannot load videos - permissions not granted');
          return;
        }
      }

      // Let the user pick videos
      try {
        // Delayed to avoid setState during build
        await Future.delayed(const Duration(milliseconds: 300));

        final XFile? pickedVideo = await _picker.pickVideo(
          source: ImageSource.gallery,
        );

        if (pickedVideo != null) {
          _deviceVideos.add(File(pickedVideo.path));
          debugPrint('✅ Added video: ${pickedVideo.path}');
        } else {
          debugPrint('No video selected by user');
        }
      } catch (e) {
        debugPrint('❌ Error picking video: $e');
        _errorMessage = 'Error picking video: $e';
      }

      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loading device videos: $e');
      _errorMessage = 'Error loading videos: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadLikedVideos() async {
    try {
      _likedVideos.clear();

      if (_likedVideosBox.isOpen) {
        _likedVideos.addAll(_likedVideosBox.values);
        debugPrint('Loaded ${_likedVideos.length} liked videos');
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading liked videos: $e');
      _errorMessage = 'Error loading liked videos: $e';
    }
  }

  Future<void> toggleLike(String videoPath) async {
    try {
      // Check if video is already liked
      final existingIndex = _likedVideos.indexWhere(
        (v) => v.videoPath == videoPath,
      );

      if (existingIndex >= 0) {
        // Video exists in liked videos, toggle its status
        final video = _likedVideos[existingIndex];
        video.isLiked = !video.isLiked;

        if (video.isLiked) {
          await _likedVideosBox.put(video.id, video);
          debugPrint('Video marked as liked again: ${video.id}');
        } else {
          await _likedVideosBox.delete(video.id);
          _likedVideos.removeAt(existingIndex);
          debugPrint('Video removed from likes: ${video.id}');
        }
      } else {
        // Video is not in liked videos, add it
        final newLikedVideo = LikedVideo(videoPath: videoPath);
        await _likedVideosBox.put(newLikedVideo.id, newLikedVideo);
        _likedVideos.add(newLikedVideo);
        debugPrint('New video liked: ${newLikedVideo.id}');
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling like for video: $e');
      _errorMessage = 'Error updating liked status: $e';
    }
  }

  bool isVideoLiked(String videoPath) {
    return _likedVideos.any((v) => v.videoPath == videoPath && v.isLiked);
  }

  void nextVideo() {
    if (_deviceVideos.isNotEmpty) {
      _currentVideoIndex = (_currentVideoIndex + 1) % _deviceVideos.length;
      notifyListeners();
    }
  }

  void previousVideo() {
    if (_deviceVideos.isNotEmpty) {
      _currentVideoIndex =
          (_currentVideoIndex - 1 + _deviceVideos.length) %
          _deviceVideos.length;
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
