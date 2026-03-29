import 'package:flutter_test/flutter_test.dart';
import 'package:woori_san/models/hiking_plan.dart';
import 'package:woori_san/models/hiking_record.dart';
import 'package:woori_san/datasources/local/plan_local.dart';
import 'package:woori_san/repositories/plan_repository.dart';
import 'package:woori_san/providers/plan_provider.dart';

/// In-memory PlanLocalDataSource for testing
class FakePlanLocalDataSource implements PlanLocalDataSource {
  List<HikingPlan> _plans = [];
  List<ChecklistItem> _checklist = [
    ChecklistItem(text: '등산화'),
    ChecklistItem(text: '물'),
  ];
  List<HikingRecord> _records = [];

  @override
  List<HikingPlan> getPlans() => _plans;

  @override
  Future<void> savePlans(List<HikingPlan> plans) async {
    _plans = plans;
  }

  @override
  List<ChecklistItem> getChecklist() => _checklist;

  @override
  Future<void> saveChecklist(List<ChecklistItem> items) async {
    _checklist = items;
  }

  @override
  List<HikingRecord> getRecords() => _records;

  @override
  Future<void> saveRecords(List<HikingRecord> records) async {
    _records = records;
  }
}

/// PlanRepository variant that can be configured to throw on specific methods.
class FailingPlanRepository extends PlanRepository {
  bool shouldFailAdd = false;
  bool shouldFailDelete = false;
  bool shouldFailUpdateStatus = false;

  FailingPlanRepository(super.local);

  @override
  Future<HikingPlan> addPlan(HikingPlan plan) async {
    if (shouldFailAdd) throw Exception('addPlan server error');
    return super.addPlan(plan);
  }

  @override
  Future<void> deletePlan(String id) async {
    if (shouldFailDelete) throw Exception('deletePlan server error');
    return super.deletePlan(id);
  }

  @override
  Future<void> updatePlanStatus(HikingPlan plan) async {
    if (shouldFailUpdateStatus) throw Exception('updatePlanStatus server error');
    return super.updatePlanStatus(plan);
  }
}

