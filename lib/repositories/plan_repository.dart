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
    // 서버 동기화 (실패해도 로컬은 저장됨)
    if (_remote != null) {
      try {
        for (final plan in plans) {
          await _remote.createPlan(plan);
        }
      } catch (e) {
        AppLogger.warning('계획 서버 동기화 실패', tag: 'PlanRepo', error: e);
      }
    }
  }

  // Checklist
  List<ChecklistItem> getChecklist() => _local.getChecklist();
  Future<void> saveChecklist(List<ChecklistItem> items) => _local.saveChecklist(items);

  // Records
  List<HikingRecord> getRecords() => _local.getRecords();
  Future<void> saveRecords(List<HikingRecord> records) => _local.saveRecords(records);
}
