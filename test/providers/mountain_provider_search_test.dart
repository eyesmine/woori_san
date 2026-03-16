import 'package:flutter_test/flutter_test.dart';
import 'package:woori_san/models/mountain.dart';
import 'package:woori_san/models/hiking_plan.dart';
import 'package:woori_san/models/hiking_record.dart';
import 'package:woori_san/datasources/local/mountain_local.dart';
import 'package:woori_san/datasources/local/plan_local.dart';
import 'package:woori_san/repositories/mountain_repository.dart';
import 'package:woori_san/repositories/plan_repository.dart';
import 'package:woori_san/providers/mountain_provider.dart';

class FakeMountainLocalDataSource implements MountainLocalDataSource {
  List<Mountain>? _cached;

  @override
  Future<List<Mountain>?> getCached() async => _cached;

  @override
  Future<void> cache(List<Mountain> mountains) async {
    _cached = mountains;
  }

  @override
  Future<void> clearCache() async {
    _cached = null;
  }
}

class FakePlanLocalDataSource implements PlanLocalDataSource {
  @override
  List<HikingPlan> getPlans() => [];
  @override
  Future<void> savePlans(List<HikingPlan> plans) async {}
  @override
  List<ChecklistItem> getChecklist() => [];
  @override
  Future<void> saveChecklist(List<ChecklistItem> items) async {}
  @override
  List<HikingRecord> getRecords() => [];
  @override
  Future<void> saveRecords(List<HikingRecord> records) async {}
}

void main() {
  late MountainProvider provider;

  setUp(() async {
    final mountainRepo = MountainRepository(FakeMountainLocalDataSource());
    final planRepo = PlanRepository(FakePlanLocalDataSource());
    provider = MountainProvider(mountainRepo, planRepo);

    // Wait for async _loadMountains to complete
    await Future.delayed(Duration.zero);
  });

  group('MountainProvider.getMountainById', () {
    test('returns correct mountain for known id', () {
      final mountain = provider.getMountainById('mt_1');

      expect(mountain, isNotNull);
      expect(mountain!.name, '청계산');
      expect(mountain.id, 'mt_1');
    });

    test('returns null for unknown id', () {
      final mountain = provider.getMountainById('nonexistent');

      expect(mountain, isNull);
    });

    test('returns each mountain by its id', () {
      expect(provider.getMountainById('mt_1')!.name, '청계산');
      expect(provider.getMountainById('mt_2')!.name, '북한산');
      expect(provider.getMountainById('mt_3')!.name, '관악산');
      expect(provider.getMountainById('mt_4')!.name, '수락산');
    });
  });

  group('MountainProvider.search', () {
    test('with name query returns matching mountains', () {
      final results = provider.search('북한산');

      expect(results, hasLength(1));
      expect(results.first.name, '북한산');
    });

    test('with partial name query returns matching mountains', () {
      final results = provider.search('산');

      // All mountains contain '산' in their name
      expect(results, hasLength(defaultMountains.length));
    });

    test('with location query returns matching mountains', () {
      final results = provider.search('서울');

      // 청계산 (서울/경기), 북한산 (서울), 관악산 (서울) contain 서울
      expect(results, hasLength(3));
    });

    test('with difficulty filter returns correct mountains', () {
      final results = provider.search('', difficulty: Difficulty.beginner);

      // 청계산 and 수락산 are beginner
      expect(results, hasLength(2));
      for (final m in results) {
        expect(m.difficulty, Difficulty.beginner);
      }
    });

    test('with intermediate difficulty filter', () {
      final results = provider.search('', difficulty: Difficulty.intermediate);

      // 북한산 and 관악산 are intermediate
      expect(results, hasLength(2));
      for (final m in results) {
        expect(m.difficulty, Difficulty.intermediate);
      }
    });

    test('with region filter returns mountains in that region', () {
      final results = provider.search('', region: '노원');

      // Only 수락산 is in 노원
      expect(results, hasLength(1));
      expect(results.first.name, '수락산');
    });

    test('with combined name and difficulty filters', () {
      final results = provider.search('산', difficulty: Difficulty.beginner);

      // Beginner mountains that contain '산': 청계산, 수락산
      expect(results, hasLength(2));
      for (final m in results) {
        expect(m.difficulty, Difficulty.beginner);
        expect(m.name.contains('산'), true);
      }
    });

    test('with combined query and region filters', () {
      final results = provider.search('관악', region: '서울');

      expect(results, hasLength(1));
      expect(results.first.name, '관악산');
    });

    test('with combined difficulty and region filters', () {
      final results = provider.search('', difficulty: Difficulty.beginner, region: '노원');

      // Only 수락산 is beginner and in 노원
      expect(results, hasLength(1));
      expect(results.first.name, '수락산');
    });

    test('with empty query returns all mountains', () {
      final results = provider.search('');

      expect(results, hasLength(defaultMountains.length));
    });

    test('with non-matching query returns empty list', () {
      final results = provider.search('한라산');

      expect(results, isEmpty);
    });

    test('with non-matching difficulty for specific mountain returns empty', () {
      final results = provider.search('북한산', difficulty: Difficulty.beginner);

      // 북한산 is intermediate, not beginner
      expect(results, isEmpty);
    });
  });
}
