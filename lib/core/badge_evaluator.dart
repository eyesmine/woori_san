import '../models/badge.dart';
import '../models/hiking_record.dart';
import '../models/stamp.dart';

/// 배지 평가 및 진행도 계산 로직.
/// BadgeProvider에서 상태관리와 분리된 순수 로직 클래스.
class BadgeEvaluator {
  final List<HikingRecord> records;
  final List<Stamp> stamps;
  final DateTime? joinDate;
  final DateTime? birthday;

  BadgeEvaluator({
    required this.records,
    required this.stamps,
    this.joinDate,
    this.birthday,
  });

  /// 모든 배지를 평가하여 획득한 배지 Set 반환
  Set<BadgeType> evaluateAll() {
    final earned = <BadgeType>{};
    for (final badge in allBadgeDefinitions) {
      if (check(badge.type)) {
        earned.add(badge.type);
      }
    }
    return earned;
  }

  // ── check ─────────────────────────────────────

  bool check(BadgeType type) {
    return switch (type) {
      // Count
      BadgeType.firstHike => totalHikes >= 1,
      BadgeType.hikes5 => totalHikes >= 5,
      BadgeType.hikes10 => totalHikes >= 10,
      BadgeType.hikes25 => totalHikes >= 25,
      BadgeType.hikes50 => totalHikes >= 50,
      BadgeType.hikes100 => totalHikes >= 100,
      BadgeType.hikes200 => totalHikes >= 200,
      BadgeType.hikes365 => totalHikes >= 365,
      BadgeType.hikes500 => totalHikes >= 500,
      BadgeType.hikes1000 => totalHikes >= 1000,

      // Distance
      BadgeType.distance10km => totalDistanceKm >= 10,
      BadgeType.distance50km => totalDistanceKm >= 50,
      BadgeType.distance100km => totalDistanceKm >= 100,
      BadgeType.distance200km => totalDistanceKm >= 200,
      BadgeType.distance500km => totalDistanceKm >= 500,
      BadgeType.distance1000km => totalDistanceKm >= 1000,
      BadgeType.distance2000km => totalDistanceKm >= 2000,
      BadgeType.distance3000km => totalDistanceKm >= 3000,
      BadgeType.distance5000km => totalDistanceKm >= 5000,
      BadgeType.distance10000km => totalDistanceKm >= 10000,

      // Elevation
      BadgeType.elevation500m => totalElevation >= 500,
      BadgeType.elevation1000m => totalElevation >= 1000,
      BadgeType.elevation1500m => totalElevation >= 1500,
      BadgeType.elevation5000m => totalElevation >= 5000,
      BadgeType.elevation10000m => totalElevation >= 10000,
      BadgeType.elevation50000m => totalElevation >= 50000,
      BadgeType.singleHike500m => maxSingleElevation >= 500,
      BadgeType.singleHike1000m => maxSingleElevation >= 1000,
      BadgeType.peak1000m => hasPeakAbove(1000),
      BadgeType.peak1500m => hasPeakAbove(1500),

      // Region
      BadgeType.regions3 => stampedRegionCount >= 3,
      BadgeType.regions5 => stampedRegionCount >= 5,
      BadgeType.regions8 => stampedRegionCount >= 8,
      BadgeType.regions10 => stampedRegionCount >= 10,
      BadgeType.regions15 => stampedRegionCount >= 15,
      BadgeType.allRegions => allRegionCount > 0 && stampedRegionCount >= allRegionCount,
      BadgeType.islandMountain => hasIslandStamp,
      BadgeType.capitalArea5 => capitalAreaStamps >= 5,

      // Stamps
      BadgeType.stamps5 => totalStamped >= 5,
      BadgeType.stamps10 => totalStamped >= 10,
      BadgeType.stamps25 => totalStamped >= 25,
      BadgeType.stamps50 => totalStamped >= 50,
      BadgeType.stamps75 => totalStamped >= 75,
      BadgeType.stamps100 => totalStamped >= 100,
      BadgeType.stamps150 => totalStamped >= 150,
      BadgeType.stamps200 => totalStamped >= 200,
      BadgeType.stamps250 => totalStamped >= 250,
      BadgeType.stamps300 => totalStamped >= 300,

      // Together
      BadgeType.together1 => togetherCount >= 1,
      BadgeType.together5 => togetherCount >= 5,
      BadgeType.together10 => togetherCount >= 10,
      BadgeType.together25 => togetherCount >= 25,
      BadgeType.together50 => togetherCount >= 50,
      BadgeType.together100 => togetherCount >= 100,
      BadgeType.togetherStreak3 => togetherStreak >= 3,
      BadgeType.togetherStreak7 => togetherStreak >= 7,

      // Time
      BadgeType.earlyBird => hasHikeBefore(6),
      BadgeType.dawnHiker => hasHikeBefore(5),
      BadgeType.nightHiker => hasHikeAfter(20),
      BadgeType.longHike4h => maxDurationHours >= 4,
      BadgeType.longHike6h => maxDurationHours >= 6,
      BadgeType.longHike8h => maxDurationHours >= 8,
      BadgeType.longHike10h => maxDurationHours >= 10,
      BadgeType.quickHike1h => hasQuickHike,
      BadgeType.sunriseHike => hasSunriseHike,
      BadgeType.sunsetHike => hasSunsetHike,

      // Consistency
      BadgeType.streakWeek => maxStreak >= 7,
      BadgeType.streak2weeks => maxStreak >= 14,
      BadgeType.streak30days => maxStreak >= 30,
      BadgeType.monthlyChallenger => bestMonthlyCount >= 4,
      BadgeType.monthly8 => bestMonthlyCount >= 8,
      BadgeType.yearlyHiker => bestYearlyCount >= 12,
      BadgeType.yearly50 => bestYearlyCount >= 50,
      BadgeType.yearly100 => bestYearlyCount >= 100,
      BadgeType.allSeasons => seasonsCovered >= 4,
      BadgeType.everyMonth => monthsCovered >= 12,

      // Challenge
      BadgeType.weekendWarrior => weekendHikes >= 10,
      BadgeType.weekdayHiker => weekdayHikes >= 10,
      BadgeType.rainHiker => hasRainHike,
      BadgeType.winterHiker => hasWinterHike,
      BadgeType.summerHiker => hasSummerHike,
      BadgeType.speedDemon => hasSpeedDemon,
      BadgeType.distanceDay20km => maxSingleDayDistance >= 20,
      BadgeType.multiPeak3 => maxPeaksInDay >= 3,
      BadgeType.backToBack => hasBackToBack,
      BadgeType.centurion => uniqueMountainCount >= 100,

      // Special
      BadgeType.newYear => hasNewYearHike,
      BadgeType.springBloom => springHikeCount >= 5,
      BadgeType.summerSolstice => hasSummerSolstice,
      BadgeType.autumnLeaves => autumnHikeCount >= 5,
      BadgeType.winterSolstice => hasWinterSolstice,
      BadgeType.fullMoon => hasFullMoonHike,
      BadgeType.birthday => hasBirthdayHike,
      BadgeType.anniversary100 => hasAnniversary100,
      BadgeType.milestone50stamps => totalStamped >= 50,
      BadgeType.explorer20regions => hikedRegionCount >= 20,
      // grandMaster, legendaryHiker, ultimateChallenger 는 earnedCount에 의존하므로 외부에서 처리
      BadgeType.grandMaster => false,
      BadgeType.legendaryHiker => false,
      BadgeType.ultimateChallenger => false,
      BadgeType.perfectYear => hasPerfectYear,
    };
  }

