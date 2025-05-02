import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/media_service.dart';

class PhotoSelectionScreen extends StatelessWidget {
  const PhotoSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Photos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context);
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
                onPressed: () {
                  final mediaService = context.read<MediaService>();
                  if (mediaService.selectedPhotos.isNotEmpty) {
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text('Clear selected photos?'),
                            content: const Text(
                              'This will remove all photos from the current selection.',
                            ),
                            actions: [
                              TextButton(
                                child: const Text('Cancel'),
                                onPressed: () => Navigator.pop(context),
                              ),
                              TextButton(
                                child: const Text('Clear'),
                                onPressed: () {
                                  mediaService.clearSelectedPhotos();
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                    );
                  }
                },
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
