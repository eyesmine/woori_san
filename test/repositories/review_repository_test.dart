import 'package:flutter_test/flutter_test.dart';
import 'package:woori_san/models/review.dart';
import 'package:woori_san/datasources/local/review_local.dart';
import 'package:woori_san/datasources/remote/review_remote.dart';
import 'package:woori_san/repositories/review_repository.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class FakeReviewLocal implements ReviewLocalDataSource {
  final Map<String, List<Review>> _cache = {};
  bool shouldFail = false;

  @override
  List<Review>? getCached(String mountainId) {
    if (shouldFail) throw Exception('cache read error');
    return _cache[mountainId];
  }

  @override
  Future<void> cache(String mountainId, List<Review> reviews) async {
    _cache[mountainId] = reviews;
  }
}

class FakeReviewRemote implements ReviewRemoteDataSource {
  List<Review> reviewsToReturn = [];
  Review? createdReview;
  bool shouldFail = false;
  String? lastDeletedId;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<List<Review>> getReviews(String mountainId) async {
    if (shouldFail) throw Exception('network error');
    return reviewsToReturn;
  }

  @override
  Future<Review> createReview(String mountainId, Map<String, dynamic> data) async {
    if (shouldFail) throw Exception('create failed');
    createdReview = Review(
      id: '999',
      mountainId: mountainId,
      userId: data['user_id'] ?? 'u1',
      userNickname: data['user_nickname'] ?? 'tester',
      content: data['content'] ?? '',
      createdAt: DateTime(2025, 6, 1),
    );
    return createdReview!;
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    if (shouldFail) throw Exception('delete failed');
    lastDeletedId = reviewId;
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Review _review({
  String id = '1',
  String mountainId = 'mt-100',
  String content = 'Great hike!',
}) {
  return Review(
    id: id,
    mountainId: mountainId,
    userId: 'user-1',
    userNickname: 'Hiker',
    content: content,
    createdAt: DateTime(2025, 5, 20),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late FakeReviewLocal fakeLocal;
  late FakeReviewRemote fakeRemote;
  late ReviewRepository repo;

  setUp(() {
    fakeLocal = FakeReviewLocal();
    fakeRemote = FakeReviewRemote();
    repo = ReviewRepository(fakeLocal, fakeRemote);
  });

  group('ReviewRepository.getReviews', () {
    test('success: remote data is returned and cached locally', () async {
      final reviews = [
        _review(id: '1', content: 'Beautiful view'),
        _review(id: '2', content: 'Steep trail'),
      ];
      fakeRemote.reviewsToReturn = reviews;

      final result = await repo.getReviews('mt-100');

      expect(result.length, 2);
      expect(result.first.content, 'Beautiful view');
      // Verify cached
      expect(fakeLocal.getCached('mt-100'), isNotNull);
      expect(fakeLocal.getCached('mt-100')!.length, 2);
    });

    test('remote failure: falls back to cached data', () async {
      // Pre-populate cache
      final cached = [_review(id: '10', content: 'Cached review')];
      await fakeLocal.cache('mt-200', cached);

      fakeRemote.shouldFail = true;

      final result = await repo.getReviews('mt-200');

      expect(result.length, 1);
      expect(result.first.content, 'Cached review');
    });

    test('remote failure + cache miss: rethrows the original error', () async {
      fakeRemote.shouldFail = true;
      // No cache for this mountain

      expect(
        () => repo.getReviews('mt-unknown'),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('network error'),
        )),
      );
    });

    test('remote failure + cache failure: rethrows the original remote error', () async {
      fakeRemote.shouldFail = true;
      fakeLocal.shouldFail = true;

      expect(
        () => repo.getReviews('mt-broken'),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('network error'),
        )),
      );
    });
  });

  group('ReviewRepository.createReview', () {
    test('delegates to remote and returns created review', () async {
      final data = {
        'content': 'Amazing summit!',
        'rating': 5.0,
        'user_id': 'u1',
        'user_nickname': 'tester',
      };

      final result = await repo.createReview('mt-100', data);

      expect(result.id, '999');
      expect(result.mountainId, 'mt-100');
      expect(fakeRemote.createdReview, isNotNull);
    });

    test('rethrows on remote failure', () async {
      fakeRemote.shouldFail = true;

      expect(
        () => repo.createReview('mt-100', {'content': 'fail'}),
        throwsException,
      );
    });
  });

  group('ReviewRepository.deleteReview', () {
    test('delegates to remote data source', () async {
      await repo.deleteReview('review-42');

      expect(fakeRemote.lastDeletedId, 'review-42');
    });

    test('rethrows on remote failure', () async {
      fakeRemote.shouldFail = true;

      expect(
        () => repo.deleteReview('review-42'),
        throwsException,
      );
    });
  });
}
