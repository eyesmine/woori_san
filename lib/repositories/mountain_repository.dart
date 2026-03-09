import '../models/mountain.dart';
import '../datasources/local/mountain_local.dart';

class MountainRepository {
  final MountainLocalDataSource _local;

  MountainRepository(this._local);

  Future<List<Mountain>> getRecommended() async {
    // 1. 로컬 캐시 확인
    final cached = await _local.getCached();
    if (cached != null) return cached;

    // 2. 백엔드 미연동 → 기본 데이터 반환
    // TODO: Remote 연동 시 아래를 교체
    // try {
    //   final remote = await _remote.getRecommended();
    //   await _local.cache(remote);
    //   return remote;
    // } catch (_) {}

    // 3. 폴백: 기본 데이터
    await _local.cache(defaultMountains);
    return defaultMountains;
  }
}
