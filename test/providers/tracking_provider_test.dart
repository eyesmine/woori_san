import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:woori_san/models/mountain.dart';
import 'package:woori_san/providers/tracking_provider.dart';
import 'package:woori_san/services/location_service.dart';

class FakeLocationService implements LocationService {
  bool permissionGranted = true;

  @override
  Future<bool> requestPermission() async => permissionGranted;

  @override
  Future<Position> getCurrentPosition() async {
    throw UnimplementedError();
  }

  @override
  Stream<Position> getPositionStream() {
    return const Stream.empty();
  }

  @override
  double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    return 0;
  }

  @override
  bool isNearSummit(Position position, Mountain mountain, {double? threshold}) {
    return false;
  }
}

void main() {
  late TrackingProvider provider;
  late FakeLocationService fakeLocation;

  setUpAll(() async {
    await initializeDateFormatting('ko_KR');
  });

  setUp(() {
    fakeLocation = FakeLocationService();
    provider = TrackingProvider(fakeLocation);
  });

  group('TrackingProvider', () {
    test('initial state is not active, no route points, zero distance', () {
      expect(provider.isActive, false);
      expect(provider.isPaused, false);
      expect(provider.routePoints, isEmpty);
      expect(provider.totalDistanceMeters, 0);
      expect(provider.totalDistanceKm, 0);
      expect(provider.summitReached, false);
      expect(provider.currentMountain, isNull);
    });

    group('elapsedFormatted', () {
      test('shows minutes and seconds for durations under 1 hour', () {
        // Provider starts with Duration.zero, so elapsed should be 0m 0s
        expect(provider.elapsedFormatted, '0m 0s');
      });
    });

    group('speedKmh', () {
      test('returns 0.0 when elapsed is zero', () {
        expect(provider.speedKmh, '0.0');
      });
    });

    test('stop creates HikingRecord with correct data', () {
      // Even without starting, stop() should produce a record
      final record = provider.stop();

      expect(record.mountain, '자유 등산');
      expect(record.mountainId, isNull);
      expect(record.distanceKm, 0.0);
      expect(record.routePoints, isEmpty);
      expect(record.startTime, isNotNull);
      expect(record.endTime, isNotNull);
      expect(record.emoji, '🏔️');
      expect(provider.isActive, false);
    });

    test('pause sets isPaused to true', () {
      provider.pause();
      expect(provider.isPaused, true);
    });

    test('resume sets isPaused to false', () {
      provider.pause();
      expect(provider.isPaused, true);

      provider.resume();
      expect(provider.isPaused, false);
    });

    test('pause and resume toggle isPaused', () {
      expect(provider.isPaused, false);

      provider.pause();
      expect(provider.isPaused, true);

      provider.resume();
      expect(provider.isPaused, false);

      provider.pause();
      expect(provider.isPaused, true);
    });

    test('reset clears all state', () {
      // Mutate state via pause
      provider.pause();
      expect(provider.isPaused, true);

      provider.reset();

      expect(provider.isActive, false);
      expect(provider.isPaused, false);
      expect(provider.routePoints, isEmpty);
      expect(provider.totalDistanceMeters, 0);
      expect(provider.totalDistanceKm, 0);
      expect(provider.summitReached, false);
      expect(provider.currentMountain, isNull);
    });

    test('stop returns record with duration format from elapsedFormatted', () {
      final record = provider.stop();
      // Elapsed is zero, so duration should be the formatted form of Duration.zero
      expect(record.duration, '0m 0s');
    });
  });
}
