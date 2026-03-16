import 'package:flutter_test/flutter_test.dart';
import 'package:woori_san/core/api_client.dart';
import 'package:woori_san/models/mountain.dart';
import 'package:woori_san/datasources/local/mountain_local.dart';
import 'package:woori_san/datasources/remote/mountain_remote.dart';
import 'package:woori_san/repositories/mountain_repository.dart';

class FakeMountainLocal implements MountainLocalDataSource {
  List<Mountain>? _cached;

  @override
  Future<List<Mountain>?> getCached() async => _cached;

  @override
  Future<void> cache(List<Mountain> mountains) async {
    _cached = mountains;
  }

  @override
  Future<void> clearCache() async {
    _cached = null;
  }
}

class FakeMountainRemote extends MountainRemoteDataSource {
  bool shouldFail = false;
  List<Mountain> remoteMountains = [];

  FakeMountainRemote() : super(ApiClient());

  @override
  Future<List<Mountain>> getRecommended() async {
    if (shouldFail) throw Exception('Server error');
    return remoteMountains;
  }

  @override
  Future<Mountain> getDetail(String id) async {
    throw UnimplementedError();
  }
}

void main() {
  group('MountainRepository', () {
    test('returns cached data when available', () async {
      final local = FakeMountainLocal();
      local._cached = defaultMountains;
      final repo = MountainRepository(local);

      final result = await repo.getRecommended();

      expect(result, defaultMountains);
    });

    test('fetches from remote when cache is empty', () async {
      final local = FakeMountainLocal();
      final remote = FakeMountainRemote();
      remote.remoteMountains = defaultMountains;
      final repo = MountainRepository(local, remote);

      final result = await repo.getRecommended();

      expect(result, defaultMountains);
      expect(local._cached, isNotNull); // should be cached
    });

    test('falls back to defaults when remote fails', () async {
      final local = FakeMountainLocal();
      final remote = FakeMountainRemote();
      remote.shouldFail = true;
      final repo = MountainRepository(local, remote);

      final result = await repo.getRecommended();

      expect(result, defaultMountains);
      expect(local._cached, defaultMountains);
    });

    test('falls back to defaults when no remote is provided', () async {
      final local = FakeMountainLocal();
      final repo = MountainRepository(local);

      final result = await repo.getRecommended();

      expect(result, defaultMountains);
    });
  });
}
