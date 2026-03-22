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
  List<Mountain> _recommended = [];
  late List<HikingRecord> _records;
  bool _isLoading = false;
  String? _error;

  MountainProvider(this._mountainRepo, this._planRepo) {
    _records = _planRepo.getRecords();
    _loadAllMountains();
  }

  /// 전체 산 목록 (검색, 지도, 도장 등에서 사용)
  List<Mountain> get mountains => _mountains;

  /// 추천 코스 (홈 화면에서 사용)
  List<Mountain> get recommended => _recommended;

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

  Future<void> _loadAllMountains() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _mountains = await _mountainRepo.getAllMountains();
      debugPrint('MountainProvider: 산 ${_mountains.length}개 로드 완료');
    } catch (e) {
      _error = '산 목록을 불러올 수 없습니다.';
      debugPrint('MountainProvider._loadAllMountains error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadRecommended({double? lat, double? lng}) async {
    try {
      _recommended = await _mountainRepo.getRecommended(lat: lat, lng: lng);
      notifyListeners();
    } catch (e) {
      debugPrint('MountainProvider.loadRecommended error: $e');
    }
  }

  Future<void> refresh({double? lat, double? lng}) async {
    await Future.wait([
      _mountainRepo.getAllMountains(forceRefresh: true).then((v) => _mountains = v),
      _mountainRepo.getRecommended(lat: lat, lng: lng).then((v) => _recommended = v),
    ]);
    notifyListeners();
  }

  Future<Mountain?> getMountainDetail(String id) async {
    try {
      return await _mountainRepo.getDetail(id);
    } catch (e) {
      debugPrint('MountainProvider.getMountainDetail error: $e');
      return null;
    }
  }

  void addRecord(HikingRecord record) {
    _records.insert(0, record);
    _planRepo.saveRecords(_records);
    notifyListeners();
  }
}
