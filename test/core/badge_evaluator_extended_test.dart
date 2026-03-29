import 'package:flutter_test/flutter_test.dart';
import 'package:woori_san/core/badge_evaluator.dart';
import 'package:woori_san/models/badge.dart';
import 'package:woori_san/models/hiking_record.dart';
import 'package:woori_san/models/stamp.dart';

// ---------------------------------------------------------------------------
// Test helpers (same pattern as badge_evaluator_test.dart)
// ---------------------------------------------------------------------------

HikingRecord _record({
  String mountain = 'TestMt',
  double distanceKm = 5.0,
  int? elevationGain,
  DateTime? startTime,
  DateTime? endTime,
  String duration = '2h 30m',
  String date = '3월 15일',
}) {
  return HikingRecord(
    mountain: mountain,
    date: date,
    duration: duration,
    distanceKm: distanceKm,
    emoji: '',
    elevationGain: elevationGain,
    startTime: startTime,
    endTime: endTime,
  );
}

Stamp _stamp({
  String name = 'TestMt',
  String region = 'Seoul',
  int height = 500,
  bool isStamped = false,
  bool isTogether = false,
  String? stampDate,
}) {
  return Stamp(
    name: name,
    region: region,
    height: height,
    isStamped: isStamped,
    isTogetherStamped: isTogether,
    stampDate: stampDate,
  );
}

// ---------------------------------------------------------------------------
// Tests for CHANGED code paths
// ---------------------------------------------------------------------------