  // ── progress ratio ────────────────────────────

  double getProgressRatio(BadgeType type, {int earnedCount = 0}) {
    double clamp(double v) => v.clamp(0.0, 1.0);

    return switch (type) {
      // Count
      BadgeType.firstHike => clamp(totalHikes / 1),
      BadgeType.hikes5 => clamp(totalHikes / 5),
      BadgeType.hikes10 => clamp(totalHikes / 10),
      BadgeType.hikes25 => clamp(totalHikes / 25),
      BadgeType.hikes50 => clamp(totalHikes / 50),
      BadgeType.hikes100 => clamp(totalHikes / 100),
      BadgeType.hikes200 => clamp(totalHikes / 200),
      BadgeType.hikes365 => clamp(totalHikes / 365),
      BadgeType.hikes500 => clamp(totalHikes / 500),
      BadgeType.hikes1000 => clamp(totalHikes / 1000),

      // Distance
      BadgeType.distance10km => clamp(totalDistanceKm / 10),
      BadgeType.distance50km => clamp(totalDistanceKm / 50),
      BadgeType.distance100km => clamp(totalDistanceKm / 100),
      BadgeType.distance200km => clamp(totalDistanceKm / 200),
      BadgeType.distance500km => clamp(totalDistanceKm / 500),
      BadgeType.distance1000km => clamp(totalDistanceKm / 1000),
      BadgeType.distance2000km => clamp(totalDistanceKm / 2000),
      BadgeType.distance3000km => clamp(totalDistanceKm / 3000),
      BadgeType.distance5000km => clamp(totalDistanceKm / 5000),
      BadgeType.distance10000km => clamp(totalDistanceKm / 10000),

      // Elevation
      BadgeType.elevation500m => clamp(totalElevation / 500),
      BadgeType.elevation1000m => clamp(totalElevation / 1000),
      BadgeType.elevation1500m => clamp(totalElevation / 1500),
      BadgeType.elevation5000m => clamp(totalElevation / 5000),
      BadgeType.elevation10000m => clamp(totalElevation / 10000),
      BadgeType.elevation50000m => clamp(totalElevation / 50000),
      BadgeType.singleHike500m => clamp(maxSingleElevation / 500),
      BadgeType.singleHike1000m => clamp(maxSingleElevation / 1000),
      BadgeType.peak1000m => hasPeakAbove(1000) ? 1.0 : 0.0,
      BadgeType.peak1500m => hasPeakAbove(1500) ? 1.0 : 0.0,

      // Region
      BadgeType.regions3 => clamp(stampedRegionCount / 3),
      BadgeType.regions5 => clamp(stampedRegionCount / 5),
      BadgeType.regions8 => clamp(stampedRegionCount / 8),
      BadgeType.regions10 => clamp(stampedRegionCount / 10),
      BadgeType.regions15 => clamp(stampedRegionCount / 15),
      BadgeType.allRegions => allRegionCount > 0 ? clamp(stampedRegionCount / allRegionCount) : 0.0,
      BadgeType.islandMountain => hasIslandStamp ? 1.0 : 0.0,
      BadgeType.capitalArea5 => clamp(capitalAreaStamps / 5),

      // Stamps
      BadgeType.stamps5 => clamp(totalStamped / 5),
      BadgeType.stamps10 => clamp(totalStamped / 10),
      BadgeType.stamps25 => clamp(totalStamped / 25),
      BadgeType.stamps50 => clamp(totalStamped / 50),
      BadgeType.stamps75 => clamp(totalStamped / 75),
      BadgeType.stamps100 => clamp(totalStamped / 100),
      BadgeType.stamps150 => clamp(totalStamped / 150),
      BadgeType.stamps200 => clamp(totalStamped / 200),
      BadgeType.stamps250 => clamp(totalStamped / 250),
      BadgeType.stamps300 => clamp(totalStamped / 300),

      // Together
      BadgeType.together1 => clamp(togetherCount / 1),
      BadgeType.together5 => clamp(togetherCount / 5),
      BadgeType.together10 => clamp(togetherCount / 10),
      BadgeType.together25 => clamp(togetherCount / 25),
      BadgeType.together50 => clamp(togetherCount / 50),
      BadgeType.together100 => clamp(togetherCount / 100),
      BadgeType.togetherStreak3 => clamp(togetherStreak / 3),
      BadgeType.togetherStreak7 => clamp(togetherStreak / 7),

      // Time
      BadgeType.earlyBird => hasHikeBefore(6) ? 1.0 : 0.0,
      BadgeType.dawnHiker => hasHikeBefore(5) ? 1.0 : 0.0,
      BadgeType.nightHiker => hasHikeAfter(20) ? 1.0 : 0.0,
      BadgeType.longHike4h => clamp(maxDurationHours / 4),
      BadgeType.longHike6h => clamp(maxDurationHours / 6),
      BadgeType.longHike8h => clamp(maxDurationHours / 8),
      BadgeType.longHike10h => clamp(maxDurationHours / 10),
      BadgeType.quickHike1h => hasQuickHike ? 1.0 : 0.0,
      BadgeType.sunriseHike => hasSunriseHike ? 1.0 : 0.0,
      BadgeType.sunsetHike => hasSunsetHike ? 1.0 : 0.0,

      // Consistency
      BadgeType.streakWeek => clamp(maxStreak / 7),
      BadgeType.streak2weeks => clamp(maxStreak / 14),
      BadgeType.streak30days => clamp(maxStreak / 30),
      BadgeType.monthlyChallenger => clamp(bestMonthlyCount / 4),
      BadgeType.monthly8 => clamp(bestMonthlyCount / 8),
      BadgeType.yearlyHiker => clamp(bestYearlyCount / 12),
      BadgeType.yearly50 => clamp(bestYearlyCount / 50),
      BadgeType.yearly100 => clamp(bestYearlyCount / 100),
      BadgeType.allSeasons => clamp(seasonsCovered / 4),
      BadgeType.everyMonth => clamp(monthsCovered / 12),

      // Challenge
      BadgeType.weekendWarrior => clamp(weekendHikes / 10),
      BadgeType.weekdayHiker => clamp(weekdayHikes / 10),
      BadgeType.rainHiker => hasRainHike ? 1.0 : 0.0,
      BadgeType.winterHiker => hasWinterHike ? 1.0 : 0.0,
      BadgeType.summerHiker => hasSummerHike ? 1.0 : 0.0,
      BadgeType.speedDemon => hasSpeedDemon ? 1.0 : 0.0,
      BadgeType.distanceDay20km => clamp(maxSingleDayDistance / 20),
      BadgeType.multiPeak3 => clamp(maxPeaksInDay / 3),
      BadgeType.backToBack => hasBackToBack ? 1.0 : 0.0,
      BadgeType.centurion => clamp(uniqueMountainCount / 100),

      // Special
      BadgeType.newYear => hasNewYearHike ? 1.0 : 0.0,
      BadgeType.springBloom => clamp(springHikeCount / 5),
      BadgeType.summerSolstice => hasSummerSolstice ? 1.0 : 0.0,
      BadgeType.autumnLeaves => clamp(autumnHikeCount / 5),
      BadgeType.winterSolstice => hasWinterSolstice ? 1.0 : 0.0,
      BadgeType.fullMoon => hasFullMoonHike ? 1.0 : 0.0,
      BadgeType.birthday => hasBirthdayHike ? 1.0 : 0.0,
      BadgeType.anniversary100 => hasAnniversary100 ? 1.0 : 0.0,
      BadgeType.milestone50stamps => clamp(totalStamped / 50),
      BadgeType.explorer20regions => clamp(hikedRegionCount / 20),
      BadgeType.grandMaster => clamp(earnedCount / 50),
      BadgeType.legendaryHiker => clamp(earnedCount / 75),
      BadgeType.ultimateChallenger => clamp(earnedCount / 90),
      BadgeType.perfectYear => hasPerfectYear ? 1.0 : 0.0,
    };
  }

