import 'dart:convert';
import 'package:hive/hive.dart';
import '../../core/constants.dart';
import '../../models/weather.dart';

class WeatherLocalDataSource {
  Box get _box => Hive.box(AppConstants.weatherBox);

  static const _cacheKey = 'weather_cache';
  static const _cacheTimeKey = 'weather_cache_time';

  Future<Weather?> getCached() async {
    final data = _box.get(_cacheKey);
    if (data == null) return null;

    final cacheTime = _box.get(_cacheTimeKey);
    if (cacheTime != null) {
      final expiry = DateTime.parse(cacheTime);
      if (DateTime.now().isAfter(expiry)) {
        await clearCache();
        return null;
      }
    }

    return Weather.fromJson(jsonDecode(data));
  }

  Future<void> cache(Weather weather) async {
    final expiry = DateTime.now().add(AppConstants.weatherCacheTtl).toIso8601String();
    await _box.put(_cacheKey, jsonEncode(weather.toJson()));
    await _box.put(_cacheTimeKey, expiry);
  }

  Future<void> clearCache() async {
    await _box.delete(_cacheKey);
    await _box.delete(_cacheTimeKey);
  }
}
