import 'package:flutter_test/flutter_test.dart';
import 'package:woori_san/models/weather.dart';
import 'package:woori_san/datasources/local/weather_local.dart';
import 'package:woori_san/datasources/remote/weather_remote.dart';
import 'package:woori_san/repositories/weather_repository.dart';
import 'package:woori_san/providers/weather_provider.dart';

class FakeWeatherLocalDataSource implements WeatherLocalDataSource {
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

class FakeWeatherRemoteDataSource implements WeatherRemoteDataSource {
  bool shouldFail = false;
  Weather? weatherToReturn;

  @override
  Future<Weather> getWeather(double lat, double lng) async {
    if (shouldFail) throw Exception('API Error');
    return weatherToReturn ??
        Weather(
          temperature: 15.0,
          condition: 'Clear',
          description: '맑음',
          windSpeed: 2.5,
          humidity: 50,
          iconCode: '01d',
          forecastDate: DateTime(2025, 3, 15),
          feelsLike: 14.0,
        );
  }
}

void main() {
  late WeatherProvider provider;
  late FakeWeatherLocalDataSource fakeLocal;
  late FakeWeatherRemoteDataSource fakeRemote;

  setUp(() {
    fakeLocal = FakeWeatherLocalDataSource();
    fakeRemote = FakeWeatherRemoteDataSource();
    final repo = WeatherRepository(fakeLocal, fakeRemote);
    provider = WeatherProvider(repo);
  });

  group('WeatherProvider', () {
    test('initial state has no weather', () {
      expect(provider.weather, isNull);
      expect(provider.isLoading, false);
      expect(provider.error, isNull);
    });

    test('fetchWeather loads from remote and sets weather', () async {
      await provider.fetchWeather(37.5, 127.0);

      expect(provider.weather, isNotNull);
      expect(provider.weather!.temperature, 15.0);
      expect(provider.weather!.condition, 'Clear');
      expect(provider.isLoading, false);
    });

    test('fetchWeather uses cached data when available', () async {
      final cachedWeather = Weather(
        temperature: 10.0,
        condition: 'Clouds',
        description: '흐림',
        windSpeed: 5.0,
        humidity: 70,
        iconCode: '04d',
        forecastDate: DateTime(2025, 3, 14),
        feelsLike: 9.0,
      );
      fakeLocal._cached = cachedWeather;

      await provider.fetchWeather(37.5, 127.0);

      expect(provider.weather!.temperature, 10.0);
      expect(provider.weather!.condition, 'Clouds');
    });

    test('fetchWeather handles remote error gracefully', () async {
      fakeRemote.shouldFail = true;

      await provider.fetchWeather(37.5, 127.0);

      expect(provider.weather, isNull);
      expect(provider.isLoading, false);
      // No error set because repository returns null on failure
    });
  });
}
