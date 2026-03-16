import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../core/constants.dart';

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
