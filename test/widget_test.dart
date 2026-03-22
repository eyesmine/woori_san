import 'package:flutter_test/flutter_test.dart';
import 'package:woori_san/models/mountain.dart';
import 'package:woori_san/models/stamp.dart';
import 'package:woori_san/models/hiking_plan.dart';
import 'package:woori_san/models/hiking_record.dart';
import 'package:woori_san/models/user.dart';
import 'package:woori_san/models/weather.dart';

void main() {
  group('Model serialization', () {
    test('Mountain toJson/fromJson', () {
      final mountain = defaultMountains.first;
      final json = mountain.toJson();
      final restored = Mountain.fromJson(json);
      expect(restored.name, mountain.name);
      expect(restored.height, mountain.height);
      expect(restored.id, mountain.id);
      expect(restored.latitude, mountain.latitude);
      expect(restored.longitude, mountain.longitude);
    });

    test('User toJson/fromJson', () {
      final user = User(id: '1', email: 'test@test.com', nickname: '산타');
      final json = user.toJson();
      final restored = User.fromJson(json);
      expect(restored.email, 'test@test.com');
      expect(restored.nickname, '산타');
    });

    test('Weather toJson/fromJson', () {
      final weather = Weather(
        temperature: 12.5,
        condition: 'Clear',
        description: '맑음',
        windSpeed: 2.1,
        humidity: 45,
        iconCode: '01d',
        forecastDate: DateTime(2025, 3, 15),
      );
      final json = weather.toJson();
      final restored = Weather.fromJson(json);
      expect(restored.temperature, 12.5);
      expect(restored.emoji, '☀️');
      expect(restored.windLabel, '바람 약함');
    });

    test('Stamp toJson/fromJson', () {
      final stamp = defaultStamps.first;
      final json = stamp.toJson();
      final restored = Stamp.fromJson(json);
      expect(restored.name, stamp.name);
      expect(restored.isStamped, stamp.isStamped);
      expect(restored.isTogetherStamped, stamp.isTogetherStamped);
    });

    test('HikingPlan toJson/fromJson', () {
      final plan = HikingPlan(mountain: '북한산', date: '3월 15일', status: PlanStatus.confirmed, emoji: '⛰️');
      final json = plan.toJson();
      final restored = HikingPlan.fromJson(json);
      expect(restored.mountain, '북한산');
      expect(restored.status, PlanStatus.confirmed);
    });

    test('HikingRecord toJson/fromJson', () {
      final record = HikingRecord(mountain: '관악산', date: '2025.02.01', duration: '3시간', distanceKm: 6.5, emoji: '🌄');
      final json = record.toJson();
      final restored = HikingRecord.fromJson(json);
      expect(restored.mountain, '관악산');
      expect(restored.distanceKm, 6.5);
    });

    test('ChecklistItem toJson/fromJson', () {
      final item = ChecklistItem(text: '등산화', checked: true);
      final json = item.toJson();
      final restored = ChecklistItem.fromJson(json);
      expect(restored.text, '등산화');
      expect(restored.checked, true);
    });
  });

  group('Default data', () {
    test('defaultMountains has 100 items', () {
      expect(defaultMountains.length, 100);
    });

    test('defaultStamps has 100 items', () {
      expect(defaultStamps.length, 100);
    });

    test('defaultChecklist has 6 items', () {
      expect(defaultChecklist.length, 6);
    });
  });
}
