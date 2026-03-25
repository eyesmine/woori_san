import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../core/constants.dart';
import '../core/logger.dart';

class SettingsProvider extends ChangeNotifier {
  late final Box _box;

  ThemeMode _themeMode = ThemeMode.system;
  bool _notificationsEnabled = true;
  Locale _locale = const Locale('ko');

  SettingsProvider() {
    _box = Hive.box(AppConstants.settingsBox);
    _load();
  }

  ThemeMode get themeMode => _themeMode;
  bool get notificationsEnabled => _notificationsEnabled;
  Locale get locale => _locale;

  void _load() {
    final themeIndex = _box.get('themeMode', defaultValue: 0) as int;
    _themeMode = ThemeMode.values[themeIndex];
    _notificationsEnabled = _box.get('notifications', defaultValue: true) as bool;
    final localeCode = _box.get('locale', defaultValue: 'ko') as String;
    _locale = Locale(localeCode);
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _box.put('themeMode', mode.index);
    notifyListeners();
  }

  void toggleDarkMode() {
    if (_themeMode == ThemeMode.dark) {
      setThemeMode(ThemeMode.light);
    } else {
      setThemeMode(ThemeMode.dark);
    }
  }

  bool get isDark => _themeMode == ThemeMode.dark;

  void setNotificationsEnabled(bool enabled) {
    _notificationsEnabled = enabled;
    _box.put('notifications', enabled);
    _syncFcmTopics(enabled);
    notifyListeners();
  }

  void _syncFcmTopics(bool enabled) {
    try {
      final messaging = FirebaseMessaging.instance;
      if (enabled) {
        messaging.subscribeToTopic('weather_alerts');
        messaging.subscribeToTopic('hiking_tips');
      } else {
        messaging.unsubscribeFromTopic('weather_alerts');
        messaging.unsubscribeFromTopic('hiking_tips');
      }
    } catch (e) {
      AppLogger.warning('FCM 토픽 동기화 실패', tag: 'SettingsProvider', error: e);
    }
  }

  String? get emergencyName => _box.get('emergencyName') as String?;
  String? get emergencyPhone => _box.get('emergencyPhone') as String?;

  void setEmergencyContact(String name, String phone) {
    _box.put('emergencyName', name);
    _box.put('emergencyPhone', phone);
    notifyListeners();
  }

  void setLocale(Locale locale) {
    _locale = locale;
    _box.put('locale', locale.languageCode);
    notifyListeners();
  }

  void toggleLocale() {
    if (_locale.languageCode == 'ko') {
      setLocale(const Locale('en'));
    } else {
      setLocale(const Locale('ko'));
    }
  }
}