  // ── progress string ───────────────────────────

  String getProgress(BadgeType type, {int earnedCount = 0}) {
    return switch (type) {
      // Count
      BadgeType.firstHike => '$totalHikes / 1',
      BadgeType.hikes5 => '$totalHikes / 5',
      BadgeType.hikes10 => '$totalHikes / 10',
      BadgeType.hikes25 => '$totalHikes / 25',
      BadgeType.hikes50 => '$totalHikes / 50',
      BadgeType.hikes100 => '$totalHikes / 100',
      BadgeType.hikes200 => '$totalHikes / 200',
      BadgeType.hikes365 => '$totalHikes / 365',
      BadgeType.hikes500 => '$totalHikes / 500',
      BadgeType.hikes1000 => '$totalHikes / 1000',

      // Distance
      BadgeType.distance10km => '${totalDistanceKm.toStringAsFixed(1)} / 10 km',
      BadgeType.distance50km => '${totalDistanceKm.toStringAsFixed(1)} / 50 km',
      BadgeType.distance100km => '${totalDistanceKm.toStringAsFixed(1)} / 100 km',
      BadgeType.distance200km => '${totalDistanceKm.toStringAsFixed(1)} / 200 km',
      BadgeType.distance500km => '${totalDistanceKm.toStringAsFixed(1)} / 500 km',
      BadgeType.distance1000km => '${totalDistanceKm.toStringAsFixed(1)} / 1000 km',
      BadgeType.distance2000km => '${totalDistanceKm.toStringAsFixed(1)} / 2000 km',
      BadgeType.distance3000km => '${totalDistanceKm.toStringAsFixed(1)} / 3000 km',
      BadgeType.distance5000km => '${totalDistanceKm.toStringAsFixed(1)} / 5000 km',
      BadgeType.distance10000km => '${totalDistanceKm.toStringAsFixed(1)} / 10000 km',

      // Elevation
      BadgeType.elevation500m => '$totalElevation / 500 m',
      BadgeType.elevation1000m => '$totalElevation / 1000 m',
      BadgeType.elevation1500m => '$totalElevation / 1500 m',
      BadgeType.elevation5000m => '$totalElevation / 5000 m',
      BadgeType.elevation10000m => '$totalElevation / 10000 m',
      BadgeType.elevation50000m => '$totalElevation / 50000 m',
      BadgeType.singleHike500m => '$maxSingleElevation / 500 m',
      BadgeType.singleHike1000m => '$maxSingleElevation / 1000 m',
      BadgeType.peak1000m || BadgeType.peak1500m => hasPeakAbove(type == BadgeType.peak1000m ? 1000 : 1500) ? '달성!' : '미달성',

      // Region
      BadgeType.regions3 => '$stampedRegionCount / 3',
      BadgeType.regions5 => '$stampedRegionCount / 5',
      BadgeType.regions8 => '$stampedRegionCount / 8',
      BadgeType.regions10 => '$stampedRegionCount / 10',
      BadgeType.regions15 => '$stampedRegionCount / 15',
      BadgeType.allRegions => '$stampedRegionCount / $allRegionCount',
      BadgeType.islandMountain => hasIslandStamp ? '달성!' : '미달성',
      BadgeType.capitalArea5 => '$capitalAreaStamps / 5',

      // Stamps
      BadgeType.stamps5 => '$totalStamped / 5',
      BadgeType.stamps10 => '$totalStamped / 10',
      BadgeType.stamps25 => '$totalStamped / 25',
      BadgeType.stamps50 => '$totalStamped / 50',
      BadgeType.stamps75 => '$totalStamped / 75',
      BadgeType.stamps100 => '$totalStamped / 100',
      BadgeType.stamps150 => '$totalStamped / 150',
      BadgeType.stamps200 => '$totalStamped / 200',
      BadgeType.stamps250 => '$totalStamped / 250',
      BadgeType.stamps300 => '$totalStamped / 300',

      // Together
      BadgeType.together1 => '$togetherCount / 1',
      BadgeType.together5 => '$togetherCount / 5',
      BadgeType.together10 => '$togetherCount / 10',
      BadgeType.together25 => '$togetherCount / 25',
      BadgeType.together50 => '$togetherCount / 50',
      BadgeType.together100 => '$togetherCount / 100',
      BadgeType.togetherStreak3 => '$togetherStreak / 3',
      BadgeType.togetherStreak7 => '$togetherStreak / 7',

      // Time
      BadgeType.earlyBird => hasHikeBefore(6) ? '달성!' : '미달성',
      BadgeType.dawnHiker => hasHikeBefore(5) ? '달성!' : '미달성',
      BadgeType.nightHiker => hasHikeAfter(20) ? '달성!' : '미달성',
      BadgeType.longHike4h => '${maxDurationHours.toStringAsFixed(1)} / 4 h',
      BadgeType.longHike6h => '${maxDurationHours.toStringAsFixed(1)} / 6 h',
      BadgeType.longHike8h => '${maxDurationHours.toStringAsFixed(1)} / 8 h',
      BadgeType.longHike10h => '${maxDurationHours.toStringAsFixed(1)} / 10 h',
      BadgeType.quickHike1h => hasQuickHike ? '달성!' : '미달성',
      BadgeType.sunriseHike => hasSunriseHike ? '달성!' : '미달성',
      BadgeType.sunsetHike => hasSunsetHike ? '달성!' : '미달성',

      // Consistency
      BadgeType.streakWeek => '$maxStreak / 7일',
      BadgeType.streak2weeks => '$maxStreak / 14일',
      BadgeType.streak30days => '$maxStreak / 30일',
      BadgeType.monthlyChallenger => '$bestMonthlyCount / 4',
      BadgeType.monthly8 => '$bestMonthlyCount / 8',
      BadgeType.yearlyHiker => '$bestYearlyCount / 12',
      BadgeType.yearly50 => '$bestYearlyCount / 50',
      BadgeType.yearly100 => '$bestYearlyCount / 100',
      BadgeType.allSeasons => '$seasonsCovered / 4',
      BadgeType.everyMonth => '$monthsCovered / 12',

      // Challenge
      BadgeType.weekendWarrior => '$weekendHikes / 10',
      BadgeType.weekdayHiker => '$weekdayHikes / 10',
      BadgeType.rainHiker => hasRainHike ? '달성!' : '미달성',
      BadgeType.winterHiker => hasWinterHike ? '달성!' : '미달성',
      BadgeType.summerHiker => hasSummerHike ? '달성!' : '미달성',
      BadgeType.speedDemon => hasSpeedDemon ? '달성!' : '미달성',
      BadgeType.distanceDay20km => '${maxSingleDayDistance.toStringAsFixed(1)} / 20 km',
      BadgeType.multiPeak3 => '$maxPeaksInDay / 3',
      BadgeType.backToBack => hasBackToBack ? '달성!' : '미달성',
      BadgeType.centurion => '$uniqueMountainCount / 100',

      // Special
      BadgeType.newYear => hasNewYearHike ? '달성!' : '미달성',
      BadgeType.springBloom => '$springHikeCount / 5',
      BadgeType.summerSolstice => hasSummerSolstice ? '달성!' : '미달성',
      BadgeType.autumnLeaves => '$autumnHikeCount / 5',
      BadgeType.winterSolstice => hasWinterSolstice ? '달성!' : '미달성',
      BadgeType.fullMoon => hasFullMoonHike ? '달성!' : '미달성',
      BadgeType.birthday => hasBirthdayHike ? '달성!' : '미달성',
      BadgeType.anniversary100 => hasAnniversary100 ? '달성!' : '미달성',
      BadgeType.milestone50stamps => '$totalStamped / 50',
      BadgeType.explorer20regions => '$hikedRegionCount / 20',
      BadgeType.grandMaster => '$earnedCount / 50',
      BadgeType.legendaryHiker => '$earnedCount / 75',
      BadgeType.ultimateChallenger => '$earnedCount / 90',
      BadgeType.perfectYear => hasPerfectYear ? '달성!' : '미달성',
    };
  }

