import 'package:flutter/material.dart';
import '../core/exceptions.dart';
import '../core/logger.dart';
import '../models/weather.dart';
import '../repositories/weather_repository.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherRepository _repo;

  Weather? _weather;
  bool _isLoading = false;
  String? _error;

  WeatherProvider(this._repo);

  Weather? get weather => _weather;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchWeather(double lat, double lng) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _weather = await _repo.getWeather(lat, lng);
    } on NetworkException {
      _error = '네트워크 연결을 확인해주세요.';
    } catch (e) {
      _error = '날씨 정보를 불러올 수 없습니다.';
      AppLogger.error('fetchWeather 실패', tag: 'WeatherProvider', error: e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
