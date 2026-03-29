import 'dart:async';
import 'package:flutter/material.dart';
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

/// LocationService variant that denies permission.
class DeniedPermissionLocationService extends FakeLocationService {
  @override
  Future<bool> requestPermission() async => false;
}

/// LocationService variant that emits errors on the position stream.
class ErrorLocationService extends FakeLocationService {
  @override
  Stream<Position> getPositionStream() {
    return Stream.error('GPS error');
  }
}

/// LocationService variant that emits positions from a StreamController.
class ControllableLocationService extends FakeLocationService {
  final StreamController<Position> controller = StreamController<Position>.broadcast();

  @override
  Stream<Position> getPositionStream() => controller.stream;

  void emitPosition(Position position) {
    controller.add(position);
  }

  void emitError(dynamic error) {
    controller.addError(error);
  }

  void dispose() {
    controller.close();
  }
}

Mountain _makeMountain({
  String id = 'm1',
  String name = '북한산',
  String emoji = '⛰️',
}) {
  return Mountain(
    id: id,
    name: name,
    location: '서울',
    difficulty: Difficulty.intermediate,
    time: '3시간',
    distanceKm: 8.5,
    height: 836,
    emoji: emoji,
    colors: [Colors.green, Colors.blue],
    description: '서울의 명산',
    latitude: 37.6586,
    longitude: 126.9780,
  );
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ko_KR');
  });

  group('TrackingProvider extended', () {
    group('start() with permission denied', () {
      test('sets error when permission is denied', () async {
        final locationService = DeniedPermissionLocationService();
        final provider = TrackingProvider(locationService);

        await provider.start(null);

        expect(provider.error, '위치 권한이 필요합니다');
        expect(provider.isActive, false);
        expect(provider.isLoading, false);
      });

      test('does not set isActive when permission is denied', () async {
        final locationService = DeniedPermissionLocationService();
        final provider = TrackingProvider(locationService);

        await provider.start(_makeMountain());

        expect(provider.isActive, false);
        expect(provider.currentMountain, isNull);
      });
    });

    group('start() with a Mountain', () {
      test('sets currentMountain when started with a mountain', () async {
        final locationService = FakeLocationService();
        final provider = TrackingProvider(locationService);
        final mountain = _makeMountain(name: '관악산');

        await provider.start(mountain);

        expect(provider.currentMountain, isNotNull);
        expect(provider.currentMountain!.name, '관악산');
        expect(provider.isActive, true);

        provider.reset();
      });

      test('sets currentMountain to null when started without mountain', () async {
        final locationService = FakeLocationService();
        final provider = TrackingProvider(locationService);

        await provider.start(null);

        expect(provider.currentMountain, isNull);
        expect(provider.isActive, true);

        provider.reset();
      });
    });

    group('onError handler', () {
      test('sets error message when position stream emits error', () async {
        final locationService = ErrorLocationService();
        final provider = TrackingProvider(locationService);

        await provider.start(null);

        // Give the stream error time to propagate
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(provider.error, 'GPS 신호를 수신할 수 없습니다');

        provider.reset();
      });

      test('error from stream does not stop tracking', () async {
        final locationService = ErrorLocationService();
        final provider = TrackingProvider(locationService);

        await provider.start(null);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(provider.error, isNotNull);
        // isActive stays true - the stream errored but tracking was not stopped
        expect(provider.isActive, true);

        provider.reset();
      });
    });

    group('reset()', () {
      test('clears all state including timer and positionStream', () async {
        final locationService = FakeLocationService();
        final provider = TrackingProvider(locationService);
        final mountain = _makeMountain();

        await provider.start(mountain);
        expect(provider.isActive, true);
        expect(provider.currentMountain, isNotNull);

        provider.reset();

        expect(provider.isActive, false);
        expect(provider.isPaused, false);
        expect(provider.isLoading, false);
        expect(provider.routePoints, isEmpty);
        expect(provider.totalDistanceMeters, 0);
        expect(provider.totalDistanceKm, 0);
        expect(provider.summitReached, false);
        expect(provider.summitDialogShown, false);
        expect(provider.currentMountain, isNull);
        expect(provider.error, isNull);
      });

      test('reset after pause clears isPaused', () async {
        final locationService = FakeLocationService();
        final provider = TrackingProvider(locationService);

        await provider.start(null);
        provider.pause();
        expect(provider.isPaused, true);

        provider.reset();
        expect(provider.isPaused, false);
      });

      test('can start again after reset', () async {
        final locationService = FakeLocationService();
        final provider = TrackingProvider(locationService);

        await provider.start(null);
        expect(provider.isActive, true);

        provider.reset();
        expect(provider.isActive, false);

        await provider.start(_makeMountain());
        expect(provider.isActive, true);
        expect(provider.currentMountain!.name, '북한산');

        provider.reset();
      });
    });

    group('stop() with a mountain', () {
      test('record has mountain name when started with a mountain', () async {
        final locationService = FakeLocationService();
        final provider = TrackingProvider(locationService);
        final mountain = _makeMountain(name: '설악산', emoji: '🏔️');

        await provider.start(mountain);
        final record = provider.stop();

        expect(record.mountain, '설악산');
        expect(record.emoji, '🏔️');
        expect(record.mountainId, mountain.id);
      });

      test('record has default name when started without mountain', () async {
        final locationService = FakeLocationService();
        final provider = TrackingProvider(locationService);

        await provider.start(null);
        final record = provider.stop();

        expect(record.mountain, '자유 등산');
        expect(record.mountainId, isNull);
        expect(record.emoji, '🏔️');
      });
    });

    group('summitDialogShown state management', () {
      test('summitDialogShown is false initially', () {
        final locationService = FakeLocationService();
        final provider = TrackingProvider(locationService);

        expect(provider.summitDialogShown, false);
      });

      test('markSummitDialogShown sets summitDialogShown to true', () {
        final locationService = FakeLocationService();
        final provider = TrackingProvider(locationService);

        provider.markSummitDialogShown();
        expect(provider.summitDialogShown, true);
      });

      test('summitDialogShown resets to false on start', () async {
        final locationService = FakeLocationService();
        final provider = TrackingProvider(locationService);

        provider.markSummitDialogShown();
        expect(provider.summitDialogShown, true);

        await provider.start(null);
        expect(provider.summitDialogShown, false);

        provider.reset();
      });

      test('summitDialogShown resets to false on reset', () {
        final locationService = FakeLocationService();
        final provider = TrackingProvider(locationService);

        provider.markSummitDialogShown();
        expect(provider.summitDialogShown, true);

        provider.reset();
        expect(provider.summitDialogShown, false);
      });
    });

    group('start() idempotency', () {
      test('calling start twice does not restart if already active', () async {
        final locationService = FakeLocationService();
        final provider = TrackingProvider(locationService);
        final mountain1 = _makeMountain(name: '북한산');
        final mountain2 = _makeMountain(name: '관악산');

        await provider.start(mountain1);
        expect(provider.currentMountain!.name, '북한산');

        await provider.start(mountain2);
        // Should still be the first mountain since start() returns early if active
        expect(provider.currentMountain!.name, '북한산');

        provider.reset();
      });
    });
  });
}