  // ── computed helpers (public for testability) ──

  int get totalHikes => records.length;

  double get totalDistanceKm {
    double sum = 0;
    for (final r in records) {
      sum += r.distanceKm;
    }
    return sum;
  }

  int get totalElevation {
    int sum = 0;
    for (final r in records) {
      sum += r.elevationGain ?? 0;
    }
    return sum;
  }

  int get maxSingleElevation {
    int best = 0;
    for (final r in records) {
      final e = r.elevationGain ?? 0;
      if (e > best) best = e;
    }
    return best;
  }

  bool hasPeakAbove(int h) {
    for (final s in stamps) {
      if (s.isStamped && s.height >= h) return true;
    }
    return false;
  }

  int get totalStamped => stamps.where((s) => s.isStamped).length;
  int get togetherCount => stamps.where((s) => s.isTogetherStamped).length;

  int get stampedRegionCount {
    final regions = <String>{};
    for (final s in stamps) {
      if (s.isStamped) regions.add(s.region);
    }
    return regions.length;
  }

  int get allRegionCount {
    final regions = <String>{};
    for (final s in stamps) {
      regions.add(s.region);
    }
    return regions.length;
  }

  bool get hasIslandStamp {
    for (final s in stamps) {
      if (s.isStamped && (s.region == '제주' || s.region == '제주도')) return true;
    }
    return false;
  }

