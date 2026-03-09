import 'dart:convert';
import 'package:hive/hive.dart';
import '../../core/constants.dart';
import '../../models/stamp.dart';

class StampLocalDataSource {
  Box get _box => Hive.box(AppConstants.stampBox);

  static const _key = 'stamps';

  List<Stamp> getAll() {
    final data = _box.get(_key);
    if (data == null) return defaultStamps;
    final list = jsonDecode(data) as List;
    return list.map((e) => Stamp.fromJson(e)).toList();
  }

  Future<void> saveAll(List<Stamp> stamps) async {
    await _box.put(_key, jsonEncode(stamps.map((e) => e.toJson()).toList()));
  }
}
