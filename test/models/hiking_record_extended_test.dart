import 'package:flutter_test/flutter_test.dart';
import 'package:woori_san/models/hiking_record.dart';

void main() {
  group('HikingRecord extended fields', () {
    test('creates record with all new fields', () {
      final start = DateTime(2025, 3, 1, 9, 0);
      final end = DateTime(2025, 3, 1, 13, 0);
      final routePoints = [
        {'lat': 37.6584, 'lng': 126.9780},
        {'lat': 37.6590, 'lng': 126.9785},
      ];

      final record = HikingRecord(
        id: 'ext_1',
        mountain: '북한산',
        date: '3월 1일',
        duration: '4h 0m 0s',
        distanceKm: 9.2,
        emoji: '⛰️',
        mountainId: 'mt_2',
        routePoints: routePoints,
        photoUrls: ['https://example.com/photo1.jpg', 'https://example.com/photo2.jpg'],
        elevationGain: 450,
        startTime: start,
        endTime: end,
      );

      expect(record.mountainId, 'mt_2');
      expect(record.routePoints, hasLength(2));
      expect(record.routePoints![0]['lat'], 37.6584);
      expect(record.photoUrls, hasLength(2));
      expect(record.elevationGain, 450);
      expect(record.startTime, start);
      expect(record.endTime, end);
    });

    test('toJson includes new fields when present', () {
      final start = DateTime(2025, 6, 15, 8, 30);
      final end = DateTime(2025, 6, 15, 12, 45);

      final record = HikingRecord(
        id: 'json_1',
        mountain: '관악산',
        date: '6월 15일',
        duration: '4h 15m',
        distanceKm: 7.8,
        emoji: '🌄',
        mountainId: 'mt_3',
        routePoints: [
          {'lat': 37.4331, 'lng': 126.9637},
        ],
        photoUrls: ['photo1.jpg'],
        elevationGain: 320,
        startTime: start,
        endTime: end,
      );

      final json = record.toJson();

      expect(json['mountainId'], 'mt_3');
      expect(json['routePoints'], hasLength(1));
      expect(json['photoUrls'], ['photo1.jpg']);
      expect(json['elevationGain'], 320);
      expect(json['startTime'], start.toIso8601String());
      expect(json['endTime'], end.toIso8601String());
    });

    test('toJson omits new fields when null', () {
      final record = HikingRecord(
        id: 'json_2',
        mountain: '수락산',
        date: '7월 1일',
        duration: '2h',
        distanceKm: 5.5,
        emoji: '🍃',
      );

      final json = record.toJson();

      expect(json.containsKey('mountainId'), false);
      expect(json.containsKey('routePoints'), false);
      expect(json.containsKey('photoUrls'), false);
      expect(json.containsKey('elevationGain'), false);
      expect(json.containsKey('startTime'), false);
      expect(json.containsKey('endTime'), false);
    });

    test('toJson/fromJson round trip with all new fields', () {
      final start = DateTime(2025, 3, 1, 9, 0);
      final end = DateTime(2025, 3, 1, 13, 0);

      final original = HikingRecord(
        id: 'round_1',
        mountain: '북한산',
        date: '3월 1일',
        duration: '4h 0m 0s',
        distanceKm: 9.2,
        emoji: '⛰️',
        mountainId: 'mt_2',
        routePoints: [
          {'lat': 37.6584, 'lng': 126.9780},
          {'lat': 37.6590, 'lng': 126.9785},
        ],
        photoUrls: ['photo1.jpg', 'photo2.jpg'],
        elevationGain: 450,
        startTime: start,
        endTime: end,
      );

      final json = original.toJson();
      final restored = HikingRecord.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.mountain, original.mountain);
      expect(restored.date, original.date);
      expect(restored.duration, original.duration);
      expect(restored.distanceKm, original.distanceKm);
      expect(restored.emoji, original.emoji);
      expect(restored.mountainId, original.mountainId);
      expect(restored.routePoints, hasLength(2));
      expect(restored.routePoints![0]['lat'], 37.6584);
      expect(restored.routePoints![0]['lng'], 126.9780);
      expect(restored.routePoints![1]['lat'], 37.6590);
      expect(restored.routePoints![1]['lng'], 126.9785);
      expect(restored.photoUrls, original.photoUrls);
      expect(restored.elevationGain, original.elevationGain);
      expect(restored.startTime, original.startTime);
      expect(restored.endTime, original.endTime);
    });

    test('copyWith preserves original values when no arguments given', () {
      final start = DateTime(2025, 3, 1, 9, 0);
      final end = DateTime(2025, 3, 1, 13, 0);

      final original = HikingRecord(
        id: 'copy_1',
        mountain: '북한산',
        date: '3월 1일',
        duration: '4h',
        distanceKm: 9.2,
        emoji: '⛰️',
        mountainId: 'mt_2',
        routePoints: [
          {'lat': 37.6584, 'lng': 126.9780},
        ],
        photoUrls: ['photo.jpg'],
        elevationGain: 450,
        startTime: start,
        endTime: end,
      );

      final copy = original.copyWith();

      expect(copy.id, original.id);
      expect(copy.mountain, original.mountain);
      expect(copy.date, original.date);
      expect(copy.duration, original.duration);
      expect(copy.distanceKm, original.distanceKm);
      expect(copy.emoji, original.emoji);
      expect(copy.mountainId, original.mountainId);
      expect(copy.routePoints, original.routePoints);
      expect(copy.photoUrls, original.photoUrls);
      expect(copy.elevationGain, original.elevationGain);
      expect(copy.startTime, original.startTime);
      expect(copy.endTime, original.endTime);
    });

    test('copyWith overrides specified fields', () {
      final original = HikingRecord(
        id: 'copy_2',
        mountain: '북한산',
        date: '3월 1일',
        duration: '4h',
        distanceKm: 9.2,
        emoji: '⛰️',
        mountainId: 'mt_2',
        elevationGain: 450,
      );

      final modified = original.copyWith(
        mountain: '관악산',
        distanceKm: 7.8,
        mountainId: 'mt_3',
        elevationGain: 320,
        photoUrls: ['new_photo.jpg'],
      );

      expect(modified.mountain, '관악산');
      expect(modified.distanceKm, 7.8);
      expect(modified.mountainId, 'mt_3');
      expect(modified.elevationGain, 320);
      expect(modified.photoUrls, ['new_photo.jpg']);
      // Unchanged fields
      expect(modified.id, original.id);
      expect(modified.date, original.date);
      expect(modified.duration, original.duration);
      expect(modified.emoji, original.emoji);
    });

    test('backward compatibility: fromJson without new fields', () {
      final legacyJson = {
        'id': 'legacy_1',
        'mountain': '청계산',
        'date': '2025.01.15',
        'duration': '3시간',
        'distanceKm': 6.5,
        'emoji': '🌲',
      };

      final record = HikingRecord.fromJson(legacyJson);

      expect(record.id, 'legacy_1');
      expect(record.mountain, '청계산');
      expect(record.distanceKm, 6.5);
      expect(record.mountainId, isNull);
      expect(record.routePoints, isNull);
      expect(record.photoUrls, isNull);
      expect(record.elevationGain, isNull);
      expect(record.startTime, isNull);
      expect(record.endTime, isNull);
    });

    test('routePoints parsing from JSON with numeric values', () {
      final json = {
        'id': 'route_1',
        'mountain': '북한산',
        'date': '3월 1일',
        'duration': '4h',
        'distanceKm': 9.2,
        'emoji': '⛰️',
        'routePoints': [
          {'lat': 37.6584, 'lng': 126.9780},
          {'lat': 37.6590, 'lng': 126.9785},
          {'lat': 37.6595, 'lng': 126.9790},
        ],
      };

      final record = HikingRecord.fromJson(json);

      expect(record.routePoints, isNotNull);
      expect(record.routePoints, hasLength(3));
      expect(record.routePoints![0], isA<Map<String, double>>());
      expect(record.routePoints![0]['lat'], 37.6584);
      expect(record.routePoints![0]['lng'], 126.9780);
      expect(record.routePoints![2]['lat'], 37.6595);
      expect(record.routePoints![2]['lng'], 126.9790);
    });

    test('routePoints parsing handles integer values in JSON', () {
      final json = {
        'id': 'route_2',
        'mountain': '청계산',
        'date': '4월 1일',
        'duration': '3h',
        'distanceKm': 6.5,
        'emoji': '🌲',
        'routePoints': [
          {'lat': 37, 'lng': 127},
        ],
      };

      final record = HikingRecord.fromJson(json);

      expect(record.routePoints, hasLength(1));
      expect(record.routePoints![0]['lat'], 37.0);
      expect(record.routePoints![0]['lng'], 127.0);
    });
  });
}
