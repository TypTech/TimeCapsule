import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_capsule/services/media_service.dart';
import 'package:time_capsule/utils/app_theme.dart';
import 'package:time_capsule/screens/photo_selection_screen.dart';

class CreateCapsuleScreen extends StatefulWidget {
  const CreateCapsuleScreen({super.key});

  @override
  State<CreateCapsuleScreen> createState() => _CreateCapsuleScreenState();
}

class _CreateCapsuleScreenState extends State<CreateCapsuleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();

  ThemeStyle _selectedTheme = ThemeStyle.minimal;
  String? _selectedMusicPath;
  bool _isCreating = false;
  String? _error;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _createTimeCapsule() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final mediaService = Provider.of<MediaService>(context, listen: false);

    if (mediaService.selectedPhotos.isEmpty) {
      setState(() {
        _error = 'Please select at least one photo';
      });
      return;
    }

    setState(() {
      _isCreating = true;
      _error = null;
    });

    try {
      // In a real app, we would have multiple music options
      // For development, we'll skip the actual music file
      final musicPath = _selectedMusicPath ?? 'assets/music/default.mp3';

      // Simulate video creation delay
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isCreating = false;
        // Success message instead of error
        _error = "TimeCapsule created successfully! (Development mode)";
      });
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
      });
    } finally {
      setState(() {
        _isCreating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaService = Provider.of<MediaService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create TimeCapsule'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => mediaService.clearSelectedPhotos(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Selected photos preview
          Container(
            height: 120,
            padding: const EdgeInsets.all(8),
            child:
                mediaService.selectedPhotos.isEmpty
                    ? const Center(child: Text('No photos selected'))
                    : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: mediaService.selectedPhotos.length,
                      itemBuilder: (context, index) {
                        return _buildPhotoPreview(
                          context,
                          mediaService.selectedPhotos[index],
                          index,
                          mediaService,
                        );
                      },
                    ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title input
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        hintText: 'Enter a title for your TimeCapsule',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Add Photos button
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add_photo_alternate),
                      label: const Text('Add Photos'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PhotoSelectionScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Theme selection
                    const Text(
                      'Select Theme',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: ThemeStyle.values.length,
                        itemBuilder: (context, index) {
                          final theme = ThemeStyle.values[index];
                          final isSelected = theme == _selectedTheme;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedTheme = theme;
                              });
                            },
                            child: Container(
                              width: 80,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? AppTheme.primaryColor
                                        : Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    isSelected
                                        ? Border.all(
                                          color: AppTheme.accentColor,
                                          width: 2,
                                        )
                                        : null,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _getThemeIcon(theme),
                                    color:
                                        isSelected
                                            ? Colors.white
                                            : Colors.grey[600],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _getThemeName(theme),
                                    style: TextStyle(
                                      color:
                                          isSelected
                                              ? Colors.white
                                              : Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Error and create button
                    if (_error != null) ...[
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:
                              _error!.contains('successfully')
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _error!,
                          style: TextStyle(
                            color:
                                _error!.contains('successfully')
                                    ? Colors.green
                                    : Colors.red,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isCreating ? null : _createTimeCapsule,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child:
                            _isCreating
                                ? const CircularProgressIndicator()
                                : const Text('Create TimeCapsule'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoPreview(
    BuildContext context,
    File photo,
    int index,
    MediaService mediaService,
  ) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Image.file(photo, fit: BoxFit.cover),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => mediaService.removePhoto(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getThemeIcon(ThemeStyle theme) {
    switch (theme) {
      case ThemeStyle.classic:
        return Icons.photo_album;
      case ThemeStyle.modern:
        return Icons.style;
      case ThemeStyle.vintage:
        return Icons.camera_alt;
      case ThemeStyle.minimal:
        return Icons.crop_square;
      case ThemeStyle.colorful:
        return Icons.palette;
      case ThemeStyle.dark:
        return Icons.brightness_2;
      default:
        return Icons.photo_album;
    }
  }

  String _getThemeName(ThemeStyle theme) {
    switch (theme) {
      case ThemeStyle.classic:
        return 'Classic';
      case ThemeStyle.modern:
        return 'Modern';
      case ThemeStyle.vintage:
        return 'Vintage';
      case ThemeStyle.minimal:
        return 'Minimal';
      case ThemeStyle.colorful:
        return 'Colorful';
      case ThemeStyle.dark:
        return 'Dark';
      default:
        return 'Unknown';
    }
  }
}
