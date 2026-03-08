import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/stamp_mountain.dart';
import '../models/plan.dart';
import '../models/hiking_record.dart';

class StorageService {
  static const _stampKey = 'stamp_mountains';
  static const _planKey = 'plans';
  static const _checklistKey = 'checklist';
  static const _recordKey = 'hiking_records';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // Stamp Mountains
  List<StampMountain> loadStamps() {
    final data = _prefs.getString(_stampKey);
    if (data == null) return defaultStampMountains;
    final list = jsonDecode(data) as List;
    return list.map((e) => StampMountain.fromJson(e)).toList();
  }

  Future<void> saveStamps(List<StampMountain> stamps) async {
    await _prefs.setString(_stampKey, jsonEncode(stamps.map((e) => e.toJson()).toList()));
  }

  // Plans
  List<Plan> loadPlans() {
    final data = _prefs.getString(_planKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => Plan.fromJson(e)).toList();
  }

  Future<void> savePlans(List<Plan> plans) async {
    await _prefs.setString(_planKey, jsonEncode(plans.map((e) => e.toJson()).toList()));
  }

  // Checklist
  List<ChecklistItem> loadChecklist() {
    final data = _prefs.getString(_checklistKey);
    if (data == null) return defaultChecklist;
    final list = jsonDecode(data) as List;
    return list.map((e) => ChecklistItem.fromJson(e)).toList();
  }

  Future<void> saveChecklist(List<ChecklistItem> items) async {
    await _prefs.setString(_checklistKey, jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  // Hiking Records
  List<HikingRecord> loadRecords() {
    final data = _prefs.getString(_recordKey);
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
    await _prefs.setString(_recordKey, jsonEncode(records.map((e) => e.toJson()).toList()));
  }
}
