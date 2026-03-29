import 'dart:convert';
import 'package:hive/hive.dart';
import '../../core/constants.dart';
import '../../core/logger.dart';
import '../../models/review.dart';

class ReviewLocalDataSource {
  static const _ttl = Duration(hours: 1);

  Box get _box {
    try {
      return Hive.box(AppConstants.reviewBox);
    } catch (e) {
      AppLogger.error('Review Hive box 열기 실패', tag: 'ReviewLocal', error: e);
      rethrow;
    }
  }

  List<Review>? getCached(String mountainId) {
    try {
      final data = _box.get(mountainId);
      if (data == null) return null;

      final tsKey = '${mountainId}_ts';
      final ts = _box.get(tsKey);
      if (ts == null) return null; // timestamp 없으면 만료로 처리
      final cachedAt = DateTime.tryParse(ts.toString());
      if (cachedAt == null || DateTime.now().difference(cachedAt) > _ttl) {
        return null; // 캐시 만료
      }
      final list = jsonDecode(data) as List;
      return list.map((e) => Review.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      AppLogger.warning('Reviews 캐시 역직렬화 실패 (mountainId=$mountainId)', tag: 'ReviewLocal', error: e);
      return null;
    }
  }

  Future<void> cache(String mountainId, List<Review> reviews) async {
    final data = jsonEncode(reviews.map((e) => e.toJson()).toList());
    await _box.put(mountainId, data);
    await _box.put('${mountainId}_ts', DateTime.now().toIso8601String());
  }
}
