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

void main() {
  late PlanProvider provider;
  late FakePlanLocalDataSource fakeLocal;

  setUp(() {
    fakeLocal = FakePlanLocalDataSource();
    final repo = PlanRepository(fakeLocal);
    provider = PlanProvider(repo);
  });

  group('PlanProvider', () {
    test('initializes with empty plans and default checklist', () {
      expect(provider.plans, isEmpty);
      expect(provider.checklist.length, 2);
    });

    test('addPlan adds a plan', () {
      final plan = HikingPlan(
        id: 'p1',
        mountain: '북한산',
        date: '3월 15일',
        status: PlanStatus.confirmed,
        emoji: '⛰️',
      );

      provider.addPlan(plan);

      expect(provider.plans.length, 1);
      expect(provider.plans.first.mountain, '북한산');
    });

    test('removePlan removes by id', () {
      provider.addPlan(HikingPlan(id: 'p1', mountain: '북한산', date: '3월 15일', status: PlanStatus.confirmed, emoji: '⛰️'));
      provider.addPlan(HikingPlan(id: 'p2', mountain: '관악산', date: '3월 22일', status: PlanStatus.pending, emoji: '🌄'));

      expect(provider.plans.length, 2);

      provider.removePlan('p1');

      expect(provider.plans.length, 1);
      expect(provider.plans.first.id, 'p2');
    });

    test('removePlan does nothing with non-existent id', () {
      provider.addPlan(HikingPlan(id: 'p1', mountain: '북한산', date: '3월 15일', status: PlanStatus.confirmed, emoji: '⛰️'));

      provider.removePlan('non_existent');

      expect(provider.plans.length, 1);
    });

    test('toggleChecklistItem toggles checked state', () {
      expect(provider.checklist[0].checked, false);

      provider.toggleChecklistItem(0);
      expect(provider.checklist[0].checked, true);

      provider.toggleChecklistItem(0);
      expect(provider.checklist[0].checked, false);
    });

    test('changes are persisted', () {
      provider.addPlan(HikingPlan(id: 'p1', mountain: '수락산', date: '4월 1일', status: PlanStatus.pending, emoji: '🍃'));

      final persisted = fakeLocal.getPlans();
      expect(persisted.length, 1);
      expect(persisted.first.mountain, '수락산');
    });

    test('updatePlanStatus changes plan status', () {
      provider.addPlan(HikingPlan(
        mountain: '북한산',
        date: '3월 15일',
        status: PlanStatus.pending,
        emoji: '⛰️',
      ));

      final planId = provider.plans.first.id;
      provider.updatePlanStatus(planId, PlanStatus.confirmed);
      expect(provider.plans.first.status, PlanStatus.confirmed);
    });

    test('updatePlanStatus with non-existent id does nothing', () {
      provider.addPlan(HikingPlan(
        mountain: '북한산',
        date: '3월 15일',
        status: PlanStatus.pending,
        emoji: '⛰️',
      ));

      provider.updatePlanStatus('non_existent', PlanStatus.confirmed);
      expect(provider.plans.first.status, PlanStatus.pending);
    });

    test('updatePlanStatus from confirmed to pending', () {
      provider.addPlan(HikingPlan(
        mountain: '북한산',
        date: '3월 15일',
        status: PlanStatus.confirmed,
        emoji: '⛰️',
      ));

      final planId = provider.plans.first.id;
      provider.updatePlanStatus(planId, PlanStatus.pending);
      expect(provider.plans.first.status, PlanStatus.pending);
    });
  });
}