  int get capitalAreaStamps {
    int count = 0;
    for (final s in stamps) {
      if (s.isStamped && (s.region == '서울' || s.region == '경기')) count++;
    }
    return count;
  }

  int get togetherStreak {
    final dated = stamps
        .where((s) => s.isTogetherStamped && s.stampDate != null)
        .toList();
    if (dated.isEmpty) return 0;

    dated.sort((a, b) => (a.stampDate ?? '').compareTo(b.stampDate ?? ''));

    int best = 1;
    int current = 1;
    for (int i = 1; i < dated.length; i++) {
      final prevDate = _parseStampDate(dated[i - 1].stampDate);
      final currDate = _parseStampDate(dated[i].stampDate);
      if (prevDate != null && currDate != null) {
        final diff = currDate.difference(prevDate).inDays;
        if (diff <= 7) {
          current++;
        } else {
          current = 1;
        }
      } else {
        current = 1;
      }
      if (current > best) best = current;
    }
    return best;
  }

  // ── Time helpers ──────────────────────────────

  bool hasHikeBefore(int hour) {
    for (final r in records) {
      final st = r.startTime;
      if (st != null && st.hour < hour) return true;
    }
    return false;
  }

  bool hasHikeAfter(int hour) {
    for (final r in records) {
      final st = r.startTime;
      if (st != null && st.hour >= hour) return true;
    }
    return false;
  }

