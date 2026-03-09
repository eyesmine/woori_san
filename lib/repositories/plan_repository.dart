import '../models/hiking_plan.dart';
import '../models/hiking_record.dart';
import '../datasources/local/plan_local.dart';

class PlanRepository {
  final PlanLocalDataSource _local;

  PlanRepository(this._local);

  // Plans
  List<HikingPlan> getPlans() => _local.getPlans();
  Future<void> savePlans(List<HikingPlan> plans) => _local.savePlans(plans);

  // Checklist
  List<ChecklistItem> getChecklist() => _local.getChecklist();
  Future<void> saveChecklist(List<ChecklistItem> items) => _local.saveChecklist(items);

  // Records
  List<HikingRecord> getRecords() => _local.getRecords();
  Future<void> saveRecords(List<HikingRecord> records) => _local.saveRecords(records);
}
