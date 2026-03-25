import 'package:flutter_test/flutter_test.dart';
import 'package:woori_san/models/badge.dart';
import 'package:woori_san/models/hiking_record.dart';
import 'package:woori_san/models/stamp.dart';
import 'package:woori_san/providers/badge_provider.dart';

void main() {
  group('BadgeProvider', () {
    test('computes earned badges from records and stamps', () {
      final provider = BadgeProvider(
        records: [
          HikingRecord(
            mountain: '북한산',
            date: '2026.03.26',
            duration: '2h 15m',
            distanceKm: 11.0,
            emoji: '⛰️',
          ),
        ],
        stamps: [
          Stamp(name: '북한산', region: '서울', height: 836, isStamped: true, isTogetherStamped: true),
          Stamp(name: '관악산', region: '서울', height: 629, isStamped: true),
          Stamp(name: '도봉산', region: '서울', height: 740, isStamped: true),
          Stamp(name: '수락산', region: '서울', height: 638, isStamped: true),
          Stamp(name: '불암산', region: '서울', height: 508, isStamped: true),
        ],
      );

      expect(provider.isEarned(BadgeType.firstHike), isTrue);
      expect(provider.isEarned(BadgeType.distance10km), isTrue);
      expect(provider.isEarned(BadgeType.stamps5), isTrue);
      expect(provider.isEarned(BadgeType.together1), isTrue);
    });

    test('exposes progress and nextBadge for incomplete badge sets', () {
      final provider = BadgeProvider(
        records: [
          HikingRecord(
            mountain: '북한산',
            date: '2026.03.26',
            duration: '1h 30m',
            distanceKm: 4.2,
            emoji: '⛰️',
          ),
        ],
        stamps: const [],
      );

      expect(provider.earnedCount, greaterThan(0));
      expect(provider.getProgress(BadgeType.hikes5), '1 / 5');
      expect(provider.getProgressRatio(BadgeType.hikes5), closeTo(0.2, 0.0001));
      expect(provider.nextBadge, isNotNull);
    });

    test('returns empty progress state when there is no data', () {
      final provider = BadgeProvider(records: const [], stamps: const []);

      expect(provider.earnedCount, 0);
      expect(provider.nextBadge, isNull);
      expect(provider.getProgress(BadgeType.hikes5), '-');
      expect(provider.getProgressRatio(BadgeType.hikes5), 0.0);
    });
  });
}
