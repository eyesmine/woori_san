import 'package:flutter/material.dart';
import '../models/hiking_plan.dart';
import '../repositories/plan_repository.dart';

class PlanProvider extends ChangeNotifier {
  final PlanRepository _repo;

  late List<HikingPlan> _plans;
  late List<ChecklistItem> _checklist;

  PlanProvider(this._repo) {
    _plans = _repo.getPlans();
    _checklist = _repo.getChecklist();
  }

  List<HikingPlan> get plans => _plans;
  List<ChecklistItem> get checklist => _checklist;

  void addPlan(HikingPlan plan) {
    _plans.add(plan);
    _repo.savePlans(_plans);
    notifyListeners();
  }

  void removePlan(String id) {
    _plans.removeWhere((p) => p.id == id);
    _repo.savePlans(_plans);
    notifyListeners();
  }

  void updatePlanStatus(String id, PlanStatus status) {
    final index = _plans.indexWhere((p) => p.id == id);
    if (index == -1) return;
    _plans[index] = HikingPlan(
      id: _plans[index].id,
      mountain: _plans[index].mountain,
      mountainId: _plans[index].mountainId,
      date: _plans[index].date,
      status: status,
      emoji: _plans[index].emoji,
      memo: _plans[index].memo,
    );
    _repo.savePlans(_plans);
    notifyListeners();
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
