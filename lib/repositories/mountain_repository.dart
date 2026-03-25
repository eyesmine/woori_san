import '../core/logger.dart';
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
        AppLogger.warning('MountainRepository.getRecommended remote error: $e');
      }
    }
    // 폴백: 전체 목록에서 앞 10개
    final all = await getAllMountains();
    return all.take(10).toList();
  }

  /// 전체 산 목록 (캐시 우선 → 백그라운드 갱신)
  Future<List<Mountain>> getAllMountains({bool forceRefresh = false}) async {
    // 캐시 먼저 반환 (빠른 시작)
    if (!forceRefresh) {
      final cached = await _local.getCached();
      if (cached != null && cached.length >= 50) {
        // 백그라운드에서 원격 갱신
        _refreshInBackground();
        return cached;
      }
    }

    // 캐시 없거나 강제 갱신
    if (_remote != null) {
      try {
        final remote = await _remote.getMountains();
        await _local.cache(remote);
        return remote;
      } catch (e) {
        AppLogger.warning('MountainRepository.getAllMountains remote error: $e');
      }
    }

    final cached = await _local.getCached();
    if (cached != null) return cached;

    return defaultMountains;
  }

  void _refreshInBackground() async {
    if (_remote == null) return;
    try {
      final remote = await _remote.getMountains();
      if (remote.isNotEmpty) {
        await _local.cache(remote);
      }
    } catch (e) {
      AppLogger.warning('MountainRepository._refreshInBackground error: $e');
    }
  }

  Future<Mountain?> getDetail(String id) async {
    if (_remote == null) return null;
    return await _remote.getDetail(id);
  }
}
