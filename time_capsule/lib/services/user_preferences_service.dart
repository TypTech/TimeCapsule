import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferencesService extends ChangeNotifier {
  // Singleton pattern
  static final UserPreferencesService _instance =
      UserPreferencesService._internal();
  factory UserPreferencesService() => _instance;
  UserPreferencesService._internal();

  String _userName = '';
  String _selectedAvatarColor = 'Blue';
  bool _autoSaveEnabled = true;
  bool _highQualityEnabled = true;

  // Getters
  String get userName => _userName;
  String get selectedAvatarColor => _selectedAvatarColor;
  bool get autoSaveEnabled => _autoSaveEnabled;
  bool get highQualityEnabled => _highQualityEnabled;

  // Get color object from avatar color name
  Color getAvatarColor() {
    switch (_selectedAvatarColor) {
      case 'Red':
        return Colors.red;
      case 'Green':
        return Colors.green;
      case 'Purple':
        return Colors.purple;
      case 'Orange':
        return Colors.orange;
      case 'Teal':
        return Colors.teal;
      case 'Blue':
      default:
        return Colors.blue;
    }
  }

  Future<void> init() async {
    await loadPreferences();
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString('userName') ?? '';
    _selectedAvatarColor = prefs.getString('avatarColor') ?? 'Blue';
    _autoSaveEnabled = prefs.getBool('autoSave') ?? true;
    _highQualityEnabled = prefs.getBool('highQuality') ?? true;
    notifyListeners();
  }

  Future<void> updatePreferences({
    required String userName,
    required String avatarColor,
    required bool autoSave,
    required bool highQuality,
  }) async {
    _userName = userName;
    _selectedAvatarColor = avatarColor;
    _autoSaveEnabled = autoSave;
    _highQualityEnabled = highQuality;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _userName);
    await prefs.setString('avatarColor', _selectedAvatarColor);
    await prefs.setBool('autoSave', _autoSaveEnabled);
    await prefs.setBool('highQuality', _highQualityEnabled);

    notifyListeners();
  }

  // Helper method to get user initials for displaying avatar
  String get userInitials {
    if (_userName.isEmpty) {
      return 'TC'; // Default for TimeCapsule
    }

    final nameParts = _userName.split(' ');
    if (nameParts.length > 1) {
      // Get first letter of first and last name
      return '${nameParts.first[0]}${nameParts.last[0]}'.toUpperCase();
    } else {
      // Get first letter or two of single name
      return (_userName.length > 1)
          ? _userName.substring(0, 2).toUpperCase()
          : _userName.toUpperCase();
    }
  }
}
