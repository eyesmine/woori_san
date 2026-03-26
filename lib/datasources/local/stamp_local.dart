import 'dart:convert';
import 'package:hive/hive.dart';
import '../../core/constants.dart';
import '../../core/logger.dart';
import '../../models/stamp.dart';

class StampLocalDataSource {
  Box get _box => Hive.box(AppConstants.stampBox);

  static const _key = 'stamps';

  List<Stamp> getAll() {
    final data = _box.get(_key);
    if (data == null) return defaultStamps;
    try {
      final list = jsonDecode(data) as List;
      return list.map((e) => Stamp.fromJson(e)).toList();
    } catch (e) {
      AppLogger.warning('Stamps 역직렬화 실패, 기본값 반환', tag: 'StampLocal', error: e);
      return defaultStamps;
    }
  }

  Future<void> saveAll(List<Stamp> stamps) async {
    await _box.put(_key, jsonEncode(stamps.map((e) => e.toJson()).toList()));
  }
}
