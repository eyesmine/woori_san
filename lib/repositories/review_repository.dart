import '../core/logger.dart';
import '../models/review.dart';
import '../datasources/local/review_local.dart';
import '../datasources/remote/review_remote.dart';

class ReviewRepository {
  final ReviewLocalDataSource _local;
  final ReviewRemoteDataSource _remote;

  ReviewRepository(this._local, this._remote);

  Future<List<Review>> getReviews(String mountainId) async {
    try {
      final remote = await _remote.getReviews(mountainId);
      await _local.cache(mountainId, remote);
      return remote;
    } catch (e) {
      AppLogger.warning('리뷰 원격 조회 실패, 캐시 사용', tag: 'ReviewRepo', error: e);
      final cached = _local.getCached(mountainId);
      if (cached != null) return cached;
      rethrow;
    }
  }

  Future<void> createReview(String mountainId, Map<String, dynamic> data) async {
    await _remote.createReview(mountainId, data);
  }

  Future<void> deleteReview(String reviewId) async {
    await _remote.deleteReview(reviewId);
  }
}
