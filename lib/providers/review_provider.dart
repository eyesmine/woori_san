import 'package:flutter/foundation.dart';
import '../core/exceptions.dart';
import '../core/logger.dart';
import '../models/review.dart';
import '../repositories/review_repository.dart';

class ReviewProvider extends ChangeNotifier {
  final ReviewRepository _repo;

  List<Review> _reviews = [];
  bool _isLoading = false;
  String? _error;

  ReviewProvider(this._repo);

  List<Review> get reviews => _reviews;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadReviews(String mountainId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _reviews = await _repo.getReviews(mountainId);
    } on NetworkException {
      _error = '네트워크 연결을 확인해주세요.';
    } catch (e) {
      _error = '리뷰를 불러올 수 없습니다.';
      AppLogger.error('loadReviews 실패', tag: 'ReviewProvider', error: e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createReview(
    String mountainId,
    String content,
    double? rating,
    List<String> photoUrls,
  ) async {
    try {
      final data = <String, dynamic>{
        'content': content,
      };
      if (rating != null) data['rating'] = rating;
      if (photoUrls.isNotEmpty) data['photo_urls'] = photoUrls;

      final created = await _repo.createReview(mountainId, data);
      _reviews.insert(0, created);
      notifyListeners();
      return true;
    } on NetworkException {
      _error = '네트워크 연결을 확인해주세요.';
    } on ValidationException catch (e) {
      _error = e.firstFieldError;
    } catch (e) {
      _error = '리뷰 작성에 실패했습니다.';
      AppLogger.error('createReview 실패', tag: 'ReviewProvider', error: e);
    }
    notifyListeners();
    return false;
  }

  Future<bool> deleteReview(String reviewId, String mountainId) async {
    try {
      await _repo.deleteReview(reviewId);
      await loadReviews(mountainId);
      return true;
    } on NetworkException {
      _error = '네트워크 연결을 확인해주세요.';
    } catch (e) {
      _error = '리뷰 삭제에 실패했습니다.';
      AppLogger.error('deleteReview 실패', tag: 'ReviewProvider', error: e);
    }
    notifyListeners();
    return false;
  }
}
