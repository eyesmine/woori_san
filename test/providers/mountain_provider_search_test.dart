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
      expect(mountain!.name, '가리산');
      expect(mountain.id, 'mt_1');
    });

    test('returns null for unknown id', () {
      final mountain = provider.getMountainById('nonexistent');

      expect(mountain, isNull);
    });

    test('returns each mountain by its id', () {
      expect(provider.getMountainById('mt_1')!.name, '가리산');
      expect(provider.getMountainById('mt_2')!.name, '가리왕산');
      expect(provider.getMountainById('mt_3')!.name, '가야산');
      expect(provider.getMountainById('mt_100'), isNotNull);
    });
  });

  group('MountainProvider.search', () {
    test('with name query returns matching mountains', () {
      final results = provider.search('설악산');

      expect(results, hasLength(1));
      expect(results.first.name, '설악산');
    });

    test('with partial name query returns matching mountains', () {
      final results = provider.search('산');

      // Most mountains contain '산' in their name (some end with '봉')
      expect(results.length, greaterThan(90));
    });

    test('with difficulty filter returns correct difficulty', () {
      final results = provider.search('', difficulty: Difficulty.advanced);

      for (final m in results) {
        expect(m.difficulty, Difficulty.advanced);
      }
      // Should have some advanced mountains (height > 1200m)
      expect(results.length, greaterThan(0));
    });

    test('with empty query returns all mountains', () {
      final results = provider.search('');

      expect(results, hasLength(defaultMountains.length));
    });

    test('with non-matching query returns empty list', () {
      final results = provider.search('존재하지않는산');

      expect(results, isEmpty);
    });

    test('with non-matching difficulty for specific mountain returns empty', () {
      // 설악산 is advanced (1708m), not beginner
      final results = provider.search('설악산', difficulty: Difficulty.beginner);

      expect(results, isEmpty);
    });

    test('with combined query and region filters', () {
      final results = provider.search('관악', region: '서울');

      expect(results, hasLength(1));
      expect(results.first.name, '관악산');
    });
  });
}
