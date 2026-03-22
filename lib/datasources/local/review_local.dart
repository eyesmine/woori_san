import 'dart:convert';
import 'package:hive/hive.dart';
import '../../core/constants.dart';
import '../../models/review.dart';

class ReviewLocalDataSource {
  Box get _box => Hive.box(AppConstants.reviewBox);

  List<Review>? getCached(String mountainId) {
    final data = _box.get(mountainId);
    if (data == null) return null;
    final list = jsonDecode(data) as List;
    return list.map((e) => Review.fromJson(e)).toList();
  }

  Future<void> cache(String mountainId, List<Review> reviews) async {
    final data = jsonEncode(reviews.map((e) => e.toJson()).toList());
    await _box.put(mountainId, data);
  }
}
