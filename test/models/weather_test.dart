import 'package:flutter_test/flutter_test.dart';
import 'package:woori_san/models/weather.dart';

void main() {
  group('Weather', () {
    test('emoji returns correct icon for each condition', () {
      const conditions = {
        'Clear': '☀️',
        'Clouds': '☁️',
        'Rain': '🌧️',
        'Drizzle': '🌧️',
        'Snow': '🌨️',
        'Thunderstorm': '⛈️',
        'Mist': '🌫️',
        'Fog': '🌫️',
        'Haze': '🌫️',
        'Unknown': '🌤️',
      };

      for (final entry in conditions.entries) {
        final weather = _makeWeather(condition: entry.key);
        expect(weather.emoji, entry.value, reason: 'condition: ${entry.key}');
      }
    });

    test('windLabel returns correct label for speed ranges', () {
      expect(_makeWeather(windSpeed: 1.0).windLabel, '바람 약함');
      expect(_makeWeather(windSpeed: 2.9).windLabel, '바람 약함');
      expect(_makeWeather(windSpeed: 3.0).windLabel, '바람 보통');
      expect(_makeWeather(windSpeed: 6.9).windLabel, '바람 보통');
      expect(_makeWeather(windSpeed: 7.0).windLabel, '바람 강함');
      expect(_makeWeather(windSpeed: 15.0).windLabel, '바람 강함');
    });

    test('fromOpenWeatherMap parses API response correctly', () {
      final apiJson = {
        'weather': [
          {'main': 'Clear', 'description': '맑음', 'icon': '01d'}
        ],
        'main': {'temp': 15.3, 'humidity': 55},
        'wind': {'speed': 4.2},
        'dt': 1710500000,
      };

      final weather = Weather.fromOpenWeatherMap(apiJson);
      expect(weather.temperature, 15.3);
      expect(weather.condition, 'Clear');
      expect(weather.description, '맑음');
      expect(weather.windSpeed, 4.2);
      expect(weather.humidity, 55);
      expect(weather.iconCode, '01d');
    });

    test('toJson/fromJson round trip preserves all fields', () {
      final original = _makeWeather(
        temperature: -5.2,
        condition: 'Snow',
        windSpeed: 8.0,
        humidity: 90,
      );
      final restored = Weather.fromJson(original.toJson());

      expect(restored.temperature, original.temperature);
      expect(restored.condition, original.condition);
      expect(restored.description, original.description);
      expect(restored.windSpeed, original.windSpeed);
      expect(restored.humidity, original.humidity);
      expect(restored.iconCode, original.iconCode);
      expect(restored.forecastDate, original.forecastDate);
    });
  });
}

Weather _makeWeather({
  double temperature = 12.0,
  String condition = 'Clear',
  double windSpeed = 2.0,
  int humidity = 50,
}) {
  return Weather(
    temperature: temperature,
    condition: condition,
    description: '테스트',
    windSpeed: windSpeed,
    humidity: humidity,
    iconCode: '01d',
    forecastDate: DateTime(2025, 3, 15),
  );
}
