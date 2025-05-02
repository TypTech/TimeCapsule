import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';

class ThemeSelectionPage extends StatelessWidget {
  const ThemeSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Theme')),
      body: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children:
                AppThemeType.values.map((themeType) {
                  final isSelected = themeType == themeService.themeType;
                  final themeName = themeService.getThemeTypeName(themeType);

                  return Card(
                    elevation: isSelected ? 4 : 1,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side:
                          isSelected
                              ? BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2,
                              )
                              : BorderSide.none,
                    ),
                    child: InkWell(
                      onTap: () {
                        themeService.setThemeType(themeType);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: _getThemePreviewColor(themeType),
                                shape: BoxShape.circle,
                              ),
                              child:
                                  isSelected
                                      ? Icon(
                                        Icons.check,
                                        color: _getContrastColor(
                                          _getThemePreviewColor(themeType),
                                        ),
                                      )
                                      : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    themeName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _getThemeDescription(themeType),
                                    style: TextStyle(
                                      color:
                                          Theme.of(
                                            context,
                                          ).textTheme.bodyMedium?.color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
          );
        },
      ),
    );
  }

  Color _getThemePreviewColor(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.standard:
        return Colors.blue;
      case AppThemeType.ocean:
        return Colors.lightBlue;
      case AppThemeType.forest:
        return Colors.green;
      case AppThemeType.sunset:
        return Colors.orange;
      case AppThemeType.minimal:
        return Colors.grey;
      case AppThemeType.elegant:
        return Colors.purple;
    }
  }

  String _getThemeDescription(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.standard:
        return 'Classic blue theme with modern accents';
      case AppThemeType.ocean:
        return 'Cool blue ocean-inspired theme';
      case AppThemeType.forest:
        return 'Fresh and natural green theme';
      case AppThemeType.sunset:
        return 'Warm and energetic orange theme';
      case AppThemeType.minimal:
        return 'Clean and simple monochrome theme';
      case AppThemeType.elegant:
        return 'Sophisticated purple theme';
    }
  }

  Color _getContrastColor(Color color) {
    return color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
}
