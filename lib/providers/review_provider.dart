import 'package:flutter/foundation.dart';
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
    } catch (e) {
      _error = e.toString();
      debugPrint('ReviewProvider.loadReviews error: $e');
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

      await _repo.createReview(mountainId, data);
      await loadReviews(mountainId);
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('ReviewProvider.createReview error: $e');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteReview(String reviewId, String mountainId) async {
    try {
      await _repo.deleteReview(reviewId);
      await loadReviews(mountainId);
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('ReviewProvider.deleteReview error: $e');
      notifyListeners();
      return false;
    }
  }
}
