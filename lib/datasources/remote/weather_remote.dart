import 'package:dio/dio.dart';
import '../../core/constants.dart';
import '../../models/weather.dart';

class WeatherRemoteDataSource {
  final Dio _dio;

  WeatherRemoteDataSource() : _dio = Dio(BaseOptions(
    baseUrl: AppConstants.weatherApiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Future<Weather> getWeather(double lat, double lng) async {
    final response = await _dio.get('/weather', queryParameters: {
      'lat': lat,
      'lon': lng,
      'appid': AppConstants.weatherApiKey,
      'units': 'metric',
      'lang': 'kr',
    });
    return Weather.fromOpenWeatherMap(response.data as Map<String, dynamic>);
  }
}
