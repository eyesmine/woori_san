import 'package:flutter_test/flutter_test.dart';
import 'package:woori_san/models/hiking_record.dart';
import 'package:woori_san/providers/statistics_provider.dart';

void main() {
  group('StatisticsProvider', () {
    test('hikingDates parses yyyy.MM.dd manual record dates', () {
      final provider = StatisticsProvider(
        records: [
          HikingRecord(
            mountain: '북한산',
            date: '2026.03.26',
            duration: '2h 10m',
            distanceKm: 6.2,
            emoji: '⛰️',
          ),
        ],
      );

      expect(provider.hikingDates, contains(DateTime(2026, 3, 26)));
    });

    test('hikingDates prefers startTime when present', () {
      final provider = StatisticsProvider(
        records: [
          HikingRecord(
            mountain: '관악산',
            date: '2026.03.01',
            duration: '1h 45m',
            distanceKm: 4.5,
            emoji: '🌄',
            startTime: DateTime(2026, 3, 27, 6, 30),
          ),
        ],
      );

      expect(provider.hikingDates, contains(DateTime(2026, 3, 27)));
      expect(provider.hikingDates, isNot(contains(DateTime(2026, 3, 1))));
    });

    test('longestDuration parses hour-minute format used by manual records', () {
      final provider = StatisticsProvider(
        records: [
          HikingRecord(
            mountain: '북한산',
            date: '2026.03.26',
            duration: '45m',
            distanceKm: 3.2,
            emoji: '⛰️',
          ),
          HikingRecord(
            mountain: '설악산',
            date: '2026.03.27',
            duration: '2h 15m',
            distanceKm: 12.4,
            emoji: '🏔️',
          ),
        ],
      );

      expect(provider.longestDuration, '2h 15m');
    });
  });
}
