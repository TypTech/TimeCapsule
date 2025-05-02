import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_capsule/services/media_service.dart';
import 'package:time_capsule/services/theme_service.dart';
import 'package:time_capsule/screens/create_capsule_page.dart';
import 'package:time_capsule/screens/photo_selection_screen.dart';
import 'package:time_capsule/screens/theme_selection_page.dart';

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

  @override
  void initState() {
    super.initState();
    // Initialize permissions when the app starts
    _initPermissions();

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

  Future<void> _initPermissions() async {
    final mediaService = Provider.of<MediaService>(context, listen: false);
    await mediaService.requestPermission();
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final isDark = themeService.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('TimeCapsule'),
        elevation: 0,
        actions: [
          // Theme toggle button
          IconButton(
            icon: Icon(
              themeService.isDarkMode
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
              size: 22,
            ),
            onPressed: () => themeService.toggleTheme(),
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateCapsulePage()),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Capsule'),
        elevation: 2,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
        return _buildSettingsTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    final mediaService = Provider.of<MediaService>(context);
    final theme = Theme.of(context);

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
              onPressed: () => _initPermissions(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
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
                      Text('Quick Actions', style: theme.textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _actionButton(
                          context: context,
                          icon: Icons.photo_library_rounded,
                          title: 'Select Photos',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const PhotoSelectionScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _actionButton(
                          context: context,
                          icon: Icons.camera_alt_rounded,
                          title: 'Take Photo',
                          onTap: () async {
                            final mediaService = Provider.of<MediaService>(
                              context,
                              listen: false,
                            );
                            await mediaService.takePhoto();
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
                          icon: Icons.movie_creation_rounded,
                          title: 'Create Video',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CreateCapsulePage(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
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
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 25),

          // Featured section
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

          const SizedBox(height: 80), // Space for the FAB
        ],
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

  Widget _buildCapsuleTab() {
    final theme = Theme.of(context);

    // This will show user's saved TimeCapsules
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('My Capsules', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'View and edit your saved capsules',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 50),
          Expanded(
            child: Center(
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
                      setState(() {
                        _currentIndex = 0;
                      });
                    },
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Create a Capsule'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    final theme = Theme.of(context);

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
                subtitle:
                    Provider.of<ThemeService>(context).isDarkMode
                        ? 'On'
                        : 'Off',
                onTap: () {
                  Provider.of<ThemeService>(
                    context,
                    listen: false,
                  ).toggleTheme();
                },
                trailing: Switch(
                  value: Provider.of<ThemeService>(context).isDarkMode,
                  onChanged: (value) {
                    Provider.of<ThemeService>(
                      context,
                      listen: false,
                    ).toggleTheme();
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
