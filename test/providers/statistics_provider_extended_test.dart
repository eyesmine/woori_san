import 'package:flutter_test/flutter_test.dart';
import 'package:woori_san/models/hiking_record.dart';
import 'package:woori_san/providers/statistics_provider.dart';

void main() {
  group('StatisticsProvider extended', () {
    group('totalDistanceKm', () {
      test('sums distances from all records', () {
        final provider = StatisticsProvider(
          records: [
            HikingRecord(
              mountain: '북한산',
              date: '2026.03.26',
              duration: '2h 10m',
              distanceKm: 6.2,
              emoji: '⛰️',
            ),
            HikingRecord(
              mountain: '관악산',
              date: '2026.03.27',
              duration: '1h 45m',
              distanceKm: 4.5,
              emoji: '🌄',
            ),
            HikingRecord(
              mountain: '설악산',
              date: '2026.03.28',
              duration: '5h 30m',
              distanceKm: 12.3,
              emoji: '🏔️',
            ),
          ],
        );

        expect(provider.totalDistanceKm, closeTo(23.0, 0.01));
      });

      test('returns 0 for empty records', () {
        final provider = StatisticsProvider(records: []);

        expect(provider.totalDistanceKm, 0);
      });

      test('totalDistance returns formatted string', () {
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

        expect(provider.totalDistance, '6.2km');
      });
    });

    group('totalElevationGain', () {
      test('sums elevation gains from all records', () {
        final provider = StatisticsProvider(
          records: [
            HikingRecord(
              mountain: '북한산',
              date: '2026.03.26',
              duration: '2h 10m',
              distanceKm: 6.2,
              emoji: '⛰️',
              elevationGain: 500,
            ),
            HikingRecord(
              mountain: '관악산',
              date: '2026.03.27',
              duration: '1h 45m',
              distanceKm: 4.5,
              emoji: '🌄',
              elevationGain: 300,
            ),
            HikingRecord(
              mountain: '설악산',
              date: '2026.03.28',
              duration: '5h 30m',
              distanceKm: 12.3,
              emoji: '🏔️',
              elevationGain: 1200,
            ),
          ],
        );

        expect(provider.totalElevationGain, 2000);
      });

      test('treats null elevationGain as 0', () {
        final provider = StatisticsProvider(
          records: [
            HikingRecord(
              mountain: '북한산',
              date: '2026.03.26',
              duration: '2h 10m',
              distanceKm: 6.2,
              emoji: '⛰️',
              elevationGain: 500,
            ),
            HikingRecord(
              mountain: '관악산',
              date: '2026.03.27',
              duration: '1h 45m',
              distanceKm: 4.5,
              emoji: '🌄',
              // elevationGain is null
            ),
          ],
        );

        expect(provider.totalElevationGain, 500);
      });

      test('returns 0 for empty records', () {
        final provider = StatisticsProvider(records: []);

        expect(provider.totalElevationGain, 0);
      });
    });

    group('longestDistance', () {
      test('returns the maximum distance formatted as km', () {
        final provider = StatisticsProvider(
          records: [
            HikingRecord(
              mountain: '북한산',
              date: '2026.03.26',
              duration: '2h 10m',
              distanceKm: 6.2,
              emoji: '⛰️',
            ),
            HikingRecord(
              mountain: '설악산',
              date: '2026.03.28',
              duration: '5h 30m',
              distanceKm: 12.3,
              emoji: '🏔️',
            ),
            HikingRecord(
              mountain: '관악산',
              date: '2026.03.27',
              duration: '1h 45m',
              distanceKm: 4.5,
              emoji: '🌄',
            ),
          ],
        );

        expect(provider.longestDistance, '12.3km');
      });

      test('returns dash for empty records', () {
        final provider = StatisticsProvider(records: []);

        expect(provider.longestDistance, '-');
      });

      test('works with single record', () {
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

        expect(provider.longestDistance, '6.2km');
      });
    });

    group('highestElevation', () {
      test('returns the maximum elevation formatted as m', () {
        final provider = StatisticsProvider(
          records: [
            HikingRecord(
              mountain: '북한산',
              date: '2026.03.26',
              duration: '2h 10m',
              distanceKm: 6.2,
              emoji: '⛰️',
              elevationGain: 500,
            ),
            HikingRecord(
              mountain: '설악산',
              date: '2026.03.28',
              duration: '5h 30m',
              distanceKm: 12.3,
              emoji: '🏔️',
              elevationGain: 1200,
            ),
            HikingRecord(
              mountain: '관악산',
              date: '2026.03.27',
              duration: '1h 45m',
              distanceKm: 4.5,
              emoji: '🌄',
              elevationGain: 300,
            ),
          ],
        );

        expect(provider.highestElevation, '1200m');
      });

      test('returns dash for empty records', () {
        final provider = StatisticsProvider(records: []);

        expect(provider.highestElevation, '-');
      });

      test('returns 0m when all elevationGain values are null', () {
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

        expect(provider.highestElevation, '0m');
      });
    });

    group('longestDuration', () {
      test('returns longest duration string from records', () {
        final provider = StatisticsProvider(
          records: [
            HikingRecord(
              mountain: '북한산',
              date: '2026.03.26',
              duration: '1h 30m',
              distanceKm: 6.2,
              emoji: '⛰️',
            ),
            HikingRecord(
              mountain: '설악산',
              date: '2026.03.28',
              duration: '5h 30m',
              distanceKm: 12.3,
              emoji: '🏔️',
            ),
          ],
        );

        expect(provider.longestDuration, '5h 30m');
      });

      test('parses Korean format "2시간 30분"', () {
        final provider = StatisticsProvider(
          records: [
            HikingRecord(
              mountain: '북한산',
              date: '2026.03.26',
              duration: '1시간 30분',
              distanceKm: 6.2,
              emoji: '⛰️',
            ),
            HikingRecord(
              mountain: '설악산',
              date: '2026.03.28',
              duration: '2시간 30분',
              distanceKm: 12.3,
              emoji: '🏔️',
            ),
          ],
        );

        expect(provider.longestDuration, '2시간 30분');
      });

      test('compares mixed Korean and English duration formats correctly', () {
        final provider = StatisticsProvider(
          records: [
            HikingRecord(
              mountain: '북한산',
              date: '2026.03.26',
              duration: '3시간 0분',
              distanceKm: 6.2,
              emoji: '⛰️',
            ),
            HikingRecord(
              mountain: '설악산',
              date: '2026.03.28',
              duration: '2h 45m',
              distanceKm: 12.3,
              emoji: '🏔️',
            ),
          ],
        );

        // 3시간 0분 = 180 min, 2h 45m = 165 min
        expect(provider.longestDuration, '3시간 0분');
      });

      test('returns dash for empty records', () {
        final provider = StatisticsProvider(records: []);

        expect(provider.longestDuration, '-');
      });
    });

    group('uniqueRegions', () {
      test('returns set of unique mountain names', () {
        final provider = StatisticsProvider(
          records: [
            HikingRecord(
              mountain: '북한산',
              date: '2026.03.26',
              duration: '2h 10m',
              distanceKm: 6.2,
              emoji: '⛰️',
            ),
            HikingRecord(
              mountain: '관악산',
              date: '2026.03.27',
              duration: '1h 45m',
              distanceKm: 4.5,
              emoji: '🌄',
            ),
            HikingRecord(
              mountain: '북한산',
              date: '2026.03.28',
              duration: '3h 0m',
              distanceKm: 7.1,
              emoji: '⛰️',
            ),
          ],
        );

        expect(provider.uniqueRegions, {'북한산', '관악산'});
        expect(provider.uniqueRegions.length, 2);
      });

      test('returns empty set for empty records', () {
        final provider = StatisticsProvider(records: []);

        expect(provider.uniqueRegions, isEmpty);
      });
    });

    group('hikingDates', () {
      test('returns empty set for empty records', () {
        final provider = StatisticsProvider(records: []);

        expect(provider.hikingDates, isEmpty);
      });

      test('returns dates from startTime', () {
        final provider = StatisticsProvider(
          records: [
            HikingRecord(
              mountain: '북한산',
              date: '2026.01.01',
              duration: '2h',
              distanceKm: 5.0,
              emoji: '⛰️',
              startTime: DateTime(2026, 3, 15, 8, 30),
            ),
          ],
        );

        expect(provider.hikingDates, {DateTime(2026, 3, 15)});
      });

      test('deduplicates dates from same day', () {
        final provider = StatisticsProvider(
          records: [
            HikingRecord(
              mountain: '북한산',
              date: '2026.03.15',
              duration: '2h',
              distanceKm: 5.0,
              emoji: '⛰️',
              startTime: DateTime(2026, 3, 15, 8, 0),
            ),
            HikingRecord(
              mountain: '관악산',
              date: '2026.03.15',
              duration: '1h',
              distanceKm: 3.0,
              emoji: '🌄',
              startTime: DateTime(2026, 3, 15, 14, 0),
            ),
          ],
        );

        expect(provider.hikingDates.length, 1);
        expect(provider.hikingDates, {DateTime(2026, 3, 15)});
      });
    });

    group('empty records returns dashes for best records', () {
      test('all best record fields return dash', () {
        final provider = StatisticsProvider(records: []);

        expect(provider.longestDistance, '-');
        expect(provider.highestElevation, '-');
        expect(provider.longestDuration, '-');
      });

      test('totalHikes is zero', () {
        final provider = StatisticsProvider(records: []);

        expect(provider.totalHikes, 0);
      });

      test('totalDistance is 0.0km', () {
        final provider = StatisticsProvider(records: []);

        expect(provider.totalDistance, '0.0km');
      });
    });
  });
}
