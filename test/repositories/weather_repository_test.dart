import 'package:flutter_test/flutter_test.dart';
import 'package:woori_san/models/weather.dart';
import 'package:woori_san/datasources/local/weather_local.dart';
import 'package:woori_san/datasources/remote/weather_remote.dart';
import 'package:woori_san/repositories/weather_repository.dart';

class FakeWeatherLocal implements WeatherLocalDataSource {
  Weather? _cached;

  @override
  Future<Weather?> getCached() async => _cached;

  @override
  Future<void> cache(Weather weather) async {
    _cached = weather;
  }

  @override
  Future<void> clearCache() async {
    _cached = null;
  }
}

class FakeWeatherRemote implements WeatherRemoteDataSource {
  bool shouldFail = false;

  @override
  Future<Weather> getWeather(double lat, double lng) async {
    if (shouldFail) throw Exception('API Error');
    return Weather(
      temperature: 18.0,
      condition: 'Clear',
      description: '맑음',
      windSpeed: 3.0,
      humidity: 40,
      iconCode: '01d',
      forecastDate: DateTime(2025, 3, 15),
    );
  }
}

void main() {
  group('WeatherRepository', () {
    test('returns cached weather when available', () async {
      final local = FakeWeatherLocal();
      local._cached = Weather(
        temperature: 10.0,
        condition: 'Clouds',
        description: '흐림',
        windSpeed: 5.0,
        humidity: 70,
        iconCode: '04d',
        forecastDate: DateTime(2025, 3, 14),
      );
      final remote = FakeWeatherRemote();
      final repo = WeatherRepository(local, remote);

      final result = await repo.getWeather(37.5, 127.0);

      expect(result!.temperature, 10.0);
      expect(result.condition, 'Clouds');
    });

    test('fetches from remote and caches when no cache', () async {
      final local = FakeWeatherLocal();
      final remote = FakeWeatherRemote();
      final repo = WeatherRepository(local, remote);

      final result = await repo.getWeather(37.5, 127.0);

      expect(result!.temperature, 18.0);
      expect(local._cached, isNotNull);
    });

    test('returns null when remote fails and no cache', () async {
      final local = FakeWeatherLocal();
      final remote = FakeWeatherRemote();
      remote.shouldFail = true;
      final repo = WeatherRepository(local, remote);

      final result = await repo.getWeather(37.5, 127.0);

      expect(result, isNull);
    });
  });
}
