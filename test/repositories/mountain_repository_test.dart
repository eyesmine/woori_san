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
  List<Mountain> remoteRecommended = [];

  FakeMountainRemote() : super(ApiClient());

  @override
  Future<List<Mountain>> getMountains({String? region, String? difficulty, int? minHeight, int? maxHeight}) async {
    if (shouldFail) throw Exception('Server error');
    return remoteMountains;
  }

  @override
  Future<List<Mountain>> getRecommended({double? lat, double? lng, double? radius}) async {
    if (shouldFail) throw Exception('Server error');
    return remoteRecommended;
  }

  @override
  Future<Mountain> getDetail(String id) async {
    throw UnimplementedError();
  }
}

void main() {
  group('MountainRepository.getAllMountains', () {
    test('returns cached data when available', () async {
      final local = FakeMountainLocal();
      local._cached = defaultMountains;
      final repo = MountainRepository(local);

      final result = await repo.getAllMountains();

      expect(result, defaultMountains);
    });

    test('fetches from remote when cache is empty', () async {
      final local = FakeMountainLocal();
      final remote = FakeMountainRemote();
      remote.remoteMountains = defaultMountains;
      final repo = MountainRepository(local, remote);

      final result = await repo.getAllMountains();

      expect(result, defaultMountains);
      expect(local._cached, isNotNull);
    });

    test('falls back to defaults when remote fails', () async {
      final local = FakeMountainLocal();
      final remote = FakeMountainRemote();
      remote.shouldFail = true;
      final repo = MountainRepository(local, remote);

      final result = await repo.getAllMountains();

      expect(result, defaultMountains);
    });

    test('falls back to defaults when no remote', () async {
      final local = FakeMountainLocal();
      final repo = MountainRepository(local);

      final result = await repo.getAllMountains();

      expect(result, defaultMountains);
    });
  });

  group('MountainRepository.getRecommended', () {
    test('returns remote recommended', () async {
      final local = FakeMountainLocal();
      final remote = FakeMountainRemote();
      remote.remoteRecommended = defaultMountains.take(5).toList();
      final repo = MountainRepository(local, remote);

      final result = await repo.getRecommended(lat: 37.5, lng: 127.0);

      expect(result.length, 5);
    });

    test('falls back to first 10 of all mountains when remote fails', () async {
      final local = FakeMountainLocal();
      final remote = FakeMountainRemote();
      remote.shouldFail = true;
      final repo = MountainRepository(local, remote);

      final result = await repo.getRecommended();

      expect(result.length, 10);
    });
  });
}
