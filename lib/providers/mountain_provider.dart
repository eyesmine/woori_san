import 'package:flutter/foundation.dart';
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
  bool _isLoading = false;
  String? _error;

  MountainProvider(this._mountainRepo, this._planRepo) {
    _records = _planRepo.getRecords();
    _loadMountains();
  }

  List<Mountain> get mountains => _mountains;
  List<HikingRecord> get records => _records;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get totalHikes => _records.length;

  String get totalDistance {
    double total = 0;
    for (final r in _records) {
      total += r.distanceKm;
    }
    return '${total.toStringAsFixed(1)}km';
  }

  Mountain? getMountainById(String id) {
    final idx = _mountains.indexWhere((m) => m.id == id);
    return idx != -1 ? _mountains[idx] : null;
  }

  List<Mountain> search(String query, {Difficulty? difficulty, String? region}) {
    return _mountains.where((m) {
      if (query.isNotEmpty && !m.name.contains(query) && !m.location.contains(query)) {
        return false;
      }
      if (difficulty != null && m.difficulty != difficulty) return false;
      if (region != null && !m.location.contains(region)) return false;
      return true;
    }).toList();
  }

  Future<void> _loadMountains() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _mountains = await _mountainRepo.getRecommended();
    } catch (e) {
      _error = '산 목록을 불러올 수 없습니다.';
      debugPrint('MountainProvider._loadMountains error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await _loadMountains();
  }

  void addRecord(HikingRecord record) {
    _records.insert(0, record);
    _planRepo.saveRecords(_records);
    notifyListeners();
  }
}
