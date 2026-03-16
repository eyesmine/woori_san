import 'package:flutter/foundation.dart';
import '../models/mountain.dart';
import '../datasources/local/mountain_local.dart';
import '../datasources/remote/mountain_remote.dart';

class MountainRepository {
  final MountainLocalDataSource _local;
  final MountainRemoteDataSource? _remote;

  MountainRepository(this._local, [this._remote]);

  Future<List<Mountain>> getRecommended() async {
    final cached = await _local.getCached();
    if (cached != null) return cached;

    if (_remote != null) {
      try {
        final remote = await _remote.getRecommended();
        await _local.cache(remote);
        return remote;
      } catch (e) {
        debugPrint('MountainRepository.getRecommended remote error: $e');
      }
    }

    await _local.cache(defaultMountains);
    return defaultMountains;
  }
}
