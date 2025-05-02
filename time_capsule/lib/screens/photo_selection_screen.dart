import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/media_service.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class PhotoSelectionScreen extends StatefulWidget {
  const PhotoSelectionScreen({super.key});

  @override
  State<PhotoSelectionScreen> createState() => _PhotoSelectionScreenState();
}

class _PhotoSelectionScreenState extends State<PhotoSelectionScreen> {
  @override
  void initState() {
    super.initState();
    _checkCreationMode();
  }

  // Prüfe, ob der Kapsel-Erstellungsmodus aktiv ist
  void _checkCreationMode() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mediaService = Provider.of<MediaService>(context, listen: false);
      if (!mediaService.isCapsuleCreationMode) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Fotos können nur beim Erstellen einer Kapsel hinzugefügt werden.',
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context); // Zurück zur vorherigen Seite
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Photos'),
        elevation: 0,
        actions: [
          Consumer<MediaService>(
            builder: (context, mediaService, child) {
              final selectedCount = mediaService.selectedPhotos.length;
              if (selectedCount > 0) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Text(
                      '$selectedCount selected',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<MediaService>(
        builder: (context, mediaService, child) {
          return Column(
            children: [
              // Photo selection buttons
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.photo),
                      label: const Text('Select Photo'),
                      onPressed: () => _pickSingleImage(context, mediaService),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Multiple Photos'),
                      onPressed:
                          () => _pickMultipleImages(context, mediaService),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                      onPressed: () => _takePhoto(context, mediaService),
                    ),
                  ],
                ),
              ),

              // Selected photos preview
              Expanded(
                child:
                    mediaService.selectedPhotos.isEmpty
                        ? const Center(child: Text('No photos selected yet'))
                        : GridView.builder(
                          padding: const EdgeInsets.all(8.0),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                          itemCount: mediaService.selectedPhotos.length,
                          itemBuilder: (context, index) {
                            return _buildPhotoItem(
                              context,
                              mediaService,
                              index,
                            );
                          },
                        ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Consumer<MediaService>(
                builder: (context, mediaService, child) {
                  return Text(
                    '${mediaService.selectedPhotos.length} photos selected',
                    style: Theme.of(context).textTheme.bodyLarge,
                  );
                },
              ),
              TextButton.icon(
                icon: const Icon(Icons.delete),
                label: const Text('Clear All'),
                onPressed:
                    () =>
                        Provider.of<MediaService>(
                          context,
                          listen: false,
                        ).clearPhotos(),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoItem(
    BuildContext context,
    MediaService mediaService,
    int index,
  ) {
    final photo = mediaService.selectedPhotos[index];
    return Stack(
      fit: StackFit.expand,
      children: [
        // Photo preview
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(photo, fit: BoxFit.cover),
        ),

        // Remove button
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
    );
  }

  Future<void> _pickSingleImage(
    BuildContext context,
    MediaService mediaService,
  ) async {
    await mediaService.pickSingleImage();
  }

  Future<void> _pickMultipleImages(
    BuildContext context,
    MediaService mediaService,
  ) async {
    await mediaService.pickMultipleImages();
  }

  Future<void> _takePhoto(
    BuildContext context,
    MediaService mediaService,
  ) async {
    await mediaService.takePhoto();
  }
}
