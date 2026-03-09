import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:woori_san/models/mountain.dart';
import 'package:woori_san/models/stamp.dart';
import 'package:woori_san/models/hiking_plan.dart';
import 'package:woori_san/models/hiking_record.dart';

void main() {
  group('Model serialization', () {
    test('Mountain toJson/fromJson', () {
      final mountain = defaultMountains.first;
      final json = mountain.toJson();
      final restored = Mountain.fromJson(json);
      expect(restored.name, mountain.name);
      expect(restored.height, mountain.height);
      expect(restored.id, mountain.id);
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
      final record = HikingRecord(mountain: '관악산', date: '2025.02.01', duration: '3시간', distance: '6.5km', emoji: '🌄');
      final json = record.toJson();
      final restored = HikingRecord.fromJson(json);
      expect(restored.mountain, '관악산');
      expect(restored.distance, '6.5km');
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
    test('defaultMountains has 4 items', () {
      expect(defaultMountains.length, 4);
    });

    test('defaultStamps has 10 items', () {
      expect(defaultStamps.length, 10);
    });

    test('defaultChecklist has 6 items', () {
      expect(defaultChecklist.length, 6);
    });
  });
}
