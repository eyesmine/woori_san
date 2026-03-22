import 'package:flutter/foundation.dart';
import '../datasources/local/weather_local.dart';
import '../datasources/remote/weather_remote.dart';
import '../models/weather.dart';

class WeatherRepository {
  final WeatherLocalDataSource _local;
  final WeatherRemoteDataSource _remote;

  WeatherRepository(this._local, this._remote);

  Future<Weather?> getWeather(double lat, double lng) async {
    final cached = await _local.getCached();
    // 새 필드(feelsLike)가 없는 구버전 캐시는 무효화
    if (cached != null && cached.feelsLike != null) return cached;
    if (cached != null && cached.feelsLike == null) await _local.clearCache();

    try {
      final weather = await _remote.getWeather(lat, lng);
      await _local.cache(weather);
      return weather;
    } catch (e) {
      debugPrint('WeatherRepository.getWeather error: $e');
      return null;
    }
  }
}
