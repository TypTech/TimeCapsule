import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MediaService()),
        ChangeNotifierProvider(create: (_) => ThemeService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);

    return MaterialApp(
      title: 'TimeCapsule',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFE8D5F5),
          foregroundColor: Colors.black87,
        ),
      ),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: themeService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const HomeScreen(),
    );
  }
}

class ThemeService extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}

class MediaService extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();
  List<File> _selectedPhotos = [];

  List<File> get selectedPhotos => _selectedPhotos;

  Future<void> requestPermission() async {
    await Permission.photos.request();
  }

  Future<void> pickMultipleImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      _selectedPhotos.addAll(pickedFiles.map((file) => File(file.path)));
      notifyListeners();
    }
  }

  Future<void> takePhoto() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
    );
    if (pickedFile != null) {
      _selectedPhotos.add(File(pickedFile.path));
      notifyListeners();
    }
  }

  void removePhoto(int index) {
    if (index >= 0 && index < _selectedPhotos.length) {
      _selectedPhotos.removeAt(index);
      notifyListeners();
    }
  }

  void clearPhotos() {
    _selectedPhotos.clear();
    notifyListeners();
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('TimeCapsule'),
        actions: [
          IconButton(
            icon: Icon(
              themeService.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () => themeService.toggleTheme(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.photo_camera, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              'Capture Your Memories',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Select Photos'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PhotoSelectionScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class PhotoSelectionScreen extends StatelessWidget {
  const PhotoSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaService = Provider.of<MediaService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Photos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Photo selection options
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                  onPressed: () => mediaService.pickMultipleImages(),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                  onPressed: () => mediaService.takePhoto(),
                ),
              ],
            ),
          ),

          // Selected photos display
          Expanded(
            child:
                mediaService.selectedPhotos.isEmpty
                    ? const Center(child: Text('No photos selected'))
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
                        return PhotoItem(
                          photo: mediaService.selectedPhotos[index],
                          onRemove: () => mediaService.removePhoto(index),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton:
          mediaService.selectedPhotos.isNotEmpty
              ? FloatingActionButton(
                onPressed: () => mediaService.clearPhotos(),
                tooltip: 'Clear All',
                child: const Icon(Icons.delete),
              )
              : null,
    );
  }
}

class PhotoItem extends StatelessWidget {
  final File photo;
  final VoidCallback onRemove;

  const PhotoItem({super.key, required this.photo, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(photo, fit: BoxFit.cover),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
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
}