void main() {
  late PlanProvider provider;
  late FailingPlanRepository failingRepo;
  late FakePlanLocalDataSource fakeLocal;

  setUp(() {
    fakeLocal = FakePlanLocalDataSource();
    failingRepo = FailingPlanRepository(fakeLocal);
    provider = PlanProvider(failingRepo);
  });

  HikingPlan makePlan(String id, String mountain, {PlanStatus status = PlanStatus.pending}) {
    return HikingPlan(
      id: id,
      mountain: mountain,
      date: '3월 15일',
      status: status,
      emoji: '⛰️',
    );
  }

  group('PlanProvider rollback', () {
    group('addPlan rollback', () {
      test('removes plan from list when repo.addPlan throws', () async {
        failingRepo.shouldFailAdd = true;

        await provider.addPlan(makePlan('p1', '북한산'));

        expect(provider.plans, isEmpty,
            reason: 'Plan should be rolled back after addPlan failure');
      });

      test('keeps existing plans intact when new addPlan fails', () async {
        // First, add a plan successfully
        await provider.addPlan(makePlan('p1', '북한산'));
        expect(provider.plans.length, 1);

        // Now enable failure and try to add another
        failingRepo.shouldFailAdd = true;
        await provider.addPlan(makePlan('p2', '관악산'));

        expect(provider.plans.length, 1,
            reason: 'Only the failed plan should be removed');
        expect(provider.plans.first.id, 'p1');
      });

      test('addPlan succeeds when repo does not throw', () async {
        await provider.addPlan(makePlan('p1', '북한산'));

        expect(provider.plans.length, 1);
        expect(provider.plans.first.mountain, '북한산');
      });
    });

    group('removePlan rollback', () {
      test('restores plan to the list when repo.deletePlan throws', () async {
        // Add plan successfully first
        await provider.addPlan(makePlan('p1', '북한산'));
        expect(provider.plans.length, 1);

        // Enable failure and try to remove
        failingRepo.shouldFailDelete = true;
        await provider.removePlan('p1');

        expect(provider.plans.length, 1,
            reason: 'Plan should be restored after deletePlan failure');
        expect(provider.plans.first.id, 'p1');
        expect(provider.plans.first.mountain, '북한산');
      });

      test('restores plan at correct position when repo.deletePlan throws', () async {
        // Add three plans
        await provider.addPlan(makePlan('p1', '북한산'));
        await provider.addPlan(makePlan('p2', '관악산'));
        await provider.addPlan(makePlan('p3', '설악산'));
        expect(provider.plans.length, 3);

        // Enable failure and try to remove the middle one
        failingRepo.shouldFailDelete = true;
        await provider.removePlan('p2');

        expect(provider.plans.length, 3,
            reason: 'Plan should be restored after failure');
        expect(provider.plans[0].id, 'p1');
        expect(provider.plans[1].id, 'p2');
        expect(provider.plans[2].id, 'p3');
      });

      test('removePlan succeeds when repo does not throw', () async {
        await provider.addPlan(makePlan('p1', '북한산'));
        expect(provider.plans.length, 1);

        await provider.removePlan('p1');
        expect(provider.plans, isEmpty);
      });

      test('removePlan does nothing with non-existent id even when failing', () async {
        await provider.addPlan(makePlan('p1', '북한산'));
        failingRepo.shouldFailDelete = true;

        await provider.removePlan('non_existent');

        expect(provider.plans.length, 1,
            reason: 'Non-existent id should be a no-op');
      });
    });

    group('updatePlanStatus rollback', () {
      test('reverts to previous status when repo.updatePlanStatus throws', () async {
        await provider.addPlan(makePlan('p1', '북한산', status: PlanStatus.pending));
        expect(provider.plans.first.status, PlanStatus.pending);

        failingRepo.shouldFailUpdateStatus = true;
        await provider.updatePlanStatus('p1', PlanStatus.confirmed);

        expect(provider.plans.first.status, PlanStatus.pending,
            reason: 'Status should revert to pending after failure');
      });

      test('reverts confirmed to pending on failure', () async {
        await provider.addPlan(makePlan('p1', '북한산', status: PlanStatus.confirmed));
        expect(provider.plans.first.status, PlanStatus.confirmed);

        failingRepo.shouldFailUpdateStatus = true;
        await provider.updatePlanStatus('p1', PlanStatus.done);

        expect(provider.plans.first.status, PlanStatus.confirmed,
            reason: 'Status should revert to confirmed after failure');
      });

      test('updatePlanStatus succeeds when repo does not throw', () async {
        await provider.addPlan(makePlan('p1', '북한산', status: PlanStatus.pending));

        await provider.updatePlanStatus('p1', PlanStatus.confirmed);

        expect(provider.plans.first.status, PlanStatus.confirmed);
      });

      test('updatePlanStatus with non-existent id is a no-op even when failing', () async {
        await provider.addPlan(makePlan('p1', '북한산', status: PlanStatus.pending));
        failingRepo.shouldFailUpdateStatus = true;

        await provider.updatePlanStatus('non_existent', PlanStatus.confirmed);

        expect(provider.plans.first.status, PlanStatus.pending,
            reason: 'Original plan status should remain unchanged');
      });

      test('other plans are not affected by rollback', () async {
        await provider.addPlan(makePlan('p1', '북한산', status: PlanStatus.pending));
        await provider.addPlan(makePlan('p2', '관악산', status: PlanStatus.confirmed));

        failingRepo.shouldFailUpdateStatus = true;
        await provider.updatePlanStatus('p1', PlanStatus.done);

        expect(provider.plans[0].status, PlanStatus.pending,
            reason: 'p1 should revert');
        expect(provider.plans[1].status, PlanStatus.confirmed,
            reason: 'p2 should remain unchanged');
      });
    });
  });
}
