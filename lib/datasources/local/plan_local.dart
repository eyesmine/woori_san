import 'dart:convert';
import 'package:hive/hive.dart';
import '../../core/constants.dart';
import '../../models/hiking_plan.dart';
import '../../models/hiking_record.dart';

class PlanLocalDataSource {
  Box get _box => Hive.box(AppConstants.planBox);

  static const _planKey = 'plans';
  static const _checklistKey = 'checklist';
  static const _recordKey = 'records';

  // Plans
  List<HikingPlan> getPlans() {
    final data = _box.get(_planKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => HikingPlan.fromJson(e)).toList();
  }

  Future<void> savePlans(List<HikingPlan> plans) async {
    await _box.put(_planKey, jsonEncode(plans.map((e) => e.toJson()).toList()));
  }

  // Checklist
  List<ChecklistItem> getChecklist() {
    final data = _box.get(_checklistKey);
    if (data == null) return defaultChecklist;
    final list = jsonDecode(data) as List;
    return list.map((e) => ChecklistItem.fromJson(e)).toList();
  }

  Future<void> saveChecklist(List<ChecklistItem> items) async {
    await _box.put(_checklistKey, jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  // Records
  List<HikingRecord> getRecords() {
    final data = _box.get(_recordKey);
    if (data == null) {
      return [
        HikingRecord(id: '1', mountain: '북한산', date: '2025.02.15', duration: '4시간 23분', distance: '8.2km', emoji: '🌲'),
        HikingRecord(id: '2', mountain: '관악산', date: '2025.02.01', duration: '3시간 10분', distance: '6.5km', emoji: '⛅'),
      ];
    }
    final list = jsonDecode(data) as List;
    return list.map((e) => HikingRecord.fromJson(e)).toList();
  }

  Future<void> saveRecords(List<HikingRecord> records) async {
    await _box.put(_recordKey, jsonEncode(records.map((e) => e.toJson()).toList()));
  }
}
