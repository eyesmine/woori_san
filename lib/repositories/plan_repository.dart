import '../core/logger.dart';
import '../models/hiking_plan.dart';
import '../models/hiking_record.dart';
import '../datasources/local/plan_local.dart';
import '../datasources/remote/plan_remote.dart';

class PlanRepository {
  final PlanLocalDataSource _local;
  final PlanRemoteDataSource? _remote;

  PlanRepository(this._local, [this._remote]);

  // Plans
  List<HikingPlan> getPlans() => _local.getPlans();

  Future<void> savePlans(List<HikingPlan> plans) async {
    await _local.savePlans(plans);
  }

  Future<HikingPlan> addPlan(HikingPlan plan) async {
    final plans = List<HikingPlan>.of(getPlans());
    plans.add(plan);
    await _local.savePlans(plans);

    if (_remote == null) return plan;

    try {
      final remotePlan = await _remote.createPlan(plan);
      final syncedPlans = getPlans()
          .map((existing) => existing.id == plan.id ? remotePlan : existing)
          .toList();
      await _local.savePlans(syncedPlans);
      return remotePlan;
    } catch (e) {
      AppLogger.warning('계획 생성 서버 동기화 실패', tag: 'PlanRepo', error: e);
      return plan;
    }
  }

  Future<void> updatePlanStatus(HikingPlan plan) async {
    final plans = List<HikingPlan>.of(getPlans());
    final index = plans.indexWhere((existing) => existing.id == plan.id);
    if (index == -1) return;

    plans[index] = plan;
    await _local.savePlans(plans);

    if (_remote == null) return;

    try {
      await _remote.updateStatus(plan.id, plan.status.name);
    } catch (e) {
      AppLogger.warning('계획 상태 서버 동기화 실패', tag: 'PlanRepo', error: e);
    }
  }

  Future<void> deletePlan(String id) async {
    final plans = List<HikingPlan>.of(getPlans())
      ..removeWhere((plan) => plan.id == id);
    await _local.savePlans(plans);

    if (_remote == null) return;

    try {
      await _remote.deletePlan(id);
    } catch (e) {
      AppLogger.warning('계획 삭제 서버 동기화 실패', tag: 'PlanRepo', error: e);
    }
  }

  // Checklist
  List<ChecklistItem> getChecklist() => _local.getChecklist();
  Future<void> saveChecklist(List<ChecklistItem> items) => _local.saveChecklist(items);

  // Records
  List<HikingRecord> getRecords() => _local.getRecords();
  Future<void> saveRecords(List<HikingRecord> records) => _local.saveRecords(records);
}
