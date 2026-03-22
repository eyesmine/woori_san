import 'package:hive/hive.dart';
import '../../core/constants.dart';
import '../../models/badge.dart';

class BadgeLocalDataSource {
  Box get _box => Hive.box(AppConstants.badgeBox);

  /// Returns a map of earned badge type names to their earned date ISO strings.
  Map<String, String> getEarnedBadges() {
    final Map<String, String> result = {};
    for (final key in _box.keys) {
      final value = _box.get(key);
      if (value is String) {
        result[key as String] = value;
      }
    }
    return result;
  }

  /// Saves an earned badge with its earned date.
  Future<void> saveEarnedBadge(BadgeType type, DateTime date) async {
    await _box.put(type.name, date.toIso8601String());
  }
}
