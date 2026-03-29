import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:woori_san/core/constants.dart';
import 'package:woori_san/datasources/local/plan_local.dart';
import 'package:woori_san/datasources/local/stamp_local.dart';
import 'package:woori_san/datasources/local/mountain_local.dart';
import 'package:woori_san/datasources/local/weather_local.dart';
import 'package:woori_san/datasources/local/review_local.dart';
import 'package:woori_san/datasources/local/favorite_local.dart';
import 'package:woori_san/datasources/local/badge_local.dart';
import 'package:woori_san/models/hiking_plan.dart';
import 'package:woori_san/models/hiking_record.dart';
import 'package:woori_san/models/stamp.dart';
import 'package:woori_san/models/mountain.dart';
import 'package:woori_san/models/weather.dart';
import 'package:woori_san/models/review.dart';
import 'package:woori_san/models/badge.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(tempDir.path);
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  // ---------------------------------------------------------------------------
  // PlanLocalDataSource
  // ---------------------------------------------------------------------------
  group('PlanLocalDataSource', () {
    late PlanLocalDataSource ds;

    setUp(() async {
      await Hive.openBox(AppConstants.planBox);
      ds = PlanLocalDataSource();
    });

    group('getPlans / savePlans', () {
      test('getPlans returns empty list when box is empty', () {
        expect(ds.getPlans(), isEmpty);
      });

      test('savePlans then getPlans round-trips correctly', () async {
        final plans = [
          HikingPlan(
            id: 'p1',
            mountain: '북한산',
            date: '2025-04-01',
            status: PlanStatus.confirmed,
            emoji: '🏔️',
            memo: '첫 등산',
          ),
          HikingPlan(
            id: 'p2',
            mountain: '설악산',
            mountainId: 42,
            date: '2025-05-01',
            status: PlanStatus.pending,
            emoji: '⛰️',
          ),
        ];

        await ds.savePlans(plans);
        final loaded = ds.getPlans();

        expect(loaded.length, 2);
        expect(loaded[0].id, 'p1');
        expect(loaded[0].mountain, '북한산');
        expect(loaded[0].status, PlanStatus.confirmed);
        expect(loaded[0].memo, '첫 등산');
        expect(loaded[1].id, 'p2');
        // Note: HikingPlan.toJson() stores mountainId (42) as the 'mountain'
        // field when mountainId is set, so round-trip reads it back as '42'.
        expect(loaded[1].mountain, '42');
        expect(loaded[1].mountainId, 42);
        expect(loaded[1].status, PlanStatus.pending);
      });

      test('savePlans overwrites previous data', () async {
        await ds.savePlans([
          HikingPlan(id: 'a', mountain: 'A', date: 'd', status: PlanStatus.pending, emoji: '🏔️'),
        ]);
        await ds.savePlans([
          HikingPlan(id: 'b', mountain: 'B', date: 'd', status: PlanStatus.done, emoji: '⛰️'),
        ]);

        final loaded = ds.getPlans();
        expect(loaded.length, 1);
        expect(loaded[0].id, 'b');
      });

      test('getPlans returns empty list on deserialization failure', () async {
        // Write invalid JSON to the box directly
        final box = Hive.box(AppConstants.planBox);
        await box.put('plans', 'not valid json {{{');

        expect(ds.getPlans(), isEmpty);
      });
    });

    group('getChecklist / saveChecklist', () {
      test('getChecklist returns default checklist when box is empty', () {
        final checklist = ds.getChecklist();

        expect(checklist, isNotEmpty);
        // defaultChecklist has 6 items
        expect(checklist.length, defaultChecklist.length);
        expect(checklist[0].text, '등산화');
        expect(checklist[0].checked, isFalse);
      });

      test('saveChecklist then getChecklist round-trips correctly', () async {
        final items = [
          ChecklistItem(text: '물', checked: true),
          ChecklistItem(text: '간식', checked: false),
        ];

        await ds.saveChecklist(items);
        final loaded = ds.getChecklist();

        expect(loaded.length, 2);
        expect(loaded[0].text, '물');
        expect(loaded[0].checked, isTrue);
        expect(loaded[1].text, '간식');
        expect(loaded[1].checked, isFalse);
      });

      test('getChecklist returns default on deserialization failure', () async {
        final box = Hive.box(AppConstants.planBox);
        await box.put('checklist', '<<<broken>>>');

        final checklist = ds.getChecklist();
        expect(checklist.length, defaultChecklist.length);
      });
    });

    group('getRecords / saveRecords', () {
      test('getRecords returns empty list when box is empty', () {
        expect(ds.getRecords(), isEmpty);
      });

      test('saveRecords then getRecords round-trips correctly', () async {
        final records = [
          HikingRecord(
            id: 'r1',
            mountain: '관악산',
            date: '2025-03-15',
            duration: '2h 30m',
            distanceKm: 5.5,
            emoji: '🏔️',
          ),
        ];

        await ds.saveRecords(records);
        final loaded = ds.getRecords();

        expect(loaded.length, 1);
        expect(loaded[0].id, 'r1');
        expect(loaded[0].mountain, '관악산');
        expect(loaded[0].distanceKm, 5.5);
      });

      test('getRecords returns empty list on deserialization failure', () async {
        final box = Hive.box(AppConstants.planBox);
        await box.put('records', 'not-json');

        expect(ds.getRecords(), isEmpty);
      });
    });
  });

  // ---------------------------------------------------------------------------
  // StampLocalDataSource
  // ---------------------------------------------------------------------------
  group('StampLocalDataSource', () {
    late StampLocalDataSource ds;

    setUp(() async {
      await Hive.openBox(AppConstants.stampBox);
      ds = StampLocalDataSource();
    });

    test('getAll returns defaultStamps when box is empty', () {
      final stamps = ds.getAll();

      expect(stamps, isNotEmpty);
      expect(stamps.length, defaultStamps.length);
      // First stamp in defaultStamps is '가리산'
      expect(stamps[0].name, '가리산');
      expect(stamps[0].isStamped, isTrue);
    });

    test('saveAll then getAll returns saved data', () async {
      final customStamps = [
        const Stamp(name: 'TestMt', region: 'Seoul', height: 100, isStamped: true, stampDate: '2025-01-01'),
        const Stamp(name: 'TestMt2', region: 'Busan', height: 200),
      ];

      await ds.saveAll(customStamps);
      final loaded = ds.getAll();

      expect(loaded.length, 2);
      expect(loaded[0].name, 'TestMt');
      expect(loaded[0].isStamped, isTrue);
      expect(loaded[0].stampDate, '2025-01-01');
      expect(loaded[1].name, 'TestMt2');
      expect(loaded[1].isStamped, isFalse);
    });

    test('saveAll overwrites previous data', () async {
      await ds.saveAll([const Stamp(name: 'A', region: 'R', height: 1)]);
      await ds.saveAll([const Stamp(name: 'B', region: 'R', height: 2)]);

      final loaded = ds.getAll();
      expect(loaded.length, 1);
      expect(loaded[0].name, 'B');
    });

    test('getAll returns defaultStamps on deserialization failure', () async {
      final box = Hive.box(AppConstants.stampBox);
      await box.put('stamps', '{invalid_json{{{');

      final stamps = ds.getAll();
      expect(stamps.length, defaultStamps.length);
    });
  });

  // ---------------------------------------------------------------------------
  // MountainLocalDataSource
  // ---------------------------------------------------------------------------
  group('MountainLocalDataSource', () {
    late MountainLocalDataSource ds;

    setUp(() async {
      await Hive.openBox(AppConstants.cacheBox);
      ds = MountainLocalDataSource();
    });

    Mountain _testMountain({String id = 'mt_1', String name = '테스트산'}) {
      return Mountain(
        id: id,
        name: name,
        location: '서울',
        difficulty: Difficulty.beginner,
        time: '약 2시간',
        distanceKm: 3.0,
        height: 500,
        emoji: '🏔️',
        colors: const [],
        description: '테스트 산입니다.',
        latitude: 37.5,
        longitude: 127.0,
      );
    }

    test('getCached returns null when box is empty', () async {
      expect(await ds.getCached(), isNull);
    });

    test('cache then getCached returns cached data', () async {
      final mountains = [_testMountain(), _testMountain(id: 'mt_2', name: '두번째산')];
      await ds.cache(mountains);

      final loaded = await ds.getCached();

      expect(loaded, isNotNull);
      expect(loaded!.length, 2);
      expect(loaded[0].name, '테스트산');
      expect(loaded[1].name, '두번째산');
    });

    test('getCached returns null when cache is expired', () async {
      final mountains = [_testMountain()];

      // Manually write data with an expiry in the past
      final box = Hive.box(AppConstants.cacheBox);
      final data = jsonEncode(mountains.map((e) => e.toJson()).toList());
      final pastExpiry = DateTime.now().subtract(const Duration(hours: 25)).toIso8601String();
      await box.put('mountains_cache', data);
      await box.put('mountains_cache_time', pastExpiry);

      final loaded = await ds.getCached();
      expect(loaded, isNull);
    });

    test('getCached returns data when cache is not yet expired', () async {
      final mountains = [_testMountain()];

      // Manually write data with an expiry in the future
      final box = Hive.box(AppConstants.cacheBox);
      final data = jsonEncode(mountains.map((e) => e.toJson()).toList());
      final futureExpiry = DateTime.now().add(const Duration(hours: 12)).toIso8601String();
      await box.put('mountains_cache', data);
      await box.put('mountains_cache_time', futureExpiry);

      final loaded = await ds.getCached();
      expect(loaded, isNotNull);
      expect(loaded!.length, 1);
      expect(loaded[0].name, '테스트산');
    });

    test('clearCache removes cached data', () async {
      await ds.cache([_testMountain()]);
      expect(await ds.getCached(), isNotNull);

      await ds.clearCache();
      expect(await ds.getCached(), isNull);
    });

    test('getCached returns null on deserialization failure', () async {
      final box = Hive.box(AppConstants.cacheBox);
      final futureExpiry = DateTime.now().add(const Duration(hours: 12)).toIso8601String();
      await box.put('mountains_cache', 'broken json');
      await box.put('mountains_cache_time', futureExpiry);

      final loaded = await ds.getCached();
      expect(loaded, isNull);
    });

    test('cache overwrites previous cached data', () async {
      await ds.cache([_testMountain(name: 'First')]);
      await ds.cache([_testMountain(name: 'Second'), _testMountain(id: 'mt_3', name: 'Third')]);

      final loaded = await ds.getCached();
      expect(loaded, isNotNull);
      expect(loaded!.length, 2);
      expect(loaded[0].name, 'Second');
    });
  });

  // ---------------------------------------------------------------------------
  // WeatherLocalDataSource
  // ---------------------------------------------------------------------------
  group('WeatherLocalDataSource', () {
    late WeatherLocalDataSource ds;

    setUp(() async {
      await Hive.openBox(AppConstants.weatherBox);
      ds = WeatherLocalDataSource();
    });

    Weather _testWeather() {
      return Weather(
        temperature: 22.5,
        condition: 'Clear',
        description: '맑음',
        windSpeed: 3.2,
        humidity: 55,
        iconCode: '01d',
        forecastDate: DateTime(2025, 4, 1, 12, 0),
      );
    }

    test('getCached returns null when box is empty', () async {
      expect(await ds.getCached(), isNull);
    });

    test('cache then getCached returns cached weather', () async {
      final weather = _testWeather();
      await ds.cache(weather);

      final loaded = await ds.getCached();

      expect(loaded, isNotNull);
      expect(loaded!.temperature, 22.5);
      expect(loaded.condition, 'Clear');
      expect(loaded.humidity, 55);
    });

    test('getCached returns null when cache is expired', () async {
      final weather = _testWeather();

      // Manually write data with a past expiry
      final box = Hive.box(AppConstants.weatherBox);
      await box.put('weather_cache', jsonEncode(weather.toJson()));
      final pastExpiry = DateTime.now().subtract(const Duration(hours: 4)).toIso8601String();
      await box.put('weather_cache_time', pastExpiry);

      expect(await ds.getCached(), isNull);
    });

    test('getCached returns data when cache is still valid', () async {
      final weather = _testWeather();

      final box = Hive.box(AppConstants.weatherBox);
      await box.put('weather_cache', jsonEncode(weather.toJson()));
      final futureExpiry = DateTime.now().add(const Duration(hours: 1)).toIso8601String();
      await box.put('weather_cache_time', futureExpiry);

      final loaded = await ds.getCached();
      expect(loaded, isNotNull);
      expect(loaded!.temperature, 22.5);
    });

    test('clearCache removes weather data', () async {
      await ds.cache(_testWeather());
      expect(await ds.getCached(), isNotNull);

      await ds.clearCache();
      expect(await ds.getCached(), isNull);
    });

    test('getCached returns null on deserialization failure', () async {
      final box = Hive.box(AppConstants.weatherBox);
      final futureExpiry = DateTime.now().add(const Duration(hours: 1)).toIso8601String();
      await box.put('weather_cache', 'not json');
      await box.put('weather_cache_time', futureExpiry);

      expect(await ds.getCached(), isNull);
    });

    test('cache overwrites previous weather data', () async {
      await ds.cache(_testWeather());

      final updated = Weather(
        temperature: -5.0,
        condition: 'Snow',
        description: '눈',
        windSpeed: 8.0,
        humidity: 90,
        iconCode: '13d',
        forecastDate: DateTime(2025, 12, 25, 10, 0),
      );
      await ds.cache(updated);

      final loaded = await ds.getCached();
      expect(loaded, isNotNull);
      expect(loaded!.temperature, -5.0);
      expect(loaded.condition, 'Snow');
    });
  });

  // ---------------------------------------------------------------------------
  // ReviewLocalDataSource
  // ---------------------------------------------------------------------------
  group('ReviewLocalDataSource', () {
    late ReviewLocalDataSource ds;

    setUp(() async {
      await Hive.openBox(AppConstants.reviewBox);
      ds = ReviewLocalDataSource();
    });

    Review _testReview({String id = 'rev1', String mountainId = 'mt_1'}) {
      return Review(
        id: id,
        mountainId: mountainId,
        userId: 'user1',
        userNickname: '산사랑',
        content: '경치가 좋았어요!',
        rating: 4.5,
        createdAt: DateTime(2025, 3, 1),
      );
    }

    test('getCached returns null when nothing is cached', () {
      expect(ds.getCached('mt_1'), isNull);
    });

    test('cache then getCached returns cached reviews', () async {
      final reviews = [_testReview(), _testReview(id: 'rev2')];
      await ds.cache('mt_1', reviews);

      final loaded = ds.getCached('mt_1');

      expect(loaded, isNotNull);
      expect(loaded!.length, 2);
      expect(loaded[0].id, 'rev1');
      expect(loaded[0].content, '경치가 좋았어요!');
      expect(loaded[1].id, 'rev2');
    });

    test('getCached returns null when cache is expired (>1h)', () async {
      final reviews = [_testReview()];

      // Manually write data with a past timestamp
      final box = Hive.box(AppConstants.reviewBox);
      await box.put('mt_1', jsonEncode(reviews.map((e) => e.toJson()).toList()));
      final pastTime = DateTime.now().subtract(const Duration(hours: 2)).toIso8601String();
      await box.put('mt_1_ts', pastTime);

      expect(ds.getCached('mt_1'), isNull);
    });

    test('getCached returns data when cache is within TTL', () async {
      final reviews = [_testReview()];

      final box = Hive.box(AppConstants.reviewBox);
      await box.put('mt_1', jsonEncode(reviews.map((e) => e.toJson()).toList()));
      final recentTime = DateTime.now().subtract(const Duration(minutes: 30)).toIso8601String();
      await box.put('mt_1_ts', recentTime);

      final loaded = ds.getCached('mt_1');
      expect(loaded, isNotNull);
      expect(loaded!.length, 1);
    });

    test('getCached returns null when timestamp is missing', () async {
      final box = Hive.box(AppConstants.reviewBox);
      await box.put('mt_1', jsonEncode([_testReview().toJson()]));
      // No timestamp key written

      expect(ds.getCached('mt_1'), isNull);
    });

    test('different mountainIds are cached independently', () async {
      await ds.cache('mt_1', [_testReview(id: 'r1', mountainId: 'mt_1')]);
      await ds.cache('mt_2', [_testReview(id: 'r2', mountainId: 'mt_2')]);

      final loaded1 = ds.getCached('mt_1');
      final loaded2 = ds.getCached('mt_2');

      expect(loaded1, isNotNull);
      expect(loaded1!.length, 1);
      expect(loaded1[0].id, 'r1');

      expect(loaded2, isNotNull);
      expect(loaded2!.length, 1);
      expect(loaded2[0].id, 'r2');
    });

    test('getCached returns null on deserialization failure', () async {
      final box = Hive.box(AppConstants.reviewBox);
      await box.put('mt_1', 'broken json');
      final recentTime = DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String();
      await box.put('mt_1_ts', recentTime);

      expect(ds.getCached('mt_1'), isNull);
    });

    test('cache overwrites previous reviews for same mountainId', () async {
      await ds.cache('mt_1', [_testReview(id: 'old')]);
      await ds.cache('mt_1', [_testReview(id: 'new1'), _testReview(id: 'new2')]);

      final loaded = ds.getCached('mt_1');
      expect(loaded, isNotNull);
      expect(loaded!.length, 2);
      expect(loaded[0].id, 'new1');
    });
  });

  // ---------------------------------------------------------------------------
  // FavoriteLocalDataSource
  // ---------------------------------------------------------------------------
  group('FavoriteLocalDataSource', () {
    late FavoriteLocalDataSource ds;

    setUp(() async {
      await Hive.openBox(AppConstants.favoriteBox);
      ds = FavoriteLocalDataSource();
    });

    test('getAll returns empty list when box is empty', () {
      expect(ds.getAll(), isEmpty);
    });

    test('saveAll then getAll returns saved favorites', () async {
      await ds.saveAll(['mt_1', 'mt_5', 'mt_10']);

      final loaded = ds.getAll();
      expect(loaded, ['mt_1', 'mt_5', 'mt_10']);
    });

    test('saveAll with empty list clears favorites', () async {
      await ds.saveAll(['mt_1', 'mt_2']);
      await ds.saveAll([]);

      expect(ds.getAll(), isEmpty);
    });

    test('saveAll overwrites previous favorites', () async {
      await ds.saveAll(['mt_1', 'mt_2']);
      await ds.saveAll(['mt_3']);

      final loaded = ds.getAll();
      expect(loaded, ['mt_3']);
    });

    test('getAll returns empty list on deserialization failure', () async {
      final box = Hive.box(AppConstants.favoriteBox);
      await box.put('favoriteIds', 'not-a-json-list');

      expect(ds.getAll(), isEmpty);
    });

    test('getAll preserves order of saved ids', () async {
      final ids = ['mt_100', 'mt_1', 'mt_50', 'mt_25'];
      await ds.saveAll(ids);

      expect(ds.getAll(), ids);
    });
  });

  // ---------------------------------------------------------------------------
  // BadgeLocalDataSource
  // ---------------------------------------------------------------------------
  group('BadgeLocalDataSource', () {
    late BadgeLocalDataSource ds;

    setUp(() async {
      await Hive.openBox(AppConstants.badgeBox);
      ds = BadgeLocalDataSource();
    });

    test('getEarnedBadges returns empty map when box is empty', () {
      expect(ds.getEarnedBadges(), isEmpty);
    });

    test('saveEarnedBadge stores badge with date', () async {
      final date = DateTime(2025, 3, 15, 10, 30);
      await ds.saveEarnedBadge(BadgeType.firstHike, date);

      final earned = ds.getEarnedBadges();
      expect(earned.length, 1);
      expect(earned.containsKey('firstHike'), isTrue);
      expect(earned['firstHike'], date.toIso8601String());
    });

    test('saveEarnedBadge can save multiple different badges', () async {
      await ds.saveEarnedBadge(BadgeType.firstHike, DateTime(2025, 1, 1));
      await ds.saveEarnedBadge(BadgeType.hikes5, DateTime(2025, 2, 1));
      await ds.saveEarnedBadge(BadgeType.distance10km, DateTime(2025, 3, 1));

      final earned = ds.getEarnedBadges();
      expect(earned.length, 3);
      expect(earned.containsKey('firstHike'), isTrue);
      expect(earned.containsKey('hikes5'), isTrue);
      expect(earned.containsKey('distance10km'), isTrue);
    });

    test('saveEarnedBadge overwrites same badge type', () async {
      await ds.saveEarnedBadge(BadgeType.firstHike, DateTime(2025, 1, 1));
      await ds.saveEarnedBadge(BadgeType.firstHike, DateTime(2025, 6, 15));

      final earned = ds.getEarnedBadges();
      expect(earned.length, 1);
      expect(earned['firstHike'], DateTime(2025, 6, 15).toIso8601String());
    });

    test('getEarnedBadges only returns string values', () async {
      // The box stores string values. If a non-string value were somehow
      // inserted, getEarnedBadges skips it.
      final box = Hive.box(AppConstants.badgeBox);
      await box.put('firstHike', DateTime(2025, 1, 1).toIso8601String());
      await box.put('nonStringKey', 12345); // non-string value

      final earned = ds.getEarnedBadges();
      expect(earned.length, 1);
      expect(earned.containsKey('firstHike'), isTrue);
      // 'nonStringKey' should be excluded because value is not String
      expect(earned.containsKey('nonStringKey'), isFalse);
    });

    test('getEarnedBadges reflects all saved badge types', () async {
      await ds.saveEarnedBadge(BadgeType.peak1000m, DateTime(2025, 5, 1));
      await ds.saveEarnedBadge(BadgeType.allRegions, DateTime(2025, 6, 1));
      await ds.saveEarnedBadge(BadgeType.hikes100, DateTime(2025, 7, 1));

      final earned = ds.getEarnedBadges();
      expect(earned.keys, containsAll(['peak1000m', 'allRegions', 'hikes100']));
    });
  });
}
