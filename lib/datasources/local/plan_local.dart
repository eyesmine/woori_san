import 'dart:convert';
import 'package:hive/hive.dart';
import '../../core/constants.dart';
import '../../core/logger.dart';
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
    try {
      final list = jsonDecode(data) as List;
      return list.map((e) => HikingPlan.fromJson(e)).toList();
    } catch (e) {
      AppLogger.warning('Plans 역직렬화 실패, 빈 목록 반환', tag: 'PlanLocal', error: e);
      return [];
    }
  }

  Future<void> savePlans(List<HikingPlan> plans) async {
    await _box.put(_planKey, jsonEncode(plans.map((e) => e.toJson()).toList()));
  }

  // Checklist
  List<ChecklistItem> getChecklist() {
    final data = _box.get(_checklistKey);
    if (data == null) return defaultChecklist;
    try {
      final list = jsonDecode(data) as List;
      return list.map((e) => ChecklistItem.fromJson(e)).toList();
    } catch (e) {
      AppLogger.warning('Checklist 역직렬화 실패, 기본값 반환', tag: 'PlanLocal', error: e);
      return defaultChecklist;
    }
  }

  Future<void> saveChecklist(List<ChecklistItem> items) async {
    await _box.put(_checklistKey, jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  // Records
  List<HikingRecord> getRecords() {
    final data = _box.get(_recordKey);
    if (data == null) return [];
    try {
      final list = jsonDecode(data) as List;
      return list.map((e) => HikingRecord.fromJson(e)).toList();
    } catch (e) {
      AppLogger.warning('Records 역직렬화 실패, 빈 목록 반환', tag: 'PlanLocal', error: e);
      return [];
    }
  }

  Future<void> saveRecords(List<HikingRecord> records) async {
    await _box.put(_recordKey, jsonEncode(records.map((e) => e.toJson()).toList()));
  }
}
