import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/media_service.dart';
import 'photo_selection_screen.dart';

class CreateCapsulePage extends StatefulWidget {
  const CreateCapsulePage({super.key});

  @override
  State<CreateCapsulePage> createState() => _CreateCapsulePageState();
}

class _CreateCapsulePageState extends State<CreateCapsulePage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedTheme = 'Classic';

  // Theme options with icons
  final List<Map<String, dynamic>> _themeOptions = [
    {'name': 'Classic', 'icon': Icons.auto_awesome_rounded},
    {'name': 'Modern', 'icon': Icons.diamond_rounded},
    {'name': 'Vintage', 'icon': Icons.camera_alt_rounded},
    {'name': 'Colorful', 'icon': Icons.palette_rounded},
    {'name': 'Minimal', 'icon': Icons.crop_square_rounded},
    {'name': 'Dark', 'icon': Icons.nightlight_round},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create TimeCapsule'),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Text('Design Your Capsule', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Customize how your memories will look and feel',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 30),

            // Title and Description Card
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.title_rounded,
                          color: theme.colorScheme.primary,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Basic Information',
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Title field
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        hintText: 'Give your TimeCapsule a name',
                        prefixIcon: Icon(Icons.edit_rounded),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description field
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description (Optional)',
                        hintText: 'Add some details about this collection',
                        prefixIcon: Icon(Icons.description_rounded),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Theme Selection Card
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.style_rounded,
                          color: theme.colorScheme.primary,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Choose a Theme',
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 1.1,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                      itemCount: _themeOptions.length,
                      itemBuilder: (context, index) {
                        final theme = _themeOptions[index];
                        final isSelected = theme['name'] == _selectedTheme;

                        return _themeOptionCard(
                          icon: theme['icon'],
                          label: theme['name'],
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              _selectedTheme = theme['name'];
                            });
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Photos Section Card
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.photo_library_rounded,
                              color: theme.colorScheme.primary,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text('Photos', style: theme.textTheme.titleMedium),
                          ],
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(
                            Icons.add_photo_alternate_rounded,
                            size: 18,
                          ),
                          label: const Text('Add'),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const PhotoSelectionScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Photo preview
                    Consumer<MediaService>(
                      builder: (context, mediaService, child) {
                        final photos = mediaService.selectedPhotos;

                        if (photos.isEmpty) {
                          return Container(
                            height: 180,
                            decoration: BoxDecoration(
                              color:
                                  isDark
                                      ? theme.colorScheme.primary.withOpacity(
                                        0.1,
                                      )
                                      : theme.colorScheme.primary.withOpacity(
                                        0.05,
                                      ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.photo_library_rounded,
                                    size: 48,
                                    color:
                                        isDark
                                            ? theme.colorScheme.primary
                                                .withOpacity(0.5)
                                            : theme.colorScheme.primary
                                                .withOpacity(0.3),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No photos selected yet',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap "Add" to select photos',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.textTheme.bodySmall?.color
                                          ?.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${photos.length} photo${photos.length > 1 ? "s" : ""} selected',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 120,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                itemCount: photos.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    width: 120,
                                    margin: const EdgeInsets.only(right: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: Image.file(
                                            photos[index],
                                            fit: BoxFit.cover,
                                            width: 120,
                                            height: 120,
                                          ),
                                        ),
                                        Positioned(
                                          top: 5,
                                          right: 5,
                                          child: GestureDetector(
                                            onTap: () {
                                              Provider.of<MediaService>(
                                                context,
                                                listen: false,
                                              ).removePhoto(index);
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(
                                                  0.6,
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.close_rounded,
                                                size: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {
              if (_titleController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Please enter a title for your TimeCapsule',
                    ),
                    backgroundColor: theme.colorScheme.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }

              // Here you would save the TimeCapsule
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('TimeCapsule created successfully'),
                  behavior: SnackBarBehavior.floating,
                ),
              );

              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Create TimeCapsule'),
          ),
        ),
      ),
    );
  }

  Widget _themeOptionCard({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? theme.colorScheme.primary.withOpacity(isDark ? 0.3 : 0.1)
                  : isDark
                  ? theme.colorScheme.surface.withOpacity(0.3)
                  : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color:
                  isSelected
                      ? theme.colorScheme.primary
                      : theme.iconTheme.color?.withOpacity(0.7),
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color:
                    isSelected
                        ? theme.colorScheme.primary
                        : theme.textTheme.bodySmall?.color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
