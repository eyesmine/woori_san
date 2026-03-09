import 'package:flutter/material.dart';
import '../models/mountain.dart';
import '../models/hiking_record.dart';
import '../repositories/mountain_repository.dart';
import '../repositories/plan_repository.dart';

class MountainProvider extends ChangeNotifier {
  final MountainRepository _mountainRepo;
  final PlanRepository _planRepo;

  List<Mountain> _mountains = [];
  late List<HikingRecord> _records;

  MountainProvider(this._mountainRepo, this._planRepo) {
    _records = _planRepo.getRecords();
    _loadMountains();
  }

  List<Mountain> get mountains => _mountains;
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

  Future<void> _loadMountains() async {
    _mountains = await _mountainRepo.getRecommended();
    notifyListeners();
  }

  void addRecord(HikingRecord record) {
    _records.insert(0, record);
    _planRepo.saveRecords(_records);
    notifyListeners();
  }
}
