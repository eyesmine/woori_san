class AppConstants {
  static const String appName = '우리산';
  static const String apiBaseUrl = 'https://api.example.com/v1';

  // Hive box names
  static const String mountainBox = 'mountains';
  static const String stampBox = 'stamps';
  static const String planBox = 'plans';
  static const String recordBox = 'records';
  static const String cacheBox = 'cache';

  // Cache TTL
  static const Duration mountainCacheTtl = Duration(hours: 24);
  static const Duration weatherCacheTtl = Duration(hours: 3);
}