  double get maxDurationHours {
    double best = 0;
    for (final r in records) {
      final h = _parseDurationHours(r);
      if (h > best) best = h;
    }
    return best;
  }

  bool get hasQuickHike {
    for (final r in records) {
      final h = _parseDurationHours(r);
      if (h > 0 && h < 1) return true;
    }
    return false;
  }

  bool get hasSunriseHike {
    for (final r in records) {
      final st = r.startTime;
      if (st != null && st.hour >= 5 && st.hour < 7) return true;
    }
    return false;
  }

  bool get hasSunsetHike {
    for (final r in records) {
      final st = r.startTime;
      if (st != null && st.hour >= 17 && st.hour < 19) return true;
    }
    return false;
  }

  // ── Consistency helpers ───────────────────────

  int get maxStreak {
    final days = _hikeDays;
    if (days.isEmpty) return 0;

    final sorted = days.toList()..sort();
    int best = 1;
    int current = 1;
    for (int i = 1; i < sorted.length; i++) {
      if (sorted[i].difference(sorted[i - 1]).inDays == 1) {
        current++;
      } else {
        current = 1;
      }
      if (current > best) best = current;
    }
    return best;
  }

  int get bestMonthlyCount {
    final counts = <String, int>{};
    for (final r in records) {
      final d = r.startTime ?? _parseDateField(r.date);
      if (d == null) continue;
      final key = '${d.year}-${d.month}';
      counts[key] = (counts[key] ?? 0) + 1;
    }
    int best = 0;
    for (final v in counts.values) {
      if (v > best) best = v;
    }
    return best;
  }

