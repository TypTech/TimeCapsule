import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_capsule/services/media_service.dart';
import 'package:time_capsule/services/theme_service.dart';
import 'package:time_capsule/services/local_storage_service.dart';
import 'package:time_capsule/screens/create_capsule_page.dart';
import 'package:time_capsule/screens/photo_selection_screen.dart';
import 'package:time_capsule/screens/theme_selection_page.dart';
import 'package:time_capsule/screens/capsule_detail_page.dart';
import 'package:time_capsule/screens/for_you_page.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final LocalStorageService _storageService = LocalStorageService();

  @override
  void initState() {
    super.initState();
    // Initialize permissions and services
    _initServices();

    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initServices() async {
    final mediaService = Provider.of<MediaService>(context, listen: false);
    await mediaService.requestPermission();
    await _storageService.init();
    await _refreshData();

    // Load old photos for the home screen
    await mediaService.loadOldPhotos();
  }

  Future<void> _refreshData({bool forceReload = false}) async {
    try {
      // Ensure storage service is initialized
      await _storageService.init();

      // Force close and reopen boxes if needed
      if (forceReload) {
        debugPrint('Forcing reload of capsules from disk...');
        await _storageService.reinitialize();
      }

      // Reload capsules
      await _storageService.loadCapsules();

      // Log the number of capsules loaded
      debugPrint(
        'Refreshed data: ${_storageService.capsules.length} capsules loaded',
      );

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error refreshing data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeService? themeService;
    bool isDark = false;

    try {
      themeService = Provider.of<ThemeService>(context, listen: true);
      isDark = themeService.isDarkMode;
    } catch (e) {
      debugPrint('Error accessing ThemeService: $e');
      // Fallback to default theme
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('TimeCapsule'),
        elevation: 0,
        actions: [
          // Theme toggle button
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              size: 22,
            ),
            onPressed: () => themeService?.toggleTheme(),
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateCapsulePage()),
          ).then((_) => _refreshData());
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Capsule'),
        elevation: 4,
        heroTag: 'newCapsule',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
              _animationController.reset();
              _animationController.forward();

              // Reload capsules data when switching to the Capsules tab
              if (index == 1) {
                _refreshData();
              }
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.collections_rounded),
              label: 'My Capsules',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.play_circle_fill_rounded),
              label: 'For You',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _getTabContent(),
      ),
    );
  }

  Widget _getTabContent() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildCapsuleTab();
      case 2:
        return const ForYouPage();
      case 3:
        return _buildSettingsTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    final mediaService = Provider.of<MediaService>(context);
    final theme = Theme.of(context);
    final capsules = _storageService.capsules;

    if (mediaService.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (mediaService.errorMessage != null) {
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
                mediaService.errorMessage!,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _initServices(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Welcome section
            Text('Create Memories', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Turn your photos into beautiful video collages with music',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 30),

            // Quick actions card
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
                          Icons.bolt_rounded,
                          color: theme.colorScheme.primary,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Quick Actions',
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _actionButton(
                            context: context,
                            icon: Icons.add_circle_outline_rounded,
                            title: 'Create Capsule',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => const CreateCapsulePage(),
                                ),
                              ).then((_) => _refreshData());
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _actionButton(
                            context: context,
                            icon: Icons.collections_rounded,
                            title: 'View Capsules',
                            onTap: () {
                              setState(() {
                                _currentIndex = 1; // Switch to capsules tab
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _actionButton(
                            context: context,
                            icon: Icons.style_rounded,
                            title: 'Themes',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => const ThemeSelectionPage(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _actionButton(
                            context: context,
                            icon: Icons.settings_rounded,
                            title: 'Settings',
                            onTap: () {
                              setState(() {
                                _currentIndex = 2; // Switch to settings tab
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Recent Capsules section
            const SizedBox(height: 25),

            // Old photos / Beautiful moments section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Old Memories', style: theme.textTheme.titleMedium),
                TextButton(
                  onPressed: () async {
                    // Reload old photos
                    await mediaService.loadOldPhotos();
                    setState(() {});
                  },
                  child: Text(
                    'Refresh',
                    style: TextStyle(color: theme.colorScheme.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // Display the old photos
            if (mediaService.oldPhotos.isNotEmpty)
              SizedBox(
                height: 190, // Increased height to accommodate date label
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: mediaService.oldPhotos.length,
                  itemBuilder: (context, index) {
                    final photo = mediaService.oldPhotos[index];
                    return Container(
                      width: 140,
                      margin: const EdgeInsets.only(right: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                photo,
                                height: 160,
                                width: 140,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 160,
                                    width: 140,
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.1),
                                    child: Icon(
                                      Icons.image_not_supported_rounded,
                                      color: theme.colorScheme.primary,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          if (mediaService.oldestPhotoDate != null)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 6.0,
                                left: 4.0,
                              ),
                              child: Text(
                                mediaService.oldestPhotoDate!.year.toString(),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                height: 160,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.photo_album_outlined,
                      size: 40,
                      color: theme.colorScheme.primary.withOpacity(0.7),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No old photos found',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'We\'ll show your oldest memories here',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(
                          0.7,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => mediaService.loadOldPhotos(),
                      child: const Text('Select Photos'),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 25),

            if (capsules.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent Capsules', style: theme.textTheme.titleMedium),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _currentIndex = 1; // Switch to capsules tab
                      });
                    },
                    child: Text(
                      'View All',
                      style: TextStyle(color: theme.colorScheme.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: capsules.length > 5 ? 5 : capsules.length,
                  itemBuilder: (context, index) {
                    final capsule = capsules[index];
                    return _capsuleCard(
                      context: context,
                      title: capsule.title,
                      date: DateFormat('MMM d, yyyy').format(capsule.createdAt),
                      imagePath:
                          capsule.photoFilePaths.isNotEmpty
                              ? capsule.photoFilePaths.first
                              : null,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    CapsuleDetailPage(capsuleId: capsule.id),
                          ),
                        ).then((_) => _refreshData());
                      },
                    );
                  },
                ),
              ),
            ] else ...[
              // Featured templates if no capsules
              Text('Featured Templates', style: theme.textTheme.titleMedium),
              const SizedBox(height: 15),
              SizedBox(
                height: 180,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _templateCard(
                      context: context,
                      title: 'Anniversary',
                      assetName: 'assets/images/anniversary.jpg',
                    ),
                    _templateCard(
                      context: context,
                      title: 'Birthday',
                      assetName: 'assets/images/birthday.jpg',
                    ),
                    _templateCard(
                      context: context,
                      title: 'Travel',
                      assetName: 'assets/images/travel.jpg',
                    ),
                    _templateCard(
                      context: context,
                      title: 'Memories',
                      assetName: 'assets/images/memories.jpg',
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 80), // Space for the FAB
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color:
              isDark
                  ? theme.colorScheme.primary.withOpacity(0.1)
                  : theme.colorScheme.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 26),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _templateCard({
    required BuildContext context,
    required String title,
    required String assetName,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Image.asset(
              assetName,
              height: 120,
              width: 140,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 120,
                  width: 140,
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  child: Icon(
                    Icons.image_not_supported_rounded,
                    color: theme.colorScheme.primary,
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            width: 140,
            child: Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _capsuleCard({
    required BuildContext context,
    required String title,
    required String date,
    required String? imagePath,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child:
                  imagePath != null
                      ? Image.file(
                        File(imagePath),
                        height: 130,
                        width: 180,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _placeholderImage(theme);
                        },
                      )
                      : _placeholderImage(theme),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderImage(ThemeData theme) {
    return Container(
      height: 130,
      width: 180,
      color: theme.colorScheme.primary.withOpacity(0.1),
      child: Center(
        child: Icon(
          Icons.photo_library_rounded,
          color: theme.colorScheme.primary.withOpacity(0.5),
          size: 40,
        ),
      ),
    );
  }

  Widget _buildCapsuleTab() {
    final theme = Theme.of(context);

    // Lade Capsules direkt vom StorageService
    final capsules = _storageService.capsules;
    debugPrint('Building capsule tab with ${capsules.length} capsules');

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () => _refreshData(forceReload: true),
          child:
              capsules.isEmpty
                  ? _buildEmptyCapsuleTab(theme)
                  : _buildCapsuleList(theme, capsules),
        ),

        // Manueller Refresh-Button in der oberen rechten Ecke
        Positioned(
          top: 20,
          right: 20,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.8),
            child: const Icon(Icons.refresh),
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Refreshing capsules...')),
              );
              await _refreshData(forceReload: true);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCapsuleTab(ThemeData theme) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 30),
        Text('My Capsules', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          'View and edit your saved capsules',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 80),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.video_library_rounded,
                size: 70,
                color: theme.colorScheme.primary.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Your TimeCapsules will appear here',
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateCapsulePage(),
                    ),
                  ).then((_) => _refreshData());
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text('Create a Capsule'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCapsuleList(ThemeData theme, List<TimeCapsule> capsules) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        Text('My Capsules', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          'View and edit your saved capsules',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 24),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: capsules.length,
          itemBuilder: (context, index) {
            final capsule = capsules[index];
            return _buildCapsuleListItem(theme, capsule);
          },
        ),
        const SizedBox(height: 80), // Space for FAB
      ],
    );
  }

  Widget _buildCapsuleListItem(ThemeData theme, TimeCapsule capsule) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CapsuleDetailPage(capsuleId: capsule.id),
            ),
          ).then((_) => _refreshData());
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child:
                    capsule.photoFilePaths.isNotEmpty
                        ? Image.file(
                          File(capsule.photoFilePaths.first),
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 80,
                              height: 80,
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              child: Icon(
                                Icons.image_rounded,
                                color: theme.colorScheme.primary.withOpacity(
                                  0.6,
                                ),
                              ),
                            );
                          },
                        )
                        : Container(
                          width: 80,
                          height: 80,
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          child: Icon(
                            Icons.image_rounded,
                            color: theme.colorScheme.primary.withOpacity(0.6),
                          ),
                        ),
              ),

              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      capsule.title,
                      style: theme.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (capsule.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        capsule.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(
                            0.7,
                          ),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.photo_library_rounded,
                          size: 14,
                          color: theme.colorScheme.primary.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${capsule.photoFilePaths.length} photos',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color
                                ?.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color: theme.colorScheme.primary.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('MMM d, yyyy').format(capsule.createdAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color
                                ?.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTab() {
    final theme = Theme.of(context);
    ThemeService? themeService;
    bool isDark = false;

    try {
      themeService = Provider.of<ThemeService>(context, listen: false);
      isDark = themeService.isDarkMode;
    } catch (e) {
      debugPrint('Error accessing ThemeService in settings tab: $e');
      // Fallback to default theme
    }

    // Settings tab
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settings', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Customize your experience',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 30),

          // Settings sections
          _buildSettingsSection(
            title: 'Appearance',
            items: [
              _settingsCard(
                icon: Icons.color_lens_rounded,
                title: 'Theme Settings',
                subtitle: 'Customize colors and appearance',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ThemeSelectionPage(),
                    ),
                  );
                },
              ),
              _settingsCard(
                icon: Icons.dark_mode_rounded,
                title: 'Dark Mode',
                subtitle: isDark ? 'On' : 'Off',
                onTap: () {
                  themeService?.toggleTheme();
                },
                trailing: Switch(
                  value: isDark,
                  onChanged: (value) {
                    themeService?.toggleTheme();
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _buildSettingsSection(
            title: 'Content',
            items: [
              _settingsCard(
                icon: Icons.photo_library_rounded,
                title: 'Media Quality',
                subtitle: 'High quality (recommended)',
                onTap: () {
                  // Show media quality options
                },
              ),
              _settingsCard(
                icon: Icons.notifications_rounded,
                title: 'Notifications',
                subtitle: 'Manage notification settings',
                onTap: () {
                  // Show notification settings
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          _buildSettingsSection(
            title: 'About',
            items: [
              _settingsCard(
                icon: Icons.info_outline_rounded,
                title: 'App Info',
                subtitle: 'Version 1.0.0',
                onTap: () {
                  // Show app info
                },
              ),
              _settingsCard(
                icon: Icons.policy_rounded,
                title: 'Privacy Policy',
                subtitle: 'Read our privacy policy',
                onTap: () {
                  // Show privacy policy
                },
              ),
            ],
          ),

          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required List<Widget> items,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _settingsCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: theme.colorScheme.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            trailing ?? const Icon(Icons.chevron_right_rounded, size: 22),
          ],
        ),
      ),
    );
  }
}
