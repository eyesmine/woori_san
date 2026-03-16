import 'package:flutter/material.dart';
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
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '날씨 정보를 불러올 수 없습니다.';
      _isLoading = false;
      notifyListeners();
    }
  }
}