  int get bestYearlyCount {
    final counts = <int, int>{};
    for (final r in records) {
      final d = r.startTime ?? _parseDateField(r.date);
      if (d == null) continue;
      counts[d.year] = (counts[d.year] ?? 0) + 1;
    }
    int best = 0;
    for (final v in counts.values) {
      if (v > best) best = v;
    }
    return best;
  }

  int get seasonsCovered {
    final seasons = <int>{};
    for (final r in records) {
      final d = r.startTime ?? _parseDateField(r.date);
      if (d == null) continue;
      final m = d.month;
      if (m >= 3 && m <= 5) {
        seasons.add(0);
      } else if (m >= 6 && m <= 8) {
        seasons.add(1);
      } else if (m >= 9 && m <= 11) {
        seasons.add(2);
      } else {
        seasons.add(3);
      }
    }
    return seasons.length;
  }

  int get monthsCovered {
    final months = <int>{};
    for (final r in records) {
      final d = r.startTime ?? _parseDateField(r.date);
      if (d == null) continue;
      months.add(d.month);
    }
    return months.length;
  }

  // ── Challenge helpers ─────────────────────────

  int get weekendHikes {
    int count = 0;
    for (final r in records) {
      final d = r.startTime ?? _parseDateField(r.date);
      if (d == null) continue;
      if (d.weekday == DateTime.saturday || d.weekday == DateTime.sunday) count++;
    }
    return count;
  }

  int get weekdayHikes {
    int count = 0;
    for (final r in records) {
      final d = r.startTime ?? _parseDateField(r.date);
      if (d == null) continue;
      if (d.weekday >= DateTime.monday && d.weekday <= DateTime.friday) count++;
    }
    return count;
  }

  /// 장마철(6~7월) 등산 여부 — hasSummerHike(6~8월)와 구별
  bool get hasRainHike {
    for (final r in records) {
      final d = r.startTime ?? _parseDateField(r.date);
      if (d != null && d.month >= 6 && d.month <= 7) return true;
    }
    return false;
  }

  bool get hasWinterHike {
    for (final r in records) {
      final d = r.startTime ?? _parseDateField(r.date);
      if (d != null && (d.month == 12 || d.month == 1 || d.month == 2)) return true;
    }
    return false;
  }

  bool get hasSummerHike {
    for (final r in records) {
      final d = r.startTime ?? _parseDateField(r.date);
      if (d != null && d.month >= 6 && d.month <= 8) return true;
    }
    return false;
  }

  bool get hasSpeedDemon {
    for (final r in records) {
      if (r.distanceKm >= 5 && _parseDurationHours(r) > 0 && _parseDurationHours(r) < 2) {
        return true;
      }
    }
    return false;
  }

  double get maxSingleDayDistance {
    final dayDist = <String, double>{};
    for (final r in records) {
      final d = r.startTime ?? _parseDateField(r.date);
      if (d == null) continue;
      final key = '${d.year}-${d.month}-${d.day}';
      dayDist[key] = (dayDist[key] ?? 0) + r.distanceKm;
    }
    double best = 0;
    for (final v in dayDist.values) {
      if (v > best) best = v;
    }
    return best;
  }

  int get maxPeaksInDay {
    final dayPeaks = <String, Set<String>>{};
    for (final r in records) {
      final d = r.startTime ?? _parseDateField(r.date);
      if (d == null) continue;
      final key = '${d.year}-${d.month}-${d.day}';
      dayPeaks.putIfAbsent(key, () => <String>{}).add(r.mountain);
    }
    int best = 0;
    for (final v in dayPeaks.values) {
      if (v.length > best) best = v.length;
    }
    return best;
  }

  bool get hasBackToBack {
    final dayMountains = <DateTime, Set<String>>{};
    for (final r in records) {
      final d = r.startTime ?? _parseDateField(r.date);
      if (d == null) continue;
      final key = DateTime(d.year, d.month, d.day);
      dayMountains.putIfAbsent(key, () => <String>{}).add(r.mountain);
    }
    final sortedDays = dayMountains.keys.toList()..sort();
    for (int i = 1; i < sortedDays.length; i++) {
      if (sortedDays[i].difference(sortedDays[i - 1]).inDays == 1) {
        final prev = dayMountains[sortedDays[i - 1]]!;
        final curr = dayMountains[sortedDays[i]]!;
        if (!prev.containsAll(curr) || !curr.containsAll(prev)) return true;
      }
    }
    return false;
  }

  int get uniqueMountainCount {
    final names = <String>{};
    for (final r in records) {
      names.add(r.mountain);
    }
    return names.length;
  }

  // ── Special helpers ───────────────────────────

  bool get hasNewYearHike {
    for (final r in records) {
      final d = r.startTime ?? _parseDateField(r.date);
      if (d != null && d.month == 1 && d.day == 1) return true;
    }
    return false;
  }

