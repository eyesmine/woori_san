import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static const String appName = '우리산';

  // .env에서 로드 (테스트 환경에서는 기본값 사용)
  static String get apiBaseUrl => _env('API_BASE_URL', 'http://localhost:8000/api');
  static String get naverMapClientId => _env('NAVER_MAP_CLIENT_ID', '');
  static String get weatherApiKey => _env('WEATHER_API_KEY', '');

  static const String weatherApiBaseUrl = 'https://api.openweathermap.org/data/2.5';

  // Hive box names
  static const String mountainBox = 'mountains';
  static const String stampBox = 'stamps';
  static const String planBox = 'plans';
  static const String recordBox = 'records';
  static const String cacheBox = 'cache';
  static const String weatherBox = 'weather';
  static const String settingsBox = 'settings';
  static const String favoriteBox = 'favorites';
  static const String reviewBox = 'reviews';
  static const String badgeBox = 'badges';

  // Cache TTL
  static const Duration mountainCacheTtl = Duration(hours: 24);
  static const Duration weatherCacheTtl = Duration(hours: 3);

  // GPS
  static const double summitThresholdMeters = 200; // 정상 도착 판정 반경 (미터)
  static const double defaultLat = 37.5665; // 서울 기본 좌표
  static const double defaultLng = 126.9780;

  /// dotenv에서 값을 읽되, 초기화되지 않은 경우 기본값 반환
  static String _env(String key, String fallback) {
    try {
      return dotenv.get(key, fallback: fallback);
    } catch (e) {
      debugPrint('AppConstants._env($key) error: $e');
      return fallback;
    }
  }
}
