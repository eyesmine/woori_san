import 'dart:convert';
import 'package:hive/hive.dart';
import '../../core/constants.dart';
import '../../core/logger.dart';
import '../../models/mountain.dart';

class MountainLocalDataSource {
  Box get _box => Hive.box(AppConstants.cacheBox);

  static const _cacheKey = 'mountains_cache';
  static const _cacheTimeKey = 'mountains_cache_time';

  Future<List<Mountain>?> getCached() async {
    final data = _box.get(_cacheKey);
    if (data == null) return null;

    final cacheTime = _box.get(_cacheTimeKey);
    if (cacheTime != null) {
      final expiry = DateTime.parse(cacheTime);
      if (DateTime.now().isAfter(expiry)) {
        await clearCache();
        return null;
      }
    }

    try {
      final list = jsonDecode(data) as List;
      return list.map((e) => Mountain.fromJson(e)).toList();
    } catch (e) {
      AppLogger.warning('Mountains 캐시 역직렬화 실패', tag: 'MountainLocal', error: e);
      await clearCache();
      return null;
    }
  }

  Future<void> cache(List<Mountain> mountains) async {
    final data = jsonEncode(mountains.map((e) => e.toJson()).toList());
    final expiry = DateTime.now().add(AppConstants.mountainCacheTtl).toIso8601String();
    await _box.put(_cacheKey, data);
    await _box.put(_cacheTimeKey, expiry);
  }

  Future<void> clearCache() async {
    await _box.delete(_cacheKey);
    await _box.delete(_cacheTimeKey);
  }
}