  int get springHikeCount {
    int count = 0;
    for (final r in records) {
      final d = r.startTime ?? _parseDateField(r.date);
      if (d != null && d.month >= 3 && d.month <= 5) count++;
    }
    return count;
  }

  bool get hasSummerSolstice {
    for (final r in records) {
      final d = r.startTime ?? _parseDateField(r.date);
      if (d != null && d.month == 6 && d.day >= 20 && d.day <= 22) return true;
    }
    return false;
  }

  int get autumnHikeCount {
    int count = 0;
    for (final r in records) {
      final d = r.startTime ?? _parseDateField(r.date);
      if (d != null && d.month >= 9 && d.month <= 11) count++;
    }
    return count;
  }

  bool get hasWinterSolstice {
    for (final r in records) {
      final d = r.startTime ?? _parseDateField(r.date);
      if (d != null && d.month == 12 && d.day >= 20 && d.day <= 22) return true;
    }
    return false;
  }

  bool get hasFullMoonHike {
    for (final r in records) {
      final d = r.startTime ?? _parseDateField(r.date);
      if (d != null && d.day == 15) return true;
    }
    return false;
  }

  bool get hasBirthdayHike {
    if (birthday == null) return false;
    for (final r in records) {
      final d = r.startTime ?? _parseDateField(r.date);
      if (d != null && d.month == birthday!.month && d.day == birthday!.day) return true;
    }
    return false;
  }

  bool get hasAnniversary100 {
    if (joinDate == null) return false;
    final target = joinDate!.add(const Duration(days: 100));
    for (final r in records) {
      final d = r.startTime ?? _parseDateField(r.date);
      if (d != null && d.year == target.year && d.month == target.month && d.day == target.day) {
        return true;
      }
    }
    return false;
  }

  int get hikedRegionCount {
    final regions = <String>{};
    final stampMap = <String, String>{};
    for (final s in stamps) {
      stampMap[s.name] = s.region;
    }
    for (final r in records) {
      final region = stampMap[r.mountain];
      if (region != null) regions.add(region);
    }
    return regions.length;
  }

  bool get hasPerfectYear {
    final yearMonths = <int, Set<int>>{};
    final yearCount = <int, int>{};
    for (final r in records) {
      final d = r.startTime ?? _parseDateField(r.date);
      if (d == null) continue;
      yearMonths.putIfAbsent(d.year, () => <int>{}).add(d.month);
      yearCount[d.year] = (yearCount[d.year] ?? 0) + 1;
    }
    for (final year in yearMonths.keys) {
      if ((yearCount[year] ?? 0) >= 50 && yearMonths[year]!.length >= 12) {
        return true;
      }
    }
    return false;
  }

  // ── private parsing helpers ───────────────────

  Set<DateTime> get _hikeDays {
    final days = <DateTime>{};
    for (final r in records) {
      final d = r.startTime ?? _parseDateField(r.date);
      if (d != null) days.add(DateTime(d.year, d.month, d.day));
    }
    return days;
  }

  DateTime? _parseDateField(String date) {
    // "2025.01.20" 또는 "2025-01-20" 형식
    try {
      final cleaned = date.replaceAll('.', '-');
      final parsed = DateTime.tryParse(cleaned);
      if (parsed != null) return parsed;
    } catch (_) {}

    // "1월 20일" 형식 — 연도 정보가 없으므로 현재 연도 사용하되 미래 날짜면 작년으로
    final m = RegExp(r'(\d+)월\s*(\d+)일').firstMatch(date);
    if (m != null) {
      final month = int.parse(m.group(1)!);
      final day = int.parse(m.group(2)!);
      if (month < 1 || month > 12 || day < 1 || day > 31) return null;
      final now = DateTime.now();
      var result = DateTime(now.year, month, day);
      if (result.isAfter(now)) {
        result = DateTime(now.year - 1, month, day);
      }
      return result;
    }
    return null;
  }

  DateTime? _parseStampDate(String? s) {
    if (s == null) return null;
    try {
      final parts = s.split('.');
      if (parts.length == 3) {
        return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      }
    } catch (_) {}
    return null;
  }

  double _parseDurationHours(HikingRecord r) {
    if (r.startTime != null && r.endTime != null) {
      return r.endTime!.difference(r.startTime!).inMinutes / 60.0;
    }
    final d = r.duration;
    double hours = 0;
    final hMatch = RegExp(r'(\d+)\s*h').firstMatch(d);
    final mMatch = RegExp(r'(\d+)\s*m').firstMatch(d);
    if (hMatch != null) hours += int.parse(hMatch.group(1)!);
    if (mMatch != null) hours += int.parse(mMatch.group(1)!) / 60.0;
    return hours;
  }
}
