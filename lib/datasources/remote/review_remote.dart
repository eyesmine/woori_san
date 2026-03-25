import '../../core/api_client.dart';
import '../../models/review.dart';

class ReviewRemoteDataSource {
  final ApiClient api;

  ReviewRemoteDataSource(this.api);

  Future<List<Review>> getReviews(String mountainId) async {
    final response = await api.get('/mountains/$mountainId/reviews/');
    final data = response.data;

    // DRF pagination: { "results": [...], "count": N, "next": ..., "previous": ... }
    if (data is Map<String, dynamic> && data.containsKey('results')) {
      final results = data['results'] as List;
      return results.map((e) => Review.fromJson(e as Map<String, dynamic>)).toList();
    }

    // Plain list fallback
    if (data is List) {
      return data.map((e) => Review.fromJson(e as Map<String, dynamic>)).toList();
    }

    return [];
  }

  Future<Review> createReview(String mountainId, Map<String, dynamic> data) async {
    final response = await api.post('/mountains/$mountainId/reviews/', data: data);
    return Review.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteReview(String reviewId) async {
    await api.delete('/reviews/$reviewId/');
  }
}
