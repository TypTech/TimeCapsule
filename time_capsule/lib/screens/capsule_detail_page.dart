import 'dart:io';
import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class CapsuleDetailPage extends StatefulWidget {
  final String capsuleId;

  const CapsuleDetailPage({super.key, required this.capsuleId});

  @override
  State<CapsuleDetailPage> createState() => _CapsuleDetailPageState();
}

class _CapsuleDetailPageState extends State<CapsuleDetailPage> {
  final LocalStorageService _storageService = LocalStorageService();
  bool _isLoading = true;
  bool _isDeleting = false;
  TimeCapsule? _capsule;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCapsule();
  }

  Future<void> _loadCapsule() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _storageService.init();
      await _storageService.loadCapsules();

      // Find the capsule by ID
      final capsule = _storageService.capsules.firstWhere(
        (c) => c.id == widget.capsuleId,
      );

      setState(() {
        _capsule = capsule;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load capsule: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteCapsule() async {
    // Show confirmation dialog
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Capsule'),
            content: const Text(
              'Are you sure you want to delete this capsule? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (shouldDelete != true) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      final success = await _storageService.deleteCapsule(widget.capsuleId);

      if (success) {
        Navigator.pop(context); // Go back to previous screen
      } else {
        setState(() {
          _errorMessage = 'Failed to delete capsule';
          _isDeleting = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error deleting capsule: $e';
        _isDeleting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Show loading state
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Capsule Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Show error state
    if (_errorMessage != null || _capsule == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Capsule Details')),
        body: Center(
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
                  _errorMessage ?? 'Capsule not found',
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final capsule = _capsule!;

    return Scaffold(
      appBar: AppBar(
        title: Text(capsule.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: _isDeleting ? null : _deleteCapsule,
          ),
        ],
      ),
      body:
          _isDeleting
              ? const Center(child: CircularProgressIndicator())
              : _buildCapsuleDetails(theme, capsule),
    );
  }

  Widget _buildCapsuleDetails(ThemeData theme, TimeCapsule capsule) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header information
          Text(
            capsule.title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 16,
                color: theme.colorScheme.primary.withOpacity(0.7),
              ),
              const SizedBox(width: 6),
              Text(
                'Created on ${DateFormat('MMMM d, yyyy').format(capsule.createdAt)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
            ],
          ),

          // Description
          if (capsule.description.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('Description', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(capsule.description, style: theme.textTheme.bodyMedium),
          ],

          // Photos
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Photos', style: theme.textTheme.titleMedium),
              Text(
                '${capsule.photoFilePaths.length} photos',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Photo grid
          if (capsule.photoFilePaths.isEmpty)
            _buildEmptyPhotosMessage(theme)
          else
            _buildPhotoGrid(theme, capsule.photoFilePaths),

          const SizedBox(height: 30),

          // Theme info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.style_rounded,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Theme', style: theme.textTheme.titleSmall),
                        Text(capsule.theme, style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildEmptyPhotosMessage(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 48,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No photos in this capsule',
              style: theme.textTheme.titleSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoGrid(ThemeData theme, List<String> photoPaths) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: photoPaths.length,
      itemBuilder: (context, index) {
        final path = photoPaths[index];
        return GestureDetector(
          onTap: () => _showFullScreenImage(context, path, index, photoPaths),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(path),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  child: Center(
                    child: Icon(
                      Icons.broken_image_rounded,
                      color: theme.colorScheme.error,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showFullScreenImage(
    BuildContext context,
    String imagePath,
    int initialIndex,
    List<String> allPaths,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => FullScreenImageView(
              imagePaths: allPaths,
              initialIndex: initialIndex,
            ),
      ),
    );
  }
}

class FullScreenImageView extends StatefulWidget {
  final List<String> imagePaths;
  final int initialIndex;

  const FullScreenImageView({
    super.key,
    required this.imagePaths,
    required this.initialIndex,
  });

  @override
  State<FullScreenImageView> createState() => _FullScreenImageViewState();
}

class _FullScreenImageViewState extends State<FullScreenImageView> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openImageWithExternalApp() async {
    try {
      final imagePath = widget.imagePaths[_currentIndex];
      final file = File(imagePath);

      if (await file.exists()) {
        final uri = Uri.file(file.path);

        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          debugPrint('Opening image: $uri');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open image with any app'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image file not found'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error opening image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to open image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _shareImage() {
    // In a real implementation, you'd use packages like share_plus
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing image...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _downloadImage() async {
    try {
      final imagePath = widget.imagePaths[_currentIndex];

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image saved to gallery'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        title: Text(
          '${_currentIndex + 1} / ${widget.imagePaths.length}',
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.remove_red_eye),
            tooltip: 'View with external app',
            onPressed: _openImageWithExternalApp,
          ),
          IconButton(
            icon: Icon(Icons.share),
            tooltip: 'Share image',
            onPressed: _shareImage,
          ),
          IconButton(
            icon: Icon(Icons.download),
            tooltip: 'Save to gallery',
            onPressed: _downloadImage,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Image PageView
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imagePaths.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 3.0,
                  child: Image.file(
                    File(widget.imagePaths[index]),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.broken_image_rounded,
                            size: 64,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Failed to load image',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Attempting to repair image...',
                                  ),
                                ),
                              );
                            },
                            icon: Icon(Icons.refresh),
                            label: Text('Try to repair'),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              );
            },
          ),

          // Bottom controls overlay
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed:
                        _currentIndex > 0
                            ? () {
                              _pageController.previousPage(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                            : null,
                  ),
                  IconButton(
                    iconSize: 36,
                    icon: Icon(Icons.visibility, color: Colors.white),
                    onPressed: _openImageWithExternalApp,
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward_ios, color: Colors.white),
                    onPressed:
                        _currentIndex < widget.imagePaths.length - 1
                            ? () {
                              _pageController.nextPage(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                            : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
