import 'dart:convert';
import 'package:hive/hive.dart';
import '../../core/constants.dart';
import '../../core/logger.dart';

class FavoriteLocalDataSource {
  Box get _box => Hive.box(AppConstants.favoriteBox);
  static const _key = 'favoriteIds';

  List<String> getAll() {
    final raw = _box.get(_key);
    if (raw == null) return [];
    try {
      return List<String>.from(jsonDecode(raw as String));
    } catch (e) {
      AppLogger.warning('Favorites 역직렬화 실패, 빈 목록 반환', tag: 'FavoriteLocal', error: e);
      return [];
    }
  }

  Future<void> saveAll(List<String> ids) async {
    await _box.put(_key, jsonEncode(ids));
  }
}
