import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:time_capsule/screens/home_screen.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  bool _loading = false;
  String _statusMessage = 'Bitte erteile die erforderlichen Berechtigungen';
  bool _photosGranted = false;
  bool _storageGranted = false;
  bool _videosGranted = false;
  bool _cameraGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final photosStatus = await Permission.photos.status;
    final storageStatus = await Permission.storage.status;
    final videosStatus = await Permission.videos.status;
    final cameraStatus = await Permission.camera.status;

    setState(() {
      _photosGranted = photosStatus.isGranted;
      _storageGranted = storageStatus.isGranted;
      _videosGranted = videosStatus.isGranted;
      _cameraGranted = cameraStatus.isGranted;
    });

    // Prüfen, ob alle Berechtigungen bereits erteilt wurden
    if (_photosGranted && _storageGranted && _videosGranted && _cameraGranted) {
      _navigateToHome();
    }
  }

  Future<void> _requestPermissions() async {
    setState(() {
      _loading = true;
      _statusMessage = 'Berechtigungen werden angefragt...';
    });

    try {
      // Android 13+ (API 33+) Berechtigungen
      Map<Permission, PermissionStatus> statuses =
          await [
            Permission.photos,
            Permission.videos,
            Permission.camera,
            Permission.storage,
            Permission.mediaLibrary,
          ].request();

      setState(() {
        _photosGranted = statuses[Permission.photos]?.isGranted ?? false;
        _storageGranted = statuses[Permission.storage]?.isGranted ?? false;
        _videosGranted = statuses[Permission.videos]?.isGranted ?? false;
        _cameraGranted = statuses[Permission.camera]?.isGranted ?? false;
      });

      // Überprüfen, ob die wichtigsten Berechtigungen erteilt wurden
      if (_photosGranted || _storageGranted) {
        _navigateToHome();
      } else {
        setState(() {
          _statusMessage = 'Berechtigungen erforderlich, um fortzufahren';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Fehler beim Anfordern der Berechtigungen: $e';
        _loading = false;
      });
    }
  }

  void _navigateToHome() {
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Icon und Titel
              Icon(
                Icons.access_time,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'TimeCapsule',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 48),

              // Berechtigungs-Statusliste
              _buildPermissionItem(
                'Fotos & Medien',
                _photosGranted,
                Icons.photo_library,
              ),
              const SizedBox(height: 12),
              _buildPermissionItem('Speicher', _storageGranted, Icons.storage),
              const SizedBox(height: 12),
              _buildPermissionItem(
                'Videos',
                _videosGranted,
                Icons.video_library,
              ),
              const SizedBox(height: 12),
              _buildPermissionItem('Kamera', _cameraGranted, Icons.camera_alt),

              const SizedBox(height: 36),
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 24),

              // Aktionsknopf
              if (_loading)
                const CircularProgressIndicator()
              else
                ElevatedButton.icon(
                  onPressed: _requestPermissions,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Berechtigungen erteilen'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),

              const SizedBox(height: 24),
              Text(
                'Diese Berechtigungen werden benötigt, um auf deine Fotos und Videos zuzugreifen und neue Aufnahmen zu erstellen.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionItem(String title, bool granted, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color:
            granted
                ? Colors.green.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: granted ? Colors.green : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: granted ? Colors.green : Colors.grey),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: granted ? Colors.green.shade800 : Colors.black87,
              ),
            ),
          ),
          Icon(
            granted ? Icons.check_circle : Icons.arrow_circle_right_outlined,
            color: granted ? Colors.green : Colors.grey,
          ),
        ],
      ),
    );
  }
}
