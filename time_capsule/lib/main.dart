import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_capsule/services/theme_service.dart';
import 'package:time_capsule/services/media_service.dart';
import 'package:time_capsule/services/video_service.dart';
import 'package:time_capsule/services/local_storage_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:time_capsule/models/capsule.dart';
import 'package:time_capsule/models/liked_video.dart';
import 'services/notification_service.dart';
import 'services/image_processing_service.dart';
import 'services/user_preferences_service.dart';
import 'widgets/photo_preview.dart';
import 'screens/photo_selection_screen.dart';
import 'screens/create_capsule_page.dart';
import 'screens/theme_selection_page.dart';
import 'screens/capsule_detail_page.dart';
import 'screens/for_you_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';

// Main entry point that initializes services before starting the app
void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Request storage permissions
  await Permission.photos.request();
  await Permission.storage.request();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters if needed
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(CapsuleAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(LikedVideoAdapter());
  }

  // Initialize services after Hive setup
  final mediaService = MediaService();
  final localStorageService = LocalStorageService();
  final themeService = ThemeService();
  final videoService = VideoService();

  // Wait for initialization
  try {
    await localStorageService.init();
    await mediaService.initialize();
    // Load theme preferences if needed
    // Initialisierung passiert bereits automatisch im Konstruktor
  } catch (e) {
    debugPrint('Error initializing services: $e');
  }

  // Launch the app with providers
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeService>(create: (_) => themeService),
        ChangeNotifierProvider<MediaService>(create: (_) => mediaService),
        ChangeNotifierProvider<LocalStorageService>(
          create: (_) => localStorageService,
        ),
        ChangeNotifierProvider<VideoService>(create: (_) => videoService),
      ],
      child: const MyApp(),
    ),
  );

  // Configure loading indicator
  configureEasyLoading();
}

void configureEasyLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..maskType = EasyLoadingMaskType.black
    ..userInteractions = false;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);

    return MaterialApp(
      title: 'TimeCapsule',
      debugShowCheckedModeBanner: false,
      theme: themeService.lightTheme,
      darkTheme: themeService.darkTheme,
      themeMode: themeService.themeMode,
      home: const HomeScreen(),
      builder: EasyLoading.init(),
    );
  }
}
