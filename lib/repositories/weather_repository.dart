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
    if (cached != null) return cached;

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
