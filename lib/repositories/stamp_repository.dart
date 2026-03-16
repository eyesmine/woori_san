import 'package:flutter/foundation.dart';
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
    // 서버 동기화
    if (_remote != null) {
      try {
        for (final stamp in stamps) {
          await _remote.updateStamp(stamp);
        }
      } catch (e) {
        debugPrint('StampRepository.saveAll sync error: $e');
      }
    }
  }
}
