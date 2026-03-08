import 'package:flutter/material.dart';
import '../models/stamp_mountain.dart';
import '../models/plan.dart';
import '../models/hiking_record.dart';
import '../services/storage_service.dart';

class AppState extends ChangeNotifier {
  final StorageService _storage;

  late List<StampMountain> _stamps;
  late List<Plan> _plans;
  late List<ChecklistItem> _checklist;
  late List<HikingRecord> _records;

  AppState(this._storage) {
    _stamps = _storage.loadStamps();
    _plans = _storage.loadPlans();
    _checklist = _storage.loadChecklist();
    _records = _storage.loadRecords();
  }

  // Stamps
  List<StampMountain> get stamps => _stamps;
  int get totalStamped => _stamps.where((m) => m.isStamped).length;
  int get togetherStamped => _stamps.where((m) => m.isTogetherStamped).length;
  List<StampMountain> get togetherStamps => _stamps.where((m) => m.isTogetherStamped).toList();

  void toggleStamp(int index, {bool together = false}) {
    final m = _stamps[index];
    m.isStamped = !m.isStamped;
    if (m.isStamped) {
      m.stampDate = _formatDate(DateTime.now());
      if (together) m.isTogetherStamped = true;
    } else {
      m.isTogetherStamped = false;
      m.stampDate = null;
    }
    _storage.saveStamps(_stamps);
    notifyListeners();
  }

  void toggleTogetherStamp(int index) {
    final m = _stamps[index];
    if (!m.isStamped) return;
    m.isTogetherStamped = !m.isTogetherStamped;
    _storage.saveStamps(_stamps);
    notifyListeners();
  }

  // Plans
  List<Plan> get plans => _plans;

  void addPlan(Plan plan) {
    _plans.add(plan);
    _storage.savePlans(_plans);
    notifyListeners();
  }

  void removePlan(String id) {
    _plans.removeWhere((p) => p.id == id);
    _storage.savePlans(_plans);
    notifyListeners();
  }

  // Checklist
  List<ChecklistItem> get checklist => _checklist;

  void toggleChecklistItem(int index) {
    _checklist[index].checked = !_checklist[index].checked;
    _storage.saveChecklist(_checklist);
    notifyListeners();
  }

  // Records
  List<HikingRecord> get records => _records;
  int get totalHikes => _records.length;

  String get totalDistance {
    double total = 0;
    for (final r in _records) {
      final numStr = r.distance.replaceAll(RegExp(r'[^0-9.]'), '');
      total += double.tryParse(numStr) ?? 0;
    }
    return '${total.toStringAsFixed(1)}km';
  }

  void addRecord(HikingRecord record) {
    _records.insert(0, record);
    _storage.saveRecords(_records);
    notifyListeners();
  }

  String _formatDate(DateTime d) =>
      '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';
}
