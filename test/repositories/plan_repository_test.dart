import 'package:flutter_test/flutter_test.dart';
import 'package:woori_san/core/api_client.dart';
import 'package:woori_san/datasources/local/plan_local.dart';
import 'package:woori_san/datasources/remote/plan_remote.dart';
import 'package:woori_san/models/hiking_plan.dart';
import 'package:woori_san/models/hiking_record.dart';
import 'package:woori_san/repositories/plan_repository.dart';

class FakePlanLocal implements PlanLocalDataSource {
  List<HikingPlan> _plans = [];

  @override
  List<HikingPlan> getPlans() => List.of(_plans);

  @override
  Future<void> savePlans(List<HikingPlan> plans) async {
    _plans = List.of(plans);
  }

  @override
  List<ChecklistItem> getChecklist() => [];

  @override
  Future<void> saveChecklist(List<ChecklistItem> items) async {}

  @override
  List<HikingRecord> getRecords() => [];

  @override
  Future<void> saveRecords(List<HikingRecord> records) async {}
}

class FakePlanRemote extends PlanRemoteDataSource {
  int createCalls = 0;
  int deleteCalls = 0;
  int updateStatusCalls = 0;

  FakePlanRemote() : super(ApiClient());

  @override
  Future<HikingPlan> createPlan(HikingPlan plan) async {
    createCalls++;
    return plan.copyWith(id: 'remote-1');
  }

  @override
  Future<void> deletePlan(String id) async {
    deleteCalls++;
  }

  @override
  Future<void> updateStatus(String id, String status) async {
    updateStatusCalls++;
  }
}

void main() {
  group('PlanRepository', () {
    test('addPlan stores remote id without duplicating plans', () async {
      final local = FakePlanLocal();
      final remote = FakePlanRemote();
      final repo = PlanRepository(local, remote);
      final plan = HikingPlan(
        id: 'local-1',
        mountain: '북한산',
        mountainId: 1,
        date: '2026-03-30',
        status: PlanStatus.pending,
        emoji: '⛰️',
      );

      final saved = await repo.addPlan(plan);

      expect(saved.id, 'remote-1');
      expect(local.getPlans(), hasLength(1));
      expect(local.getPlans().first.id, 'remote-1');
      expect(remote.createCalls, 1);
    });

    test('updatePlanStatus updates local plan and calls remote status API once', () async {
      final local = FakePlanLocal();
      final remote = FakePlanRemote();
      final repo = PlanRepository(local, remote);
      await local.savePlans([
        HikingPlan(
          id: 'remote-1',
          mountain: '북한산',
          date: '2026-03-30',
          status: PlanStatus.pending,
          emoji: '⛰️',
        ),
      ]);

      await repo.updatePlanStatus(
        local.getPlans().first.copyWith(status: PlanStatus.confirmed),
      );

      expect(local.getPlans().first.status, PlanStatus.confirmed);
      expect(remote.updateStatusCalls, 1);
    });

    test('deletePlan removes local plan and calls remote delete once', () async {
      final local = FakePlanLocal();
      final remote = FakePlanRemote();
      final repo = PlanRepository(local, remote);
      await local.savePlans([
        HikingPlan(
          id: 'remote-1',
          mountain: '북한산',
          date: '2026-03-30',
          status: PlanStatus.pending,
          emoji: '⛰️',
        ),
      ]);

      await repo.deletePlan('remote-1');

      expect(local.getPlans(), isEmpty);
      expect(remote.deleteCalls, 1);
    });
  });
}
