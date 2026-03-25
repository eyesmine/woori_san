import 'package:flutter/material.dart';
import '../core/logger.dart';
import '../models/hiking_plan.dart';
import '../repositories/plan_repository.dart';

class PlanProvider extends ChangeNotifier {
  final PlanRepository _repo;

  late List<HikingPlan> _plans;
  late List<ChecklistItem> _checklist;

  PlanProvider(this._repo) {
    _plans = List<HikingPlan>.of(_repo.getPlans());
    _checklist = _repo.getChecklist()
        .map((item) => ChecklistItem(text: item.text, checked: item.checked))
        .toList();
  }

  List<HikingPlan> get plans => _plans;
  List<ChecklistItem> get checklist => _checklist;

  Future<void> addPlan(HikingPlan plan) async {
    _plans.add(plan);
    notifyListeners();

    try {
      final savedPlan = await _repo.addPlan(plan);
      final index = _plans.indexWhere((existing) => existing.id == plan.id);
      if (index != -1) {
        _plans[index] = savedPlan;
        notifyListeners();
      }
    } catch (e) {
      AppLogger.error('addPlan 실패', tag: 'PlanProvider', error: e);
    }
  }

  Future<void> removePlan(String id) async {
    final index = _plans.indexWhere((p) => p.id == id);
    if (index == -1) return;

    _plans.removeAt(index);
    notifyListeners();

    try {
      await _repo.deletePlan(id);
    } catch (e) {
      AppLogger.error('removePlan 실패', tag: 'PlanProvider', error: e);
    }
  }

  Future<void> updatePlanStatus(String id, PlanStatus status) async {
    final index = _plans.indexWhere((p) => p.id == id);
    if (index == -1) return;

    final updated = _plans[index].copyWith(status: status);
    _plans[index] = updated;
    notifyListeners();

    try {
      await _repo.updatePlanStatus(updated);
    } catch (e) {
      AppLogger.error('updatePlanStatus 실패', tag: 'PlanProvider', error: e);
    }
  }

  void toggleChecklistItem(int index) {
    _checklist[index].checked = !_checklist[index].checked;
    _repo.saveChecklist(_checklist);
    notifyListeners();
  }

  void addChecklistItem(String text) {
    if (text.trim().isEmpty) return;
    _checklist.add(ChecklistItem(text: text.trim()));
    _repo.saveChecklist(_checklist);
    notifyListeners();
  }

  void removeChecklistItem(int index) {
    if (index < 0 || index >= _checklist.length) return;
    _checklist.removeAt(index);
    _repo.saveChecklist(_checklist);
    notifyListeners();
  }
}
