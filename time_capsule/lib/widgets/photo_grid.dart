import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:time_capsule/services/media_service.dart';

class PhotoGrid extends StatelessWidget {
  const PhotoGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaService = Provider.of<MediaService>(context);
    final photos = mediaService.selectedPhotos;

    if (photos.isEmpty) {
      return const Center(child: Text('No photos selected yet'));
    }

    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      padding: const EdgeInsets.all(4),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        final photo = photos[index];
        return PhotoTile(photo: photo, index: index);
      },
    );
  }
}

class PhotoTile extends StatelessWidget {
  final File photo;
  final int index;

  const PhotoTile({super.key, required this.photo, required this.index});

  @override
  Widget build(BuildContext context) {
    final mediaService = Provider.of<MediaService>(context);

    return GestureDetector(
      onTap: () {
        // Toggle selection if needed
      },
      child: Stack(
        children: [
          // Photo
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(photo, fit: BoxFit.cover),
          ),
          // Delete button
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => mediaService.removePhoto(index),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(4),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
