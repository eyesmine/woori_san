import 'dart:convert';
import 'package:hive/hive.dart';
import '../../core/constants.dart';

class FavoriteLocalDataSource {
  Box get _box => Hive.box(AppConstants.favoriteBox);
  static const _key = 'favoriteIds';

  List<String> getAll() {
    final raw = _box.get(_key);
    if (raw == null) return [];
    return List<String>.from(jsonDecode(raw as String));
  }

  Future<void> saveAll(List<String> ids) async {
    await _box.put(_key, jsonEncode(ids));
  }
}
