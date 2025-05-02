import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_capsule/services/video_service.dart';
import 'package:video_player/video_player.dart';

class ForYouPage extends StatefulWidget {
  const ForYouPage({super.key});

  @override
  State<ForYouPage> createState() => _ForYouPageState();
}

class _ForYouPageState extends State<ForYouPage> {
  late PageController _pageController;
  VideoPlayerController? _activeController;
  int _currentPage = 0;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Use a post-frame callback to avoid calling setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initVideoService();
    });
  }

  Future<void> _initVideoService() async {
    final videoService = Provider.of<VideoService>(context, listen: false);

    // First, request permissions
    if (!videoService.permissionsGranted) {
      final granted = await videoService.requestPermission();
      if (!granted && mounted) {
        // Permission denied, but we'll show UI for this
        setState(() {
          _isInitialized = true;
        });
        return;
      }
    }

    // Then load videos if we have permissions
    if (videoService.deviceVideos.isEmpty) {
      await videoService.loadDeviceVideos();
    }

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });

      if (videoService.deviceVideos.isNotEmpty) {
        _initializeController(videoService.deviceVideos.first);
      }
    }
  }

  Future<void> _initializeController(File videoFile) async {
    if (_activeController != null) {
      await _activeController!.dispose();
    }

    _activeController = VideoPlayerController.file(videoFile);

    await _activeController!.initialize();
    await _activeController!.setLooping(true);
    await _activeController!.play();
    setState(() {});
  }

  @override
  void dispose() {
    _pageController.dispose();
    _activeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videoService = Provider.of<VideoService>(context);
    final theme = Theme.of(context);

    if (videoService.isLoading || !_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show permission error view
    if (!videoService.permissionsGranted) {
      return _buildPermissionDeniedView(theme, videoService);
    }

    // Show general error view
    if (videoService.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: theme.colorScheme.error,
              size: 60,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                videoService.errorMessage!,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _initVideoService,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (videoService.deviceVideos.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.video_library_outlined,
                size: 60,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'No videos found',
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Add videos to see them here',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => videoService.loadDeviceVideos(),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Videos'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
          _initializeController(videoService.deviceVideos[index]);
        },
        itemCount: videoService.deviceVideos.length,
        itemBuilder: (context, index) {
          final video = videoService.deviceVideos[index];
          final isLiked = videoService.isVideoLiked(video.path);

          return Stack(
            fit: StackFit.expand,
            children: [
              // Video player
              if (_activeController != null &&
                  _activeController!.value.isInitialized)
                GestureDetector(
                  onTap: () {
                    if (_activeController!.value.isPlaying) {
                      _activeController!.pause();
                    } else {
                      _activeController!.play();
                    }
                    setState(() {});
                  },
                  child: VideoPlayer(_activeController!),
                ),

              // Video controls overlay
              Positioned(
                right: 16,
                bottom: 80,
                child: Column(
                  children: [
                    // Like button
                    IconButton(
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.white,
                        size: 32,
                      ),
                      onPressed: () => videoService.toggleLike(video.path),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Like',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Share button
                    IconButton(
                      icon: const Icon(
                        Icons.share_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: () {
                        // Implement share functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Share functionality not implemented yet',
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Share',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Play/pause indicator
              if (_activeController != null)
                Center(
                  child: AnimatedOpacity(
                    opacity: _activeController!.value.isPlaying ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => videoService.loadDeviceVideos(),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildPermissionDeniedView(
    ThemeData theme,
    VideoService videoService,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.no_photography,
              color: theme.colorScheme.error,
              size: 64,
            ),
            const SizedBox(height: 24),
            Text(
              'Permission Required',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'To view videos in the For You section, you need to grant permission to access your media files.',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () async {
                final granted = await videoService.requestPermission();
                if (granted && mounted) {
                  // If permission granted, load videos
                  videoService.loadDeviceVideos();
                }
              },
              icon: const Icon(Icons.perm_media),
              label: const Text('Grant Permission'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
