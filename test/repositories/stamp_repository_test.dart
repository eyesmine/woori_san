import 'package:flutter_test/flutter_test.dart';
import 'package:woori_san/models/stamp.dart';
import 'package:woori_san/datasources/local/stamp_local.dart';
import 'package:woori_san/datasources/remote/stamp_remote.dart';
import 'package:woori_san/repositories/stamp_repository.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class FakeStampLocal implements StampLocalDataSource {
  List<Stamp> _stamps = [];

  @override
  List<Stamp> getAll() => _stamps;

  @override
  Future<void> saveAll(List<Stamp> stamps) async {
    _stamps = List.of(stamps);
  }
}

class FakeStampRemote implements StampRemoteDataSource {
  List<Stamp> stampsToReturn = [];
  Map<String, dynamic> progressToReturn = {};
  bool shouldFail = false;
  Map<String, dynamic>? lastCreateData;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<List<Stamp>> getStamps() async {
    if (shouldFail) throw Exception('network error');
    return stampsToReturn;
  }

  @override
  Future<void> createStamp(Map<String, dynamic> data) async {
    if (shouldFail) throw Exception('create failed');
    lastCreateData = data;
  }

  @override
  Future<List<Stamp>> getTogetherStamps() async {
    if (shouldFail) throw Exception('network error');
    return stampsToReturn;
  }

  @override
  Future<Map<String, dynamic>> getProgress() async {
    if (shouldFail) throw Exception('network error');
    return progressToReturn;
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Stamp _stamp({
  String name = 'TestMt',
  String region = 'Seoul',
  int height = 500,
  bool isStamped = false,
  String? stampDate,
}) {
  return Stamp(
    name: name,
    region: region,
    height: height,
    isStamped: isStamped,
    stampDate: stampDate,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late FakeStampLocal fakeLocal;
  late FakeStampRemote fakeRemote;
  late StampRepository repo;

  setUp(() {
    fakeLocal = FakeStampLocal();
    fakeRemote = FakeStampRemote();
    repo = StampRepository(fakeLocal, fakeRemote);
  });

  group('StampRepository', () {
    test('getAll returns stamps from local data source', () {
      final stamps = [
        _stamp(name: 'A', isStamped: true),
        _stamp(name: 'B'),
      ];
      fakeLocal._stamps = stamps;

      final result = repo.getAll();

      expect(result, equals(stamps));
      expect(result.length, 2);
      expect(result.first.name, 'A');
    });

    test('getAll returns empty list when local has no stamps', () {
      final result = repo.getAll();
      expect(result, isEmpty);
    });

    test('saveAll persists stamps to local data source', () async {
      final stamps = [
        _stamp(name: 'X', isStamped: true, stampDate: '2025.06.01'),
        _stamp(name: 'Y', height: 1200),
      ];

      await repo.saveAll(stamps);

      expect(fakeLocal.getAll(), equals(stamps));
      expect(fakeLocal.getAll().length, 2);
    });

    test('syncFromRemote fetches from remote and saves locally', () async {
      final remoteStamps = [
        _stamp(name: 'Remote1', isStamped: true, stampDate: '2025.05.10'),
        _stamp(name: 'Remote2', region: 'Gangwon', height: 1500),
      ];
      fakeRemote.stampsToReturn = remoteStamps;

      final result = await repo.syncFromRemote();

      expect(result, equals(remoteStamps));
      // Verify they were also saved locally
      expect(fakeLocal.getAll(), equals(remoteStamps));
    });

    test('syncFromRemote failure returns local data', () async {
      final localStamps = [
        _stamp(name: 'LocalOnly', isStamped: true),
      ];
      fakeLocal._stamps = localStamps;
      fakeRemote.shouldFail = true;

      final result = await repo.syncFromRemote();

      expect(result, equals(localStamps));
      expect(result.first.name, 'LocalOnly');
    });

    test('syncFromRemote without remote returns local data', () async {
      final localStamps = [_stamp(name: 'Offline')];
      fakeLocal._stamps = localStamps;

      final repoNoRemote = StampRepository(fakeLocal);
      final result = await repoNoRemote.syncFromRemote();

      expect(result, equals(localStamps));
    });

    test('createStamp calls remote with provided data', () async {
      final data = {'mountain_name': 'TestMt', 'lat': 37.5, 'lng': 127.0};

      await repo.createStamp(data);

      expect(fakeRemote.lastCreateData, equals(data));
    });

    test('createStamp rethrows on remote failure', () async {
      fakeRemote.shouldFail = true;

      expect(
        () => repo.createStamp({'mountain_name': 'Fail'}),
        throwsException,
      );
    });

    test('createStamp does nothing when remote is null', () async {
      final repoNoRemote = StampRepository(fakeLocal);

      // Should not throw
      await repoNoRemote.createStamp({'mountain_name': 'Offline'});
    });

    test('getProgress returns empty map when remote is null', () async {
      final repoNoRemote = StampRepository(fakeLocal);
      final result = await repoNoRemote.getProgress();
      expect(result, isEmpty);
    });

    test('getProgress returns data from remote', () async {
      fakeRemote.progressToReturn = {'total': 100, 'stamped': 5};

      final result = await repo.getProgress();

      expect(result['total'], 100);
      expect(result['stamped'], 5);
    });
  });
}
