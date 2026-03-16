import 'package:flutter_test/flutter_test.dart';
import 'package:woori_san/models/mountain.dart';

void main() {
  group('Difficulty', () {
    test('fromLabel returns correct enum value', () {
      expect(Difficulty.fromLabel('초급'), Difficulty.beginner);
      expect(Difficulty.fromLabel('중급'), Difficulty.intermediate);
      expect(Difficulty.fromLabel('상급'), Difficulty.advanced);
    });

    test('fromLabel returns intermediate for unknown label', () {
      expect(Difficulty.fromLabel('전문가'), Difficulty.intermediate);
      expect(Difficulty.fromLabel(''), Difficulty.intermediate);
    });

    test('label returns Korean string', () {
      expect(Difficulty.beginner.label, '초급');
      expect(Difficulty.intermediate.label, '중급');
      expect(Difficulty.advanced.label, '상급');
    });
  });

  group('Mountain', () {
    test('distance getter formats distanceKm correctly', () {
      final mountain = defaultMountains.first;
      expect(mountain.distance, '${mountain.distanceKm}km');
    });

    test('fromJson handles legacy distance field', () {
      final legacyJson = {
        'id': 'mt_test',
        'name': '테스트산',
        'location': '서울',
        'difficulty': '초급',
        'time': '약 2시간',
        'distance': '5.5km',
        'height': 500,
        'emoji': '🏔️',
        'colors': [0xFF000000, 0xFFFFFFFF],
        'description': '테스트',
      };

      final mountain = Mountain.fromJson(legacyJson);
      expect(mountain.distanceKm, 5.5);
      expect(mountain.latitude, 0);
      expect(mountain.longitude, 0);
      expect(mountain.imageUrl, isNull);
    });

    test('fromJson handles new distanceKm field', () {
      final newJson = {
        'id': 'mt_test',
        'name': '테스트산',
        'location': '서울',
        'difficulty': '중급',
        'time': '약 3시간',
        'distanceKm': 7.8,
        'height': 600,
        'emoji': '⛰️',
        'colors': [0xFF000000, 0xFFFFFFFF],
        'description': '테스트',
        'latitude': 37.5,
        'longitude': 127.0,
        'imageUrl': 'https://example.com/img.jpg',
      };

      final mountain = Mountain.fromJson(newJson);
      expect(mountain.distanceKm, 7.8);
      expect(mountain.latitude, 37.5);
      expect(mountain.longitude, 127.0);
      expect(mountain.imageUrl, 'https://example.com/img.jpg');
      expect(mountain.difficulty, Difficulty.intermediate);
    });

    test('defaultMountains all have valid coordinates', () {
      for (final m in defaultMountains) {
        expect(m.latitude, greaterThan(0), reason: '${m.name} latitude');
        expect(m.longitude, greaterThan(0), reason: '${m.name} longitude');
      }
    });

    test('toJson/fromJson round trip preserves all fields', () {
      final original = defaultMountains[1]; // 북한산
      final restored = Mountain.fromJson(original.toJson());

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.distanceKm, original.distanceKm);
      expect(restored.difficulty, original.difficulty);
      expect(restored.latitude, original.latitude);
      expect(restored.longitude, original.longitude);
    });
  });
}
