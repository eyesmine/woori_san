import 'package:flutter_test/flutter_test.dart';
import 'package:woori_san/core/badge_evaluator.dart';
import 'package:woori_san/models/badge.dart';
import 'package:woori_san/models/hiking_record.dart';
import 'package:woori_san/models/stamp.dart';

HikingRecord _record({
  String mountain = '북한산',
  double distanceKm = 5.0,
  int? elevationGain,
  DateTime? startTime,
  DateTime? endTime,
  String duration = '2h 30m',
}) {
  return HikingRecord(
    mountain: mountain,
    date: '3월 15일',
    duration: duration,
    distanceKm: distanceKm,
    emoji: '🏔️',
    elevationGain: elevationGain,
    startTime: startTime,
    endTime: endTime,
  );
}

Stamp _stamp({
  String name = '북한산',
  String region = '서울',
  int height = 836,
  bool isStamped = false,
  bool isTogether = false,
  String? stampDate,
}) {
  final s = Stamp(name: name, region: region, height: height);
  s.isStamped = isStamped;
  s.isTogetherStamped = isTogether;
  s.stampDate = stampDate;
  return s;
}

void main() {
  group('BadgeEvaluator - basic counts', () {
    test('totalHikes', () {
      final eval = BadgeEvaluator(
        records: [_record(), _record(), _record()],
        stamps: [],
      );
      expect(eval.totalHikes, 3);
    });

    test('totalDistanceKm', () {
      final eval = BadgeEvaluator(
        records: [_record(distanceKm: 3.5), _record(distanceKm: 6.5)],
        stamps: [],
      );
      expect(eval.totalDistanceKm, 10.0);
    });

    test('totalElevation', () {
      final eval = BadgeEvaluator(
        records: [
          _record(elevationGain: 300),
          _record(elevationGain: 200),
        ],
        stamps: [],
      );
      expect(eval.totalElevation, 500);
    });

    test('maxSingleElevation', () {
      final eval = BadgeEvaluator(
        records: [
          _record(elevationGain: 300),
          _record(elevationGain: 800),
          _record(elevationGain: 500),
        ],
        stamps: [],
      );
      expect(eval.maxSingleElevation, 800);
    });
  });

  group('BadgeEvaluator - badge checks', () {
    test('firstHike earned with 1 record', () {
      final eval = BadgeEvaluator(records: [_record()], stamps: []);
      expect(eval.check(BadgeType.firstHike), isTrue);
    });

    test('firstHike not earned with 0 records', () {
      final eval = BadgeEvaluator(records: [], stamps: []);
      expect(eval.check(BadgeType.firstHike), isFalse);
    });

    test('hikes5 earned with 5 records', () {
      final records = List.generate(5, (_) => _record());
      final eval = BadgeEvaluator(records: records, stamps: []);
      expect(eval.check(BadgeType.hikes5), isTrue);
    });

    test('distance10km earned', () {
      final eval = BadgeEvaluator(
        records: [_record(distanceKm: 5), _record(distanceKm: 6)],
        stamps: [],
      );
      expect(eval.check(BadgeType.distance10km), isTrue);
    });

    test('distance10km not earned', () {
      final eval = BadgeEvaluator(
        records: [_record(distanceKm: 3), _record(distanceKm: 4)],
        stamps: [],
      );
      expect(eval.check(BadgeType.distance10km), isFalse);
    });
  });

  group('BadgeEvaluator - stamp helpers', () {
    test('totalStamped counts only stamped', () {
      final eval = BadgeEvaluator(
        records: [],
        stamps: [
          _stamp(isStamped: true),
          _stamp(name: '설악산', isStamped: true),
          _stamp(name: '지리산', isStamped: false),
        ],
      );
      expect(eval.totalStamped, 2);
    });

    test('stampedRegionCount', () {
      final eval = BadgeEvaluator(
        records: [],
        stamps: [
          _stamp(name: '북한산', region: '서울', isStamped: true),
          _stamp(name: '도봉산', region: '서울', isStamped: true),
          _stamp(name: '설악산', region: '강원', isStamped: true),
        ],
      );
      expect(eval.stampedRegionCount, 2);
    });

    test('hasIslandStamp', () {
      final eval = BadgeEvaluator(
        records: [],
        stamps: [_stamp(name: '한라산', region: '제주', isStamped: true)],
      );
      expect(eval.hasIslandStamp, isTrue);
    });

    test('capitalAreaStamps', () {
      final eval = BadgeEvaluator(
        records: [],
        stamps: [
          _stamp(name: '북한산', region: '서울', isStamped: true),
          _stamp(name: '관악산', region: '서울', isStamped: true),
          _stamp(name: '화악산', region: '경기', isStamped: true),
        ],
      );
      expect(eval.capitalAreaStamps, 3);
    });

    test('hasPeakAbove', () {
      final eval = BadgeEvaluator(
        records: [],
        stamps: [
          _stamp(name: '지리산', height: 1915, isStamped: true),
          _stamp(name: '관악산', height: 632, isStamped: true),
        ],
      );
      expect(eval.hasPeakAbove(1500), isTrue);
      expect(eval.hasPeakAbove(2000), isFalse);
    });
  });

  group('BadgeEvaluator - time helpers', () {
    test('hasHikeBefore', () {
      final eval = BadgeEvaluator(
        records: [_record(startTime: DateTime(2025, 3, 1, 5, 30))],
        stamps: [],
      );
      expect(eval.hasHikeBefore(6), isTrue);
      expect(eval.hasHikeBefore(5), isFalse);
    });

    test('maxDurationHours from startTime/endTime', () {
      final eval = BadgeEvaluator(
        records: [
          _record(
            startTime: DateTime(2025, 3, 1, 8, 0),
            endTime: DateTime(2025, 3, 1, 12, 30),
          ),
        ],
        stamps: [],
      );
      expect(eval.maxDurationHours, closeTo(4.5, 0.01));
    });

    test('maxDurationHours from duration string', () {
      final eval = BadgeEvaluator(
        records: [_record(duration: '3h 15m')],
        stamps: [],
      );
      expect(eval.maxDurationHours, closeTo(3.25, 0.01));
    });

    test('hasQuickHike', () {
      final eval = BadgeEvaluator(
        records: [_record(duration: '0h 45m')],
        stamps: [],
      );
      expect(eval.hasQuickHike, isTrue);
    });
  });

  group('BadgeEvaluator - consistency', () {
    test('maxStreak consecutive days', () {
      final eval = BadgeEvaluator(
        records: [
          _record(startTime: DateTime(2025, 3, 1)),
          _record(startTime: DateTime(2025, 3, 2)),
          _record(startTime: DateTime(2025, 3, 3)),
          _record(startTime: DateTime(2025, 3, 5)),
        ],
        stamps: [],
      );
      expect(eval.maxStreak, 3);
    });

    test('seasonsCovered', () {
      final eval = BadgeEvaluator(
        records: [
          _record(startTime: DateTime(2025, 1, 15)),  // winter
          _record(startTime: DateTime(2025, 4, 15)),  // spring
          _record(startTime: DateTime(2025, 7, 15)),  // summer
          _record(startTime: DateTime(2025, 10, 15)), // fall
        ],
        stamps: [],
      );
      expect(eval.seasonsCovered, 4);
    });
  });

  group('BadgeEvaluator - progress', () {
    test('getProgressRatio clamps to 0-1', () {
      final eval = BadgeEvaluator(
        records: List.generate(15, (_) => _record()),
        stamps: [],
      );
      expect(eval.getProgressRatio(BadgeType.hikes10), 1.0);
      expect(eval.getProgressRatio(BadgeType.hikes25), closeTo(0.6, 0.01));
    });

    test('getProgress returns formatted string', () {
      final eval = BadgeEvaluator(
        records: List.generate(3, (_) => _record()),
        stamps: [],
      );
      expect(eval.getProgress(BadgeType.hikes5), '3 / 5');
    });
  });

  group('BadgeEvaluator - evaluateAll', () {
    test('returns earned badges', () {
      final records = List.generate(10, (i) => _record(distanceKm: 2.0));
      final eval = BadgeEvaluator(records: records, stamps: []);
      final earned = eval.evaluateAll();

      expect(earned.contains(BadgeType.firstHike), isTrue);
      expect(earned.contains(BadgeType.hikes5), isTrue);
      expect(earned.contains(BadgeType.hikes10), isTrue);
      expect(earned.contains(BadgeType.distance10km), isTrue);
      expect(earned.contains(BadgeType.hikes25), isFalse);
    });
  });

  group('BadgeEvaluator - challenge helpers', () {
    test('weekendHikes', () {
      final eval = BadgeEvaluator(
        records: [
          _record(startTime: DateTime(2025, 3, 1)),  // Saturday
          _record(startTime: DateTime(2025, 3, 2)),  // Sunday
          _record(startTime: DateTime(2025, 3, 3)),  // Monday
        ],
        stamps: [],
      );
      expect(eval.weekendHikes, 2);
      expect(eval.weekdayHikes, 1);
    });

    test('uniqueMountainCount', () {
      final eval = BadgeEvaluator(
        records: [
          _record(mountain: '북한산'),
          _record(mountain: '설악산'),
          _record(mountain: '북한산'),
        ],
        stamps: [],
      );
      expect(eval.uniqueMountainCount, 2);
    });

    test('hasSpeedDemon', () {
      final eval = BadgeEvaluator(
        records: [
          _record(
            distanceKm: 6.0,
            startTime: DateTime(2025, 3, 1, 8, 0),
            endTime: DateTime(2025, 3, 1, 9, 30),
          ),
        ],
        stamps: [],
      );
      expect(eval.hasSpeedDemon, isTrue);
    });
  });
}
