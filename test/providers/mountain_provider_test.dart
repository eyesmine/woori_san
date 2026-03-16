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
  final List<HikingRecord> _records;

  FakePlanLocalDataSource([List<HikingRecord>? records])
      : _records = records ??
            [
              HikingRecord(id: '1', mountain: '북한산', date: '2025.02.15', duration: '4시간', distanceKm: 8.2, emoji: '🌲'),
              HikingRecord(id: '2', mountain: '관악산', date: '2025.02.01', duration: '3시간', distanceKm: 6.5, emoji: '⛅'),
            ];

  @override
  List<HikingPlan> getPlans() => [];
  @override
  Future<void> savePlans(List<HikingPlan> plans) async {}
  @override
  List<ChecklistItem> getChecklist() => [];
  @override
  Future<void> saveChecklist(List<ChecklistItem> items) async {}
  @override
  List<HikingRecord> getRecords() => _records;
  @override
  Future<void> saveRecords(List<HikingRecord> records) async {}
}

void main() {
  group('MountainProvider', () {
    test('totalHikes returns record count', () {
      final mountainRepo = MountainRepository(FakeMountainLocalDataSource());
      final planRepo = PlanRepository(FakePlanLocalDataSource());
      final provider = MountainProvider(mountainRepo, planRepo);

      expect(provider.totalHikes, 2);
    });

    test('totalDistance sums distanceKm from all records', () {
      final mountainRepo = MountainRepository(FakeMountainLocalDataSource());
      final planRepo = PlanRepository(FakePlanLocalDataSource());
      final provider = MountainProvider(mountainRepo, planRepo);

      expect(provider.totalDistance, '14.7km');
    });

    test('totalDistance with empty records returns 0.0km', () {
      final mountainRepo = MountainRepository(FakeMountainLocalDataSource());
      final planRepo = PlanRepository(FakePlanLocalDataSource([]));
      final provider = MountainProvider(mountainRepo, planRepo);

      expect(provider.totalDistance, '0.0km');
    });

    test('addRecord inserts at beginning', () {
      final mountainRepo = MountainRepository(FakeMountainLocalDataSource());
      final planRepo = PlanRepository(FakePlanLocalDataSource());
      final provider = MountainProvider(mountainRepo, planRepo);

      final newRecord = HikingRecord(
        mountain: '수락산',
        date: '2025.03.01',
        duration: '2시간',
        distanceKm: 5.5,
        emoji: '🍃',
      );

      provider.addRecord(newRecord);

      expect(provider.records.length, 3);
      expect(provider.records.first.mountain, '수락산');
      expect(provider.totalDistance, '20.2km');
    });

    test('loads defaultMountains when no cache exists', () async {
      final mountainRepo = MountainRepository(FakeMountainLocalDataSource());
      final planRepo = PlanRepository(FakePlanLocalDataSource());
      final provider = MountainProvider(mountainRepo, planRepo);

      // Wait for async _loadMountains to complete
      await Future.delayed(Duration.zero);

      expect(provider.mountains.length, defaultMountains.length);
    });

    test('isLoading is initially false after load', () async {
      final mountainRepo = MountainRepository(FakeMountainLocalDataSource());
      final planRepo = PlanRepository(FakePlanLocalDataSource());
      final provider = MountainProvider(mountainRepo, planRepo);

      // Wait for async _loadMountains to complete
      await Future.delayed(Duration.zero);

      // After construction and async load, isLoading should be false
      expect(provider.isLoading, isFalse);
    });

    test('error is initially null', () async {
      final mountainRepo = MountainRepository(FakeMountainLocalDataSource());
      final planRepo = PlanRepository(FakePlanLocalDataSource());
      final provider = MountainProvider(mountainRepo, planRepo);

      // Wait for async _loadMountains to complete
      await Future.delayed(Duration.zero);

      expect(provider.error, isNull);
    });
  });
}
