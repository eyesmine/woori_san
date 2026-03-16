import 'package:flutter_test/flutter_test.dart';
import 'package:woori_san/models/hiking_record.dart';

void main() {
  group('HikingRecord', () {
    test('distance getter formats correctly', () {
      final record = HikingRecord(
        mountain: '북한산',
        date: '2025.03.01',
        duration: '3시간',
        distanceKm: 8.2,
        emoji: '⛰️',
      );
      expect(record.distance, '8.2km');
    });

    test('auto-generates id when not provided', () {
      final record = HikingRecord(
        mountain: '관악산',
        date: '2025.03.01',
        duration: '2시간',
        distanceKm: 5.0,
        emoji: '🌄',
      );
      expect(record.id, isNotEmpty);
    });

    test('uses provided id', () {
      final record = HikingRecord(
        id: 'custom_id',
        mountain: '수락산',
        date: '2025.03.01',
        duration: '2시간',
        distanceKm: 5.5,
        emoji: '🍃',
      );
      expect(record.id, 'custom_id');
    });

    test('fromJson handles legacy distance field', () {
      final legacyJson = {
        'id': 'r1',
        'mountain': '북한산',
        'date': '2025.01.15',
        'duration': '4시간',
        'distance': '8.2km',
        'emoji': '🌲',
      };

      final record = HikingRecord.fromJson(legacyJson);
      expect(record.distanceKm, 8.2);
      expect(record.distance, '8.2km');
    });

    test('fromJson handles new distanceKm field', () {
      final json = {
        'id': 'r2',
        'mountain': '관악산',
        'date': '2025.02.01',
        'duration': '3시간',
        'distanceKm': 6.5,
        'emoji': '⛅',
      };

      final record = HikingRecord.fromJson(json);
      expect(record.distanceKm, 6.5);
    });

    test('fromJson prefers distanceKm over distance', () {
      final json = {
        'id': 'r3',
        'mountain': '테스트',
        'date': '2025.01.01',
        'duration': '1시간',
        'distanceKm': 10.0,
        'distance': '5.0km',
        'emoji': '🏔️',
      };

      final record = HikingRecord.fromJson(json);
      expect(record.distanceKm, 10.0);
    });
  });
}
