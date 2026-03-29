import 'package:flutter/material.dart';
import '../core/exceptions.dart';
import '../core/logger.dart';
import '../models/mountain.dart';
import '../models/stamp.dart';
import '../repositories/stamp_repository.dart';

class StampProvider extends ChangeNotifier {
  final StampRepository _repo;

  late List<Stamp> _stamps;
  bool _isSyncing = false;

  StampProvider(this._repo) {
    _stamps = _repo.getAll();
  }

  /// 산 목록에서 누락된 도장을 추가 (백엔드 산 개수 변경 시 동기화)
  void syncWithMountains(List<Mountain> mountains) {
    final existingNames = _stamps.map((s) => s.name).toSet();
    bool added = false;
    for (final m in mountains) {
      if (!existingNames.contains(m.name)) {
        _stamps.add(Stamp(name: m.name, region: m.location, height: m.height));
        added = true;
      }
    }
    if (added) {
      _repo.saveAll(_stamps);
      notifyListeners();
    }
  }

  List<Stamp> get stamps => _stamps;
  int get totalStamped => _stamps.where((m) => m.isStamped).length;
  int get togetherStamped => _stamps.where((m) => m.isTogetherStamped).length;
  List<Stamp> get togetherStamps => _stamps.where((m) => m.isTogetherStamped).toList();
  bool get isSyncing => _isSyncing;

  /// 로컬 전용 토글 (UI 테스트, 오프라인용)
  void toggleStamp(int index, {bool together = false}) {
    if (index < 0 || index >= _stamps.length) return;
    final m = _stamps[index];
    final newStamped = !m.isStamped;
    if (newStamped) {
      _stamps[index] = m.copyWith(
        isStamped: true,
        stampDate: _formatDate(DateTime.now()),
        isTogetherStamped: together,
      );
    } else {
      _stamps[index] = m.copyWith(
        isStamped: false,
        isTogetherStamped: false,
        clearStampDate: true,
      );
    }
    _repo.saveAll(_stamps);
    notifyListeners();
  }

  /// POST /api/stamps/ — GPS 검증 후 도장 찍기 (서버 연동)
  Future<bool> createStamp({
    required String mountainId,
    required double lat,
    required double lng,
    bool together = false,
  }) async {
    try {
      await _repo.createStamp({
        'mountain': mountainId,
        'lat': lat,
        'lng': lng,
        'together': together,
      });
      await syncFromRemote();
      return true;
    } on NetworkException {
      AppLogger.warning('도장 생성 실패: 네트워크 오류', tag: 'StampProvider');
      return false;
    } catch (e) {
      AppLogger.error('createStamp 실패', tag: 'StampProvider', error: e);
      return false;
    }
  }

  /// 서버에서 도장 목록 동기화
  Future<void> syncFromRemote() async {
    _isSyncing = true;
    notifyListeners();
    try {
      _stamps = await _repo.syncFromRemote();
    } catch (e) {
      AppLogger.error('syncFromRemote 실패', tag: 'StampProvider', error: e);
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  void toggleTogetherStamp(int index) {
    if (index < 0 || index >= _stamps.length) return;
    final m = _stamps[index];
    if (!m.isStamped) return;
    _stamps[index] = m.copyWith(isTogetherStamped: !m.isTogetherStamped);
    _repo.saveAll(_stamps);
    notifyListeners();
  }

  String _formatDate(DateTime d) =>
      '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';
}
