import 'package:flutter/foundation.dart';
import '../models/mountain.dart';
import '../datasources/local/mountain_local.dart';
import '../datasources/remote/mountain_remote.dart';

class MountainRepository {
  final MountainLocalDataSource _local;
  final MountainRemoteDataSource? _remote;

  MountainRepository(this._local, [this._remote]);

  /// 위치 기반 추천 (캐시 안 함 — 매번 새로 호출)
  Future<List<Mountain>> getRecommended({double? lat, double? lng}) async {
    if (_remote != null) {
      try {
        return await _remote.getRecommended(lat: lat, lng: lng);
      } catch (e) {
        debugPrint('MountainRepository.getRecommended remote error: $e');
      }
    }
    // 폴백: 전체 목록에서 앞 10개
    final all = await getAllMountains();
    return all.take(10).toList();
  }

  /// 전체 산 목록 (항상 원격 시도 → 캐시는 오프라인 폴백용)
  Future<List<Mountain>> getAllMountains({bool forceRefresh = false}) async {
    if (_remote != null) {
      try {
        final remote = await _remote.getMountains();
        await _local.cache(remote);
        return remote;
      } catch (e) {
        debugPrint('MountainRepository.getAllMountains remote error: $e');
      }
    }

    // 오프라인 폴백: 캐시 → 기본값
    final cached = await _local.getCached();
    if (cached != null) return cached;

    return defaultMountains;
  }

  Future<Mountain?> getDetail(String id) async {
    if (_remote == null) return null;
    return await _remote.getDetail(id);
  }
}
