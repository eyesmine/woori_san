import 'package:flutter_test/flutter_test.dart';
import 'package:woori_san/models/stamp.dart';
import 'package:woori_san/repositories/stamp_repository.dart';
import 'package:woori_san/datasources/local/stamp_local.dart';
import 'package:woori_san/providers/stamp_provider.dart';

/// In-memory StampLocalDataSource for testing
class FakeStampLocalDataSource implements StampLocalDataSource {
  List<Stamp> _stamps;

  FakeStampLocalDataSource([List<Stamp>? initial])
      : _stamps = initial ??
            [
              Stamp(name: '북한산', region: '서울', height: 836, isStamped: true, isTogetherStamped: true, stampDate: '2025.01.20'),
              Stamp(name: '관악산', region: '서울', height: 629),
              Stamp(name: '청계산', region: '경기', height: 618),
            ];

  @override
  List<Stamp> getAll() => _stamps;

  @override
  Future<void> saveAll(List<Stamp> stamps) async {
    _stamps = stamps;
  }
}

void main() {
  late StampProvider provider;
  late FakeStampLocalDataSource fakeLocal;

  setUp(() {
    fakeLocal = FakeStampLocalDataSource();
    final repo = StampRepository(fakeLocal);
    provider = StampProvider(repo);
  });

  group('StampProvider', () {
    test('initializes with stamps from repository', () {
      expect(provider.stamps.length, 3);
      expect(provider.totalStamped, 1);
      expect(provider.togetherStamped, 1);
    });

    test('toggleStamp stamps an unstamped mountain', () {
      expect(provider.stamps[1].isStamped, false);

      provider.toggleStamp(1);

      expect(provider.stamps[1].isStamped, true);
      expect(provider.stamps[1].stampDate, isNotNull);
      expect(provider.totalStamped, 2);
    });

    test('toggleStamp with together flag sets isTogetherStamped', () {
      provider.toggleStamp(2, together: true);

      expect(provider.stamps[2].isStamped, true);
      expect(provider.stamps[2].isTogetherStamped, true);
    });

    test('toggleStamp unstamps a stamped mountain', () {
      expect(provider.stamps[0].isStamped, true);

      provider.toggleStamp(0);

      expect(provider.stamps[0].isStamped, false);
      expect(provider.stamps[0].isTogetherStamped, false);
      expect(provider.stamps[0].stampDate, isNull);
      expect(provider.totalStamped, 0);
    });

    test('toggleTogetherStamp toggles together status on stamped mountain', () {
      expect(provider.stamps[0].isTogetherStamped, true);

      provider.toggleTogetherStamp(0);

      expect(provider.stamps[0].isTogetherStamped, false);
      expect(provider.stamps[0].isStamped, true); // still stamped

      provider.toggleTogetherStamp(0);

      expect(provider.stamps[0].isTogetherStamped, true);
    });

    test('toggleTogetherStamp does nothing on unstamped mountain', () {
      expect(provider.stamps[1].isStamped, false);

      provider.toggleTogetherStamp(1);

      expect(provider.stamps[1].isTogetherStamped, false);
    });

    test('togetherStamps returns only together-stamped mountains', () {
      expect(provider.togetherStamps.length, 1);
      expect(provider.togetherStamps.first.name, '북한산');
    });

    test('changes are persisted to repository', () {
      provider.toggleStamp(1);

      // Re-read from fake local to verify persistence
      final persisted = fakeLocal.getAll();
      expect(persisted[1].isStamped, true);
    });

    test('toggleStamp with negative index does nothing', () {
      final initialStamped = provider.totalStamped;
      provider.toggleStamp(-1);
      expect(provider.totalStamped, initialStamped);
    });

    test('toggleStamp with out-of-bounds index does nothing', () {
      final initialStamped = provider.totalStamped;
      provider.toggleStamp(999);
      expect(provider.totalStamped, initialStamped);
    });
  });
}
