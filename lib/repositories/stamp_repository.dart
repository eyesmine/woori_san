import '../core/logger.dart';
import '../models/stamp.dart';
import '../datasources/local/stamp_local.dart';
import '../datasources/remote/stamp_remote.dart';

class StampRepository {
  final StampLocalDataSource _local;
  final StampRemoteDataSource? _remote;

  StampRepository(this._local, [this._remote]);

  List<Stamp> getAll() => _local.getAll();

  Future<void> saveAll(List<Stamp> stamps) async {
    await _local.saveAll(stamps);
  }

  /// POST /api/stamps/ — 도장 찍기
  Future<void> createStamp(Map<String, dynamic> data) async {
    if (_remote != null) {
      try {
        await _remote.createStamp(data);
      } catch (e) {
        AppLogger.error('도장 생성 실패', tag: 'StampRepo', error: e);
        rethrow;
      }
    }
  }

  /// 서버에서 내 도장 목록 동기화
  Future<List<Stamp>> syncFromRemote() async {
    if (_remote == null) return getAll();
    try {
      final remote = await _remote.getStamps();
      await _local.saveAll(remote);
      return remote;
    } catch (e) {
      AppLogger.warning('도장 동기화 실패, 로컬 데이터 사용', tag: 'StampRepo', error: e);
      return getAll();
    }
  }

  /// GET /api/stamps/progress/
  Future<Map<String, dynamic>> getProgress() async {
    if (_remote == null) return {};
    return await _remote.getProgress();
  }
}