void main() {
  // ── hasRainHike (6-7 months only, separated from hasSummerHike) ────────

  group('hasRainHike', () {
    test('returns true for a June hike', () {
      final eval = BadgeEvaluator(
        records: [_record(startTime: DateTime(2025, 6, 15))],
        stamps: [],
      );
      expect(eval.hasRainHike, isTrue);
    });

    test('returns true for a July hike', () {
      final eval = BadgeEvaluator(
        records: [_record(startTime: DateTime(2025, 7, 20))],
        stamps: [],
      );
      expect(eval.hasRainHike, isTrue);
    });

    test('returns false for an August-only hike', () {
      final eval = BadgeEvaluator(
        records: [_record(startTime: DateTime(2025, 8, 10))],
        stamps: [],
      );
      expect(eval.hasRainHike, isFalse);
    });

    test('returns false for a May hike', () {
      final eval = BadgeEvaluator(
        records: [_record(startTime: DateTime(2025, 5, 31))],
        stamps: [],
      );
      expect(eval.hasRainHike, isFalse);
    });

    test('returns false with no records', () {
      final eval = BadgeEvaluator(records: [], stamps: []);
      expect(eval.hasRainHike, isFalse);
    });

    test('uses date field fallback when startTime is null', () {
      final eval = BadgeEvaluator(
        records: [_record(date: '6월 15일')],
        stamps: [],
      );
      expect(eval.hasRainHike, isTrue);
    });
  });

  // ── hasSummerHike (6-8 months) ────────────────────────────────────────

  group('hasSummerHike', () {
    test('returns true for a June hike', () {
      final eval = BadgeEvaluator(
        records: [_record(startTime: DateTime(2025, 6, 1))],
        stamps: [],
      );
      expect(eval.hasSummerHike, isTrue);
    });

    test('returns true for a July hike', () {
      final eval = BadgeEvaluator(
        records: [_record(startTime: DateTime(2025, 7, 15))],
        stamps: [],
      );
      expect(eval.hasSummerHike, isTrue);
    });

    test('returns true for an August hike', () {
      final eval = BadgeEvaluator(
        records: [_record(startTime: DateTime(2025, 8, 20))],
        stamps: [],
      );
      expect(eval.hasSummerHike, isTrue);
    });

    test('returns false for a September hike', () {
      final eval = BadgeEvaluator(
        records: [_record(startTime: DateTime(2025, 9, 1))],
        stamps: [],
      );
      expect(eval.hasSummerHike, isFalse);
    });

    test('returns false for a May hike', () {
      final eval = BadgeEvaluator(
        records: [_record(startTime: DateTime(2025, 5, 31))],
        stamps: [],
      );
      expect(eval.hasSummerHike, isFalse);
    });
  });

  // ── _parseDateField (tested indirectly) ───────────────────────────────

  group('_parseDateField (via bestMonthlyCount / hasRainHike)', () {
    test('parses "2025.01.20" format', () {
      // bestMonthlyCount calls _parseDateField for the date string
      final eval = BadgeEvaluator(
        records: [_record(date: '2025.01.20')],
        stamps: [],
      );
      // If parsed correctly, bestMonthlyCount should be 1 for Jan 2025
      expect(eval.bestMonthlyCount, 1);
    });

    test('parses "1월 20일" Korean format', () {
      final eval = BadgeEvaluator(
        records: [_record(date: '1월 20일')],
        stamps: [],
      );
      // Should parse successfully - the record contributes to a monthly count
      expect(eval.bestMonthlyCount, 1);
    });

    test('parses "12월 5일" Korean format for winter', () {
      final eval = BadgeEvaluator(
        records: [_record(date: '12월 5일')],
        stamps: [],
      );
      expect(eval.hasWinterHike, isTrue);
    });

    test('future date rolls back to previous year', () {
      // Use a month that is definitely in the future relative to "now"
      // We create a date far in the future: December 31 -- if running before Dec 31 this year,
      // it should roll back. We test indirectly via seasonsCovered.
      final now = DateTime.now();
      // Pick a month guaranteed to be in the future
      final futureMonth = now.month < 12 ? 12 : now.month;
      final futureDay = 28;

      // Only test rollback if that date is actually in the future
      if (DateTime(now.year, futureMonth, futureDay).isAfter(now)) {
        final eval = BadgeEvaluator(
          records: [_record(date: '$futureMonth월 ${futureDay}일')],
          stamps: [],
        );
        // After rollback, the year should be now.year - 1
        // bestYearlyCount should be 1 for that previous year
        expect(eval.bestYearlyCount, 1);
        expect(eval.bestMonthlyCount, 1);
      }
    });

    test('returns null for unparseable date string', () {
      final eval = BadgeEvaluator(
        records: [_record(date: 'garbage')],
        stamps: [],
      );
      // Should not contribute to any count
      expect(eval.bestMonthlyCount, 0);
    });
  });

  // ── hasWinterHike ─────────────────────────────────────────────────────

  group('hasWinterHike', () {
    test('returns true for December hike', () {
      final eval = BadgeEvaluator(
        records: [_record(startTime: DateTime(2025, 12, 15))],
        stamps: [],
      );
      expect(eval.hasWinterHike, isTrue);
    });

    test('returns true for January hike', () {
      final eval = BadgeEvaluator(
        records: [_record(startTime: DateTime(2025, 1, 10))],
        stamps: [],
      );
      expect(eval.hasWinterHike, isTrue);
    });

    test('returns true for February hike', () {
      final eval = BadgeEvaluator(
        records: [_record(startTime: DateTime(2025, 2, 28))],
        stamps: [],
      );
      expect(eval.hasWinterHike, isTrue);
    });

    test('returns false for March hike', () {
      final eval = BadgeEvaluator(
        records: [_record(startTime: DateTime(2025, 3, 1))],
        stamps: [],
      );
      expect(eval.hasWinterHike, isFalse);
    });

    test('returns false for November hike', () {
      final eval = BadgeEvaluator(
        records: [_record(startTime: DateTime(2025, 11, 30))],
        stamps: [],
      );
      expect(eval.hasWinterHike, isFalse);
    });

    test('returns false with no records', () {
      final eval = BadgeEvaluator(records: [], stamps: []);
      expect(eval.hasWinterHike, isFalse);
    });

    test('uses date field when startTime is null', () {
      final eval = BadgeEvaluator(
        records: [_record(date: '2025.02.14')],
        stamps: [],
      );
      expect(eval.hasWinterHike, isTrue);
    });
  });

  // ── capitalAreaStamps ─────────────────────────────────────────────────

  group('capitalAreaStamps', () {
    test('counts only stamped stamps in Seoul or Gyeonggi', () {
      final eval = BadgeEvaluator(
        records: [],
        stamps: [
          _stamp(name: 'A', region: '서울', isStamped: true),
          _stamp(name: 'B', region: '경기', isStamped: true),
          _stamp(name: 'C', region: '강원', isStamped: true),
          _stamp(name: 'D', region: '서울', isStamped: false),
        ],
      );
      expect(eval.capitalAreaStamps, 2);
    });

    test('returns 0 when no stamps in capital area', () {
      final eval = BadgeEvaluator(
        records: [],
        stamps: [
          _stamp(name: 'A', region: '강원', isStamped: true),
          _stamp(name: 'B', region: '전남', isStamped: true),
        ],
      );
      expect(eval.capitalAreaStamps, 0);
    });

    test('returns 0 when stamps list is empty', () {
      final eval = BadgeEvaluator(records: [], stamps: []);
      expect(eval.capitalAreaStamps, 0);
    });

    test('does not count unstamped Seoul/Gyeonggi stamps', () {
      final eval = BadgeEvaluator(
        records: [],
        stamps: [
          _stamp(name: 'A', region: '서울', isStamped: false),
          _stamp(name: 'B', region: '경기', isStamped: false),
        ],
      );
      expect(eval.capitalAreaStamps, 0);
    });

    test('does not count regions containing Seoul/Gyeonggi as substring', () {
      // e.g. "서울 관악" should NOT match since the check is == '서울'
      final eval = BadgeEvaluator(
        records: [],
        stamps: [
          _stamp(name: 'A', region: '서울 관악', isStamped: true),
          _stamp(name: 'B', region: '경기 포천', isStamped: true),
        ],
      );
      // These do NOT match exact '서울' or '경기'
      expect(eval.capitalAreaStamps, 0);
    });
  });

  // ── hasIslandStamp ────────────────────────────────────────────────────

  group('hasIslandStamp', () {
    test('returns true for stamped Jeju stamp', () {
      final eval = BadgeEvaluator(
        records: [],
        stamps: [_stamp(name: 'Hallasan', region: '제주', isStamped: true)],
      );
      expect(eval.hasIslandStamp, isTrue);
    });

    test('returns true for stamped Jejudo stamp', () {
      final eval = BadgeEvaluator(
        records: [],
        stamps: [_stamp(name: 'Hallasan', region: '제주도', isStamped: true)],
      );
      expect(eval.hasIslandStamp, isTrue);
    });

    test('returns false for unstamped Jeju stamp', () {
      final eval = BadgeEvaluator(
        records: [],
        stamps: [_stamp(name: 'Hallasan', region: '제주', isStamped: false)],
      );
      expect(eval.hasIslandStamp, isFalse);
    });

    test('returns false for non-Jeju region', () {
      final eval = BadgeEvaluator(
        records: [],
        stamps: [_stamp(name: 'A', region: '강원', isStamped: true)],
      );
      expect(eval.hasIslandStamp, isFalse);
    });

    test('returns false for empty stamps', () {
      final eval = BadgeEvaluator(records: [], stamps: []);
      expect(eval.hasIslandStamp, isFalse);
    });
  });

  // ── weekendHikes / weekdayHikes ───────────────────────────────────────

  group('weekendHikes / weekdayHikes', () {
    test('correctly separates weekend and weekday hikes via startTime', () {
      final eval = BadgeEvaluator(
        records: [
          _record(startTime: DateTime(2025, 3, 1)),  // Saturday
          _record(startTime: DateTime(2025, 3, 2)),  // Sunday
          _record(startTime: DateTime(2025, 3, 3)),  // Monday
          _record(startTime: DateTime(2025, 3, 4)),  // Tuesday
          _record(startTime: DateTime(2025, 3, 5)),  // Wednesday
        ],
        stamps: [],
      );
      expect(eval.weekendHikes, 2);
      expect(eval.weekdayHikes, 3);
    });

    test('returns 0 when no records exist', () {
      final eval = BadgeEvaluator(records: [], stamps: []);
      expect(eval.weekendHikes, 0);
      expect(eval.weekdayHikes, 0);
    });

    test('uses date field fallback when startTime is null', () {
      // "2025.03.08" is a Saturday, "2025.03.10" is a Monday
      final eval = BadgeEvaluator(
        records: [
          _record(date: '2025.03.08'),
          _record(date: '2025.03.10'),
        ],
        stamps: [],
      );
      expect(eval.weekendHikes, 1);
      expect(eval.weekdayHikes, 1);
    });

    test('all weekend records', () {
      final eval = BadgeEvaluator(
        records: [
          _record(startTime: DateTime(2025, 3, 8)),  // Saturday
          _record(startTime: DateTime(2025, 3, 9)),  // Sunday
          _record(startTime: DateTime(2025, 3, 15)), // Saturday
        ],
        stamps: [],
      );
      expect(eval.weekendHikes, 3);
      expect(eval.weekdayHikes, 0);
    });

    test('all weekday records', () {
      final eval = BadgeEvaluator(
        records: [
          _record(startTime: DateTime(2025, 3, 3)),  // Monday
          _record(startTime: DateTime(2025, 3, 6)),  // Thursday
          _record(startTime: DateTime(2025, 3, 7)),  // Friday
        ],
        stamps: [],
      );
      expect(eval.weekendHikes, 0);
      expect(eval.weekdayHikes, 3);
    });

    test('badge check: weekendWarrior requires >= 10 weekend hikes', () {
      final records = List.generate(10, (i) {
        // Generate 10 Saturdays starting from 2025-01-04
        return _record(startTime: DateTime(2025, 1, 4 + i * 7));
      });
      final eval = BadgeEvaluator(records: records, stamps: []);
      expect(eval.check(BadgeType.weekendWarrior), isTrue);
      expect(eval.weekendHikes, 10);
    });

    test('badge check: weekdayHiker requires >= 10 weekday hikes', () {
      final records = List.generate(10, (i) {
        // Generate 10 Mondays starting from 2025-01-06
        return _record(startTime: DateTime(2025, 1, 6 + i * 7));
      });
      final eval = BadgeEvaluator(records: records, stamps: []);
      expect(eval.check(BadgeType.weekdayHiker), isTrue);
      expect(eval.weekdayHikes, 10);
    });
  });

  // ── badge check integration for changed helpers ───────────────────────

  group('badge check integration for changed helpers', () {
    test('rainHiker badge uses hasRainHike', () {
      final eval = BadgeEvaluator(
        records: [_record(startTime: DateTime(2025, 7, 1))],
        stamps: [],
      );
      expect(eval.check(BadgeType.rainHiker), isTrue);
    });

    test('rainHiker badge false for August-only', () {
      final eval = BadgeEvaluator(
        records: [_record(startTime: DateTime(2025, 8, 15))],
        stamps: [],
      );
      expect(eval.check(BadgeType.rainHiker), isFalse);
    });

    test('summerHiker badge true for August', () {
      final eval = BadgeEvaluator(
        records: [_record(startTime: DateTime(2025, 8, 15))],
        stamps: [],
      );
      expect(eval.check(BadgeType.summerHiker), isTrue);
    });

    test('winterHiker badge true for January', () {
      final eval = BadgeEvaluator(
        records: [_record(startTime: DateTime(2025, 1, 15))],
        stamps: [],
      );
      expect(eval.check(BadgeType.winterHiker), isTrue);
    });

    test('islandMountain badge uses hasIslandStamp', () {
      final eval = BadgeEvaluator(
        records: [],
        stamps: [_stamp(name: 'Hallasan', region: '제주', isStamped: true)],
      );
      expect(eval.check(BadgeType.islandMountain), isTrue);
    });

    test('capitalArea5 badge requires 5 capital area stamps', () {
      final stamps = List.generate(5, (i) =>
        _stamp(name: 'Mt$i', region: '서울', isStamped: true),
      );
      final eval = BadgeEvaluator(records: [], stamps: stamps);
      expect(eval.check(BadgeType.capitalArea5), isTrue);
    });

    test('capitalArea5 badge false with only 4 capital area stamps', () {
      final stamps = List.generate(4, (i) =>
        _stamp(name: 'Mt$i', region: '서울', isStamped: true),
      );
      final eval = BadgeEvaluator(records: [], stamps: stamps);
      expect(eval.check(BadgeType.capitalArea5), isFalse);
    });
  });
}
