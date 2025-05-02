import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService extends ChangeNotifier {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  bool _notificationsEnabled = true;
  bool _reminderNotificationsEnabled = true;
  bool _newFeatureNotificationsEnabled = true;

  // Getters
  bool get notificationsEnabled => _notificationsEnabled;
  bool get reminderNotificationsEnabled => _reminderNotificationsEnabled;
  bool get newFeatureNotificationsEnabled => _newFeatureNotificationsEnabled;

  Future<void> init() async {
    // Load notification preferences
    await loadPreferences();
    debugPrint(
      'NotificationService initialized - notifications temporarily disabled',
    );
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    _reminderNotificationsEnabled =
        prefs.getBool('reminderNotifications') ?? true;
    _newFeatureNotificationsEnabled =
        prefs.getBool('newFeatureNotifications') ?? true;
    notifyListeners();
  }

  Future<void> savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    await prefs.setBool('reminderNotifications', _reminderNotificationsEnabled);
    await prefs.setBool(
      'newFeatureNotifications',
      _newFeatureNotificationsEnabled,
    );
  }

  // Update notification settings
  Future<void> updateSettings({
    required bool notificationsEnabled,
    required bool reminderNotificationsEnabled,
    required bool newFeatureNotificationsEnabled,
  }) async {
    _notificationsEnabled = notificationsEnabled;
    _reminderNotificationsEnabled = reminderNotificationsEnabled;
    _newFeatureNotificationsEnabled = newFeatureNotificationsEnabled;

    await savePreferences();
    notifyListeners();

    // If notifications were enabled, we would request permission here
    if (_notificationsEnabled) {
      debugPrint('Notification permission would be requested here');
    }
  }

  // Schedule a memory reminder notification (stubbed)
  Future<void> scheduleMemoryReminder(
    String title,
    String body,
    DateTime scheduledDate,
  ) async {
    if (!_notificationsEnabled || !_reminderNotificationsEnabled) return;

    debugPrint('Would schedule notification: $title - $body at $scheduledDate');
    // Actual notification scheduling is disabled temporarily
  }

  // Send a feature notification (stubbed)
  Future<void> sendFeatureNotification(String title, String body) async {
    if (!_notificationsEnabled || !_newFeatureNotificationsEnabled) return;

    debugPrint('Would show notification: $title - $body');
    // Actual notification sending is disabled temporarily
  }
}
