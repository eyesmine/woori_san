import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import '../core/constants.dart';
import '../core/logger.dart';

class SettingsProvider extends ChangeNotifier {
  late final Box _box;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  ThemeMode _themeMode = ThemeMode.system;
  bool _notificationsEnabled = true;
  Locale _locale = const Locale('ko');
  String? _emergencyName;
  String? _emergencyPhone;

  SettingsProvider() {
    _box = Hive.box(AppConstants.settingsBox);
    _load();
    _loadEmergencyContact();
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

  Future<void> _syncFcmTopics(bool enabled) async {
    try {
      final messaging = FirebaseMessaging.instance;
      if (enabled) {
        await messaging.subscribeToTopic('weather_alerts');
        await messaging.subscribeToTopic('hiking_tips');
      } else {
        await messaging.unsubscribeFromTopic('weather_alerts');
        await messaging.unsubscribeFromTopic('hiking_tips');
      }
    } catch (e) {
      AppLogger.warning('FCM 토픽 동기화 실패', tag: 'SettingsProvider', error: e);
    }
  }

  String? get emergencyName => _emergencyName;
  String? get emergencyPhone => _emergencyPhone;

  Future<void> _loadEmergencyContact() async {
    _emergencyName = await _secureStorage.read(key: 'emergencyName');
    _emergencyPhone = await _secureStorage.read(key: 'emergencyPhone');
    // Hive → SecureStorage 마이그레이션
    if (_emergencyName == null && _box.containsKey('emergencyName')) {
      _emergencyName = _box.get('emergencyName') as String?;
      _emergencyPhone = _box.get('emergencyPhone') as String?;
      if (_emergencyName != null) {
        await _secureStorage.write(key: 'emergencyName', value: _emergencyName!);
        await _secureStorage.write(key: 'emergencyPhone', value: _emergencyPhone ?? '');
        await _box.delete('emergencyName');
        await _box.delete('emergencyPhone');
      }
    }
    notifyListeners();
  }

  Future<void> setEmergencyContact(String name, String phone) async {
    _emergencyName = name;
    _emergencyPhone = phone;
    await _secureStorage.write(key: 'emergencyName', value: name);
    await _secureStorage.write(key: 'emergencyPhone', value: phone);
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
