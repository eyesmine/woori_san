import '../core/logger.dart';
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

    try {
      final weather = await _remote.getWeather(lat, lng);
      await _local.cache(weather);
      return weather;
    } catch (e) {
      AppLogger.warning('날씨 조회 실패', tag: 'WeatherRepo', error: e);
      // 리모트 실패 시 만료된 캐시라도 반환
      if (cached != null) return cached;
      return null;
    }
  }
}
