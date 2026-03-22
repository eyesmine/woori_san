import 'package:flutter/material.dart';
import '../models/badge.dart';
import '../models/hiking_record.dart';
import '../models/stamp.dart';

/// Provider that evaluates badge/achievement progress.
///
/// Depends on hiking records and stamps — call [evaluate] whenever either
/// data set changes.
class BadgeProvider extends ChangeNotifier {
  /// Set of badge types that are currently earned.
  final Set<BadgeType> _earned = {};

  /// Cached helper data derived from records/stamps.
  List<HikingRecord> _records = [];
  List<Stamp> _stamps = [];
  DateTime? _joinDate;
  DateTime? _birthday;

  // ── public API ──────────────────────────────────

  Set<BadgeType> get earned => _earned;

  bool isEarned(BadgeType type) => _earned.contains(type);

  int get earnedCount => _earned.length;

  /// Re-evaluate all 100 badges against latest data.
  void evaluate({
    required List<HikingRecord> records,
    required List<Stamp> stamps,
    DateTime? joinDate,
    DateTime? birthday,
  }) {
    _records = records;
    _stamps = stamps;
    _joinDate = joinDate;
    _birthday = birthday;

    _earned.clear();
    for (final badge in allBadgeDefinitions) {
      if (_check(badge.type)) {
        _earned.add(badge.type);
      }
    }
    notifyListeners();
  }

  /// Convenience: refresh with stored data
  void refresh() {
    if (_records.isNotEmpty || _stamps.isNotEmpty) {
      evaluate(records: _records, stamps: _stamps, joinDate: _joinDate, birthday: _birthday);
    }
  }

  /// Next badge closest to completion (highest progress ratio among unearned)
  HikingBadge? get nextBadge {
    HikingBadge? best;
    double bestRatio = -1;
    for (final b in allBadgeDefinitions) {
      if (!_earned.contains(b.type)) {
        final r = getProgressRatio(b.type);
        if (r > bestRatio) {
          bestRatio = r;
          best = b;
        }
      }
    }
    return best;
  }

  /// Get newly earned badges (compare with last known count stored externally)
  List<HikingBadge> getNewlyEarnedBadges() {
    // Returns all earned badges — caller should track what was already shown
    return allBadgeDefinitions.where((b) => _earned.contains(b.type)).toList();
  }

  /// Progress ratio 0.0 – 1.0 for progress bars.
  double getProgressRatio(BadgeType type) {
    if (_earned.contains(type)) return 1.0;
    final p = getProgress(type);
    final match = RegExp(r'(\d+)\s*/\s*(\d+)').firstMatch(p);
    if (match != null) {
      final current = int.parse(match.group(1)!);
      final target = int.parse(match.group(2)!);
      if (target == 0) return 0;
      return (current / target).clamp(0.0, 1.0);
    }
    return 0;
  }

  // ── progress strings ───────────────────────────

  /// Human-readable progress string (e.g. "5 / 10").
  String getProgress(BadgeType type) {
    switch (type) {
      // Count
      case BadgeType.firstHike:
        return '$_totalHikes / 1';
      case BadgeType.hikes5:
        return '$_totalHikes / 5';
      case BadgeType.hikes10:
        return '$_totalHikes / 10';
      case BadgeType.hikes25:
        return '$_totalHikes / 25';
      case BadgeType.hikes50:
        return '$_totalHikes / 50';
      case BadgeType.hikes100:
        return '$_totalHikes / 100';
      case BadgeType.hikes200:
        return '$_totalHikes / 200';
      case BadgeType.hikes365:
        return '$_totalHikes / 365';
      case BadgeType.hikes500:
        return '$_totalHikes / 500';
      case BadgeType.hikes1000:
        return '$_totalHikes / 1000';

      // Distance
      case BadgeType.distance10km:
        return '${_totalDistanceKm.toStringAsFixed(1)} / 10 km';
      case BadgeType.distance50km:
        return '${_totalDistanceKm.toStringAsFixed(1)} / 50 km';
      case BadgeType.distance100km:
        return '${_totalDistanceKm.toStringAsFixed(1)} / 100 km';
      case BadgeType.distance200km:
        return '${_totalDistanceKm.toStringAsFixed(1)} / 200 km';
      case BadgeType.distance500km:
        return '${_totalDistanceKm.toStringAsFixed(1)} / 500 km';
      case BadgeType.distance1000km:
        return '${_totalDistanceKm.toStringAsFixed(1)} / 1000 km';
      case BadgeType.distance2000km:
        return '${_totalDistanceKm.toStringAsFixed(1)} / 2000 km';
      case BadgeType.distance3000km:
        return '${_totalDistanceKm.toStringAsFixed(1)} / 3000 km';
      case BadgeType.distance5000km:
        return '${_totalDistanceKm.toStringAsFixed(1)} / 5000 km';
      case BadgeType.distance10000km:
        return '${_totalDistanceKm.toStringAsFixed(1)} / 10000 km';

      // Elevation
      case BadgeType.elevation500m:
        return '$_totalElevation / 500 m';
      case BadgeType.elevation1000m:
        return '$_totalElevation / 1000 m';
      case BadgeType.elevation1500m:
        return '$_totalElevation / 1500 m';
      case BadgeType.elevation5000m:
        return '$_totalElevation / 5000 m';
      case BadgeType.elevation10000m:
        return '$_totalElevation / 10000 m';
      case BadgeType.elevation50000m:
        return '$_totalElevation / 50000 m';
      case BadgeType.singleHike500m:
        return '$_maxSingleElevation / 500 m';
      case BadgeType.singleHike1000m:
        return '$_maxSingleElevation / 1000 m';
      case BadgeType.peak1000m:
        return _hasPeakAbove(1000) ? '달성!' : '미달성';
      case BadgeType.peak1500m:
        return _hasPeakAbove(1500) ? '달성!' : '미달성';

      // Region
      case BadgeType.regions3:
        return '$_stampedRegionCount / 3';
      case BadgeType.regions5:
        return '$_stampedRegionCount / 5';
      case BadgeType.regions8:
        return '$_stampedRegionCount / 8';
      case BadgeType.regions10:
        return '$_stampedRegionCount / 10';
      case BadgeType.regions15:
        return '$_stampedRegionCount / 15';
      case BadgeType.allRegions:
        return '$_stampedRegionCount / $_allRegionCount';
      case BadgeType.islandMountain:
        return _hasIslandStamp ? '달성!' : '미달성';
      case BadgeType.capitalArea5:
        return '$_capitalAreaStamps / 5';

      // Stamps
      case BadgeType.stamps5:
        return '$_totalStamped / 5';
      case BadgeType.stamps10:
        return '$_totalStamped / 10';
      case BadgeType.stamps25:
        return '$_totalStamped / 25';
      case BadgeType.stamps50:
        return '$_totalStamped / 50';
      case BadgeType.stamps75:
        return '$_totalStamped / 75';
      case BadgeType.stamps100:
        return '$_totalStamped / 100';
      case BadgeType.stamps150:
        return '$_totalStamped / 150';
      case BadgeType.stamps200:
        return '$_totalStamped / 200';
      case BadgeType.stamps250:
        return '$_totalStamped / 250';
      case BadgeType.stamps300:
        return '$_totalStamped / 300';

      // Together
      case BadgeType.together1:
        return '$_togetherCount / 1';
      case BadgeType.together5:
        return '$_togetherCount / 5';
      case BadgeType.together10:
        return '$_togetherCount / 10';
      case BadgeType.together25:
        return '$_togetherCount / 25';
      case BadgeType.together50:
        return '$_togetherCount / 50';
      case BadgeType.together100:
        return '$_togetherCount / 100';
      case BadgeType.togetherStreak3:
        return '$_togetherStreak / 3';
      case BadgeType.togetherStreak7:
        return '$_togetherStreak / 7';

      // Time
      case BadgeType.earlyBird:
        return _hasHikeBefore(6) ? '달성!' : '미달성';
      case BadgeType.dawnHiker:
        return _hasHikeBefore(5) ? '달성!' : '미달성';
      case BadgeType.nightHiker:
        return _hasHikeAfter(20) ? '달성!' : '미달성';
      case BadgeType.longHike4h:
        return '${_maxDurationHours.toStringAsFixed(1)} / 4 h';
      case BadgeType.longHike6h:
        return '${_maxDurationHours.toStringAsFixed(1)} / 6 h';
      case BadgeType.longHike8h:
        return '${_maxDurationHours.toStringAsFixed(1)} / 8 h';
      case BadgeType.longHike10h:
        return '${_maxDurationHours.toStringAsFixed(1)} / 10 h';
      case BadgeType.quickHike1h:
        return _hasQuickHike ? '달성!' : '미달성';
      case BadgeType.sunriseHike:
        return _hasSunriseHike ? '달성!' : '미달성';
      case BadgeType.sunsetHike:
        return _hasSunsetHike ? '달성!' : '미달성';

      // Consistency
      case BadgeType.streakWeek:
        return '$_maxStreak / 7일';
      case BadgeType.streak2weeks:
        return '$_maxStreak / 14일';
      case BadgeType.streak30days:
        return '$_maxStreak / 30일';
      case BadgeType.monthlyChallenger:
        return '$_bestMonthlyCount / 4';
      case BadgeType.monthly8:
        return '$_bestMonthlyCount / 8';
      case BadgeType.yearlyHiker:
        return '$_bestYearlyCount / 12';
      case BadgeType.yearly50:
        return '$_bestYearlyCount / 50';
      case BadgeType.yearly100:
        return '$_bestYearlyCount / 100';
      case BadgeType.allSeasons:
        return '$_seasonsCovered / 4';
      case BadgeType.everyMonth:
        return '$_monthsCovered / 12';

      // Challenge
      case BadgeType.weekendWarrior:
        return '$_weekendHikes / 10';
      case BadgeType.weekdayHiker:
        return '$_weekdayHikes / 10';
      case BadgeType.rainHiker:
        return _hasRainHike ? '달성!' : '미달성';
      case BadgeType.winterHiker:
        return _hasWinterHike ? '달성!' : '미달성';
      case BadgeType.summerHiker:
        return _hasSummerHike ? '달성!' : '미달성';
      case BadgeType.speedDemon:
        return _hasSpeedDemon ? '달성!' : '미달성';
      case BadgeType.distanceDay20km:
        return '${_maxSingleDayDistance.toStringAsFixed(1)} / 20 km';
      case BadgeType.multiPeak3:
        return '$_maxPeaksInDay / 3';
      case BadgeType.backToBack:
        return _hasBackToBack ? '달성!' : '미달성';
      case BadgeType.centurion:
        return '$_uniqueMountainCount / 100';

      // Special
      case BadgeType.newYear:
        return _hasNewYearHike ? '달성!' : '미달성';
      case BadgeType.springBloom:
        return '$_springHikeCount / 5';
      case BadgeType.summerSolstice:
        return _hasSummerSolstice ? '달성!' : '미달성';
      case BadgeType.autumnLeaves:
        return '$_autumnHikeCount / 5';
      case BadgeType.winterSolstice:
        return _hasWinterSolstice ? '달성!' : '미달성';
      case BadgeType.fullMoon:
        return _hasFullMoonHike ? '달성!' : '미달성';
      case BadgeType.birthday:
        return _hasBirthdayHike ? '달성!' : '미달성';
      case BadgeType.anniversary100:
        return _hasAnniversary100 ? '달성!' : '미달성';
      case BadgeType.milestone50stamps:
        return '$_totalStamped / 50';
      case BadgeType.explorer20regions:
        return '$_hikedRegionCount / 20';
      case BadgeType.grandMaster:
        return '$earnedCount / 50';
      case BadgeType.legendaryHiker:
        return '$earnedCount / 75';
      case BadgeType.ultimateChallenger:
        return '$earnedCount / 90';
      case BadgeType.perfectYear:
        return _hasPerfectYear ? '달성!' : '미달성';
    }
  }

  /// Progress ratio 0.0 – 1.0 for progress bar UI.
  double getProgressRatio(BadgeType type) {
    double clamp(double v) => v.clamp(0.0, 1.0);

    switch (type) {
      // Count
      case BadgeType.firstHike:
        return clamp(_totalHikes / 1);
      case BadgeType.hikes5:
        return clamp(_totalHikes / 5);
      case BadgeType.hikes10:
        return clamp(_totalHikes / 10);
      case BadgeType.hikes25:
        return clamp(_totalHikes / 25);
      case BadgeType.hikes50:
        return clamp(_totalHikes / 50);
      case BadgeType.hikes100:
        return clamp(_totalHikes / 100);
      case BadgeType.hikes200:
        return clamp(_totalHikes / 200);
      case BadgeType.hikes365:
        return clamp(_totalHikes / 365);
      case BadgeType.hikes500:
        return clamp(_totalHikes / 500);
      case BadgeType.hikes1000:
        return clamp(_totalHikes / 1000);

      // Distance
      case BadgeType.distance10km:
        return clamp(_totalDistanceKm / 10);
      case BadgeType.distance50km:
        return clamp(_totalDistanceKm / 50);
      case BadgeType.distance100km:
        return clamp(_totalDistanceKm / 100);
      case BadgeType.distance200km:
        return clamp(_totalDistanceKm / 200);
      case BadgeType.distance500km:
        return clamp(_totalDistanceKm / 500);
      case BadgeType.distance1000km:
        return clamp(_totalDistanceKm / 1000);
      case BadgeType.distance2000km:
        return clamp(_totalDistanceKm / 2000);
      case BadgeType.distance3000km:
        return clamp(_totalDistanceKm / 3000);
      case BadgeType.distance5000km:
        return clamp(_totalDistanceKm / 5000);
      case BadgeType.distance10000km:
        return clamp(_totalDistanceKm / 10000);

      // Elevation
      case BadgeType.elevation500m:
        return clamp(_totalElevation / 500);
      case BadgeType.elevation1000m:
        return clamp(_totalElevation / 1000);
      case BadgeType.elevation1500m:
        return clamp(_totalElevation / 1500);
      case BadgeType.elevation5000m:
        return clamp(_totalElevation / 5000);
      case BadgeType.elevation10000m:
        return clamp(_totalElevation / 10000);
      case BadgeType.elevation50000m:
        return clamp(_totalElevation / 50000);
      case BadgeType.singleHike500m:
        return clamp(_maxSingleElevation / 500);
      case BadgeType.singleHike1000m:
        return clamp(_maxSingleElevation / 1000);
      case BadgeType.peak1000m:
        return _hasPeakAbove(1000) ? 1.0 : 0.0;
      case BadgeType.peak1500m:
        return _hasPeakAbove(1500) ? 1.0 : 0.0;

      // Region
      case BadgeType.regions3:
        return clamp(_stampedRegionCount / 3);
      case BadgeType.regions5:
        return clamp(_stampedRegionCount / 5);
      case BadgeType.regions8:
        return clamp(_stampedRegionCount / 8);
      case BadgeType.regions10:
        return clamp(_stampedRegionCount / 10);
      case BadgeType.regions15:
        return clamp(_stampedRegionCount / 15);
      case BadgeType.allRegions:
        return _allRegionCount > 0 ? clamp(_stampedRegionCount / _allRegionCount) : 0.0;
      case BadgeType.islandMountain:
        return _hasIslandStamp ? 1.0 : 0.0;
      case BadgeType.capitalArea5:
        return clamp(_capitalAreaStamps / 5);

      // Stamps
      case BadgeType.stamps5:
        return clamp(_totalStamped / 5);
      case BadgeType.stamps10:
        return clamp(_totalStamped / 10);
      case BadgeType.stamps25:
        return clamp(_totalStamped / 25);
      case BadgeType.stamps50:
        return clamp(_totalStamped / 50);
      case BadgeType.stamps75:
        return clamp(_totalStamped / 75);
      case BadgeType.stamps100:
        return clamp(_totalStamped / 100);
      case BadgeType.stamps150:
        return clamp(_totalStamped / 150);
      case BadgeType.stamps200:
        return clamp(_totalStamped / 200);
      case BadgeType.stamps250:
        return clamp(_totalStamped / 250);
      case BadgeType.stamps300:
        return clamp(_totalStamped / 300);

      // Together
      case BadgeType.together1:
        return clamp(_togetherCount / 1);
      case BadgeType.together5:
        return clamp(_togetherCount / 5);
      case BadgeType.together10:
        return clamp(_togetherCount / 10);
      case BadgeType.together25:
        return clamp(_togetherCount / 25);
      case BadgeType.together50:
        return clamp(_togetherCount / 50);
      case BadgeType.together100:
        return clamp(_togetherCount / 100);
      case BadgeType.togetherStreak3:
        return clamp(_togetherStreak / 3);
      case BadgeType.togetherStreak7:
        return clamp(_togetherStreak / 7);

      // Time
      case BadgeType.earlyBird:
        return _hasHikeBefore(6) ? 1.0 : 0.0;
      case BadgeType.dawnHiker:
        return _hasHikeBefore(5) ? 1.0 : 0.0;
      case BadgeType.nightHiker:
        return _hasHikeAfter(20) ? 1.0 : 0.0;
      case BadgeType.longHike4h:
        return clamp(_maxDurationHours / 4);
      case BadgeType.longHike6h:
        return clamp(_maxDurationHours / 6);
      case BadgeType.longHike8h:
        return clamp(_maxDurationHours / 8);
      case BadgeType.longHike10h:
        return clamp(_maxDurationHours / 10);
      case BadgeType.quickHike1h:
        return _hasQuickHike ? 1.0 : 0.0;
      case BadgeType.sunriseHike:
        return _hasSunriseHike ? 1.0 : 0.0;
      case BadgeType.sunsetHike:
        return _hasSunsetHike ? 1.0 : 0.0;

      // Consistency
      case BadgeType.streakWeek:
        return clamp(_maxStreak / 7);
      case BadgeType.streak2weeks:
        return clamp(_maxStreak / 14);
      case BadgeType.streak30days:
        return clamp(_maxStreak / 30);
      case BadgeType.monthlyChallenger:
        return clamp(_bestMonthlyCount / 4);
      case BadgeType.monthly8:
        return clamp(_bestMonthlyCount / 8);
      case BadgeType.yearlyHiker:
        return clamp(_bestYearlyCount / 12);
      case BadgeType.yearly50:
        return clamp(_bestYearlyCount / 50);
      case BadgeType.yearly100:
        return clamp(_bestYearlyCount / 100);
      case BadgeType.allSeasons:
        return clamp(_seasonsCovered / 4);
      case BadgeType.everyMonth:
        return clamp(_monthsCovered / 12);

      // Challenge
      case BadgeType.weekendWarrior:
        return clamp(_weekendHikes / 10);
      case BadgeType.weekdayHiker:
        return clamp(_weekdayHikes / 10);
      case BadgeType.rainHiker:
        return _hasRainHike ? 1.0 : 0.0;
      case BadgeType.winterHiker:
        return _hasWinterHike ? 1.0 : 0.0;
      case BadgeType.summerHiker:
        return _hasSummerHike ? 1.0 : 0.0;
      case BadgeType.speedDemon:
        return _hasSpeedDemon ? 1.0 : 0.0;
      case BadgeType.distanceDay20km:
        return clamp(_maxSingleDayDistance / 20);
      case BadgeType.multiPeak3:
        return clamp(_maxPeaksInDay / 3);
      case BadgeType.backToBack:
        return _hasBackToBack ? 1.0 : 0.0;
      case BadgeType.centurion:
        return clamp(_uniqueMountainCount / 100);

      // Special
      case BadgeType.newYear:
        return _hasNewYearHike ? 1.0 : 0.0;
      case BadgeType.springBloom:
        return clamp(_springHikeCount / 5);
      case BadgeType.summerSolstice:
        return _hasSummerSolstice ? 1.0 : 0.0;
      case BadgeType.autumnLeaves:
        return clamp(_autumnHikeCount / 5);
      case BadgeType.winterSolstice:
        return _hasWinterSolstice ? 1.0 : 0.0;
      case BadgeType.fullMoon:
        return _hasFullMoonHike ? 1.0 : 0.0;
      case BadgeType.birthday:
        return _hasBirthdayHike ? 1.0 : 0.0;
      case BadgeType.anniversary100:
        return _hasAnniversary100 ? 1.0 : 0.0;
      case BadgeType.milestone50stamps:
        return clamp(_totalStamped / 50);
      case BadgeType.explorer20regions:
        return clamp(_hikedRegionCount / 20);
      case BadgeType.grandMaster:
        return clamp(earnedCount / 50);
      case BadgeType.legendaryHiker:
        return clamp(earnedCount / 75);
      case BadgeType.ultimateChallenger:
        return clamp(earnedCount / 90);
      case BadgeType.perfectYear:
        return _hasPerfectYear ? 1.0 : 0.0;
    }
  }

  // ── private: check a single badge ──────────────

  bool _check(BadgeType type) {
    switch (type) {
      // Count
      case BadgeType.firstHike:
        return _totalHikes >= 1;
      case BadgeType.hikes5:
        return _totalHikes >= 5;
      case BadgeType.hikes10:
        return _totalHikes >= 10;
      case BadgeType.hikes25:
        return _totalHikes >= 25;
      case BadgeType.hikes50:
        return _totalHikes >= 50;
      case BadgeType.hikes100:
        return _totalHikes >= 100;
      case BadgeType.hikes200:
        return _totalHikes >= 200;
      case BadgeType.hikes365:
        return _totalHikes >= 365;
      case BadgeType.hikes500:
        return _totalHikes >= 500;
      case BadgeType.hikes1000:
        return _totalHikes >= 1000;

      // Distance
      case BadgeType.distance10km:
        return _totalDistanceKm >= 10;
      case BadgeType.distance50km:
        return _totalDistanceKm >= 50;
      case BadgeType.distance100km:
        return _totalDistanceKm >= 100;
      case BadgeType.distance200km:
        return _totalDistanceKm >= 200;
      case BadgeType.distance500km:
        return _totalDistanceKm >= 500;
      case BadgeType.distance1000km:
        return _totalDistanceKm >= 1000;
      case BadgeType.distance2000km:
        return _totalDistanceKm >= 2000;
      case BadgeType.distance3000km:
        return _totalDistanceKm >= 3000;
      case BadgeType.distance5000km:
        return _totalDistanceKm >= 5000;
      case BadgeType.distance10000km:
        return _totalDistanceKm >= 10000;

      // Elevation
      case BadgeType.elevation500m:
        return _totalElevation >= 500;
      case BadgeType.elevation1000m:
        return _totalElevation >= 1000;
      case BadgeType.elevation1500m:
        return _totalElevation >= 1500;
      case BadgeType.elevation5000m:
        return _totalElevation >= 5000;
      case BadgeType.elevation10000m:
        return _totalElevation >= 10000;
      case BadgeType.elevation50000m:
        return _totalElevation >= 50000;
      case BadgeType.singleHike500m:
        return _maxSingleElevation >= 500;
      case BadgeType.singleHike1000m:
        return _maxSingleElevation >= 1000;
      case BadgeType.peak1000m:
        return _hasPeakAbove(1000);
      case BadgeType.peak1500m:
        return _hasPeakAbove(1500);

      // Region
      case BadgeType.regions3:
        return _stampedRegionCount >= 3;
      case BadgeType.regions5:
        return _stampedRegionCount >= 5;
      case BadgeType.regions8:
        return _stampedRegionCount >= 8;
      case BadgeType.regions10:
        return _stampedRegionCount >= 10;
      case BadgeType.regions15:
        return _stampedRegionCount >= 15;
      case BadgeType.allRegions:
        return _allRegionCount > 0 && _stampedRegionCount >= _allRegionCount;
      case BadgeType.islandMountain:
        return _hasIslandStamp;
      case BadgeType.capitalArea5:
        return _capitalAreaStamps >= 5;

      // Stamps
      case BadgeType.stamps5:
        return _totalStamped >= 5;
      case BadgeType.stamps10:
        return _totalStamped >= 10;
      case BadgeType.stamps25:
        return _totalStamped >= 25;
      case BadgeType.stamps50:
        return _totalStamped >= 50;
      case BadgeType.stamps75:
        return _totalStamped >= 75;
      case BadgeType.stamps100:
        return _totalStamped >= 100;
      case BadgeType.stamps150:
        return _totalStamped >= 150;
      case BadgeType.stamps200:
        return _totalStamped >= 200;
      case BadgeType.stamps250:
        return _totalStamped >= 250;
      case BadgeType.stamps300:
        return _totalStamped >= 300;

      // Together
      case BadgeType.together1:
        return _togetherCount >= 1;
      case BadgeType.together5:
        return _togetherCount >= 5;
      case BadgeType.together10:
        return _togetherCount >= 10;
      case BadgeType.together25:
        return _togetherCount >= 25;
      case BadgeType.together50:
        return _togetherCount >= 50;
      case BadgeType.together100:
        return _togetherCount >= 100;
      case BadgeType.togetherStreak3:
        return _togetherStreak >= 3;
      case BadgeType.togetherStreak7:
        return _togetherStreak >= 7;

      // Time
      case BadgeType.earlyBird:
        return _hasHikeBefore(6);
      case BadgeType.dawnHiker:
        return _hasHikeBefore(5);
      case BadgeType.nightHiker:
        return _hasHikeAfter(20);
      case BadgeType.longHike4h:
        return _maxDurationHours >= 4;
      case BadgeType.longHike6h:
        return _maxDurationHours >= 6;
      case BadgeType.longHike8h:
        return _maxDurationHours >= 8;
      case BadgeType.longHike10h:
        return _maxDurationHours >= 10;
      case BadgeType.quickHike1h:
        return _hasQuickHike;
      case BadgeType.sunriseHike:
        return _hasSunriseHike;
      case BadgeType.sunsetHike:
        return _hasSunsetHike;

      // Consistency
      case BadgeType.streakWeek:
        return _maxStreak >= 7;
      case BadgeType.streak2weeks:
        return _maxStreak >= 14;
      case BadgeType.streak30days:
        return _maxStreak >= 30;
      case BadgeType.monthlyChallenger:
        return _bestMonthlyCount >= 4;
      case BadgeType.monthly8:
        return _bestMonthlyCount >= 8;
      case BadgeType.yearlyHiker:
        return _bestYearlyCount >= 12;
      case BadgeType.yearly50:
        return _bestYearlyCount >= 50;
      case BadgeType.yearly100:
        return _bestYearlyCount >= 100;
      case BadgeType.allSeasons:
        return _seasonsCovered >= 4;
      case BadgeType.everyMonth:
        return _monthsCovered >= 12;

      // Challenge
      case BadgeType.weekendWarrior:
        return _weekendHikes >= 10;
      case BadgeType.weekdayHiker:
        return _weekdayHikes >= 10;
      case BadgeType.rainHiker:
        return _hasRainHike;
      case BadgeType.winterHiker:
        return _hasWinterHike;
      case BadgeType.summerHiker:
        return _hasSummerHike;
      case BadgeType.speedDemon:
        return _hasSpeedDemon;
      case BadgeType.distanceDay20km:
        return _maxSingleDayDistance >= 20;
      case BadgeType.multiPeak3:
        return _maxPeaksInDay >= 3;
      case BadgeType.backToBack:
        return _hasBackToBack;
      case BadgeType.centurion:
        return _uniqueMountainCount >= 100;

      // Special
      case BadgeType.newYear:
        return _hasNewYearHike;
      case BadgeType.springBloom:
        return _springHikeCount >= 5;
      case BadgeType.summerSolstice:
        return _hasSummerSolstice;
      case BadgeType.autumnLeaves:
        return _autumnHikeCount >= 5;
      case BadgeType.winterSolstice:
        return _hasWinterSolstice;
      case BadgeType.fullMoon:
        return _hasFullMoonHike;
      case BadgeType.birthday:
        return _hasBirthdayHike;
      case BadgeType.anniversary100:
        return _hasAnniversary100;
      case BadgeType.milestone50stamps:
        return _totalStamped >= 50;
      case BadgeType.explorer20regions:
        return _hikedRegionCount >= 20;
      case BadgeType.grandMaster:
        return earnedCount >= 50;
      case BadgeType.legendaryHiker:
        return earnedCount >= 75;
      case BadgeType.ultimateChallenger:
        return earnedCount >= 90;
      case BadgeType.perfectYear:
        return _hasPerfectYear;
    }
  }

  // ── private: computed helper values ─────────────

  int get _totalHikes => _records.length;

  double get _totalDistanceKm {
    double sum = 0;
    for (final r in _records) {
      sum += r.distanceKm;
    }
    return sum;
  }

  int get _totalElevation {
    int sum = 0;
    for (final r in _records) {
      sum += r.elevationGain ?? 0;
    }
    return sum;
  }

  int get _maxSingleElevation {
    int best = 0;
    for (final r in _records) {
      final e = r.elevationGain ?? 0;
      if (e > best) best = e;
    }
    return best;
  }

  /// Check if any stamped mountain has height >= [h].
  bool _hasPeakAbove(int h) {
    for (final s in _stamps) {
      if (s.isStamped && s.height >= h) return true;
    }
    return false;
  }

  // Stamp helpers
  int get _totalStamped => _stamps.where((s) => s.isStamped).length;
  int get _togetherCount => _stamps.where((s) => s.isTogetherStamped).length;

  int get _stampedRegionCount {
    final regions = <String>{};
    for (final s in _stamps) {
      if (s.isStamped) regions.add(s.region);
    }
    return regions.length;
  }

  int get _allRegionCount {
    final regions = <String>{};
    for (final s in _stamps) {
      regions.add(s.region);
    }
    return regions.length;
  }

  bool get _hasIslandStamp {
    for (final s in _stamps) {
      if (s.isStamped && (s.region == '제주' || s.region == '제주도')) return true;
    }
    return false;
  }

  int get _capitalAreaStamps {
    int count = 0;
    for (final s in _stamps) {
      if (s.isStamped && (s.region == '서울' || s.region == '경기')) count++;
    }
    return count;
  }

  /// Together streak: longest run of consecutive stamped stamps that are also togetherStamped.
  /// We order stamps by stampDate and look for consecutive together stamps.
  int get _togetherStreak {
    final dated = _stamps
        .where((s) => s.isTogetherStamped && s.stampDate != null)
        .toList();
    if (dated.isEmpty) return 0;

    // Sort by stamp date
    dated.sort((a, b) => (a.stampDate ?? '').compareTo(b.stampDate ?? ''));

    int best = 1;
    int current = 1;
    for (int i = 1; i < dated.length; i++) {
      final prevDate = _parseStampDate(dated[i - 1].stampDate);
      final currDate = _parseStampDate(dated[i].stampDate);
      if (prevDate != null && currDate != null) {
        final diff = currDate.difference(prevDate).inDays;
        if (diff <= 7) {
          // Within a week = consecutive together hiking
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

  DateTime? _parseStampDate(String? s) {
    if (s == null) return null;
    // Expected format: "2025.01.20"
    try {
      final parts = s.split('.');
      if (parts.length == 3) {
        return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      }
    } catch (_) {}
    return null;
  }

  // ── Time helpers ────────────────────────────────

  bool _hasHikeBefore(int hour) {
    for (final r in _records) {
      final st = r.startTime;
      if (st != null && st.hour < hour) return true;
    }
    return false;
  }

  bool _hasHikeAfter(int hour) {
    for (final r in _records) {
      final st = r.startTime;
      if (st != null && st.hour >= hour) return true;
    }
    return false;
  }

  double get _maxDurationHours {
    double best = 0;
    for (final r in _records) {
      final h = _parseDurationHours(r);
      if (h > best) best = h;
    }
    return best;
  }

  bool get _hasQuickHike {
    for (final r in _records) {
      final h = _parseDurationHours(r);
      if (h > 0 && h < 1) return true;
    }
    return false;
  }

  bool get _hasSunriseHike {
    for (final r in _records) {
      final st = r.startTime;
      if (st != null && st.hour >= 5 && st.hour < 7) return true;
    }
    return false;
  }

  bool get _hasSunsetHike {
    for (final r in _records) {
      final st = r.startTime;
      if (st != null && st.hour >= 17 && st.hour < 19) return true;
    }
    return false;
  }

  /// Parse duration from record. Uses startTime/endTime if available,
  /// else parses the duration string like "2h 30m" or "45m 10s".
  double _parseDurationHours(HikingRecord r) {
    if (r.startTime != null && r.endTime != null) {
      return r.endTime!.difference(r.startTime!).inMinutes / 60.0;
    }
    // Fallback: parse duration string
    final d = r.duration;
    double hours = 0;
    final hMatch = RegExp(r'(\d+)\s*h').firstMatch(d);
    final mMatch = RegExp(r'(\d+)\s*m').firstMatch(d);
    if (hMatch != null) hours += int.parse(hMatch.group(1)!);
    if (mMatch != null) hours += int.parse(mMatch.group(1)!) / 60.0;
    return hours;
  }

  // ── Consistency helpers ─────────────────────────

  /// Max consecutive-day streak from start times.
  int get _maxStreak {
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

  /// Unique hike dates (date-only, no duplicates).
  Set<DateTime> get _hikeDays {
    final days = <DateTime>{};
    for (final r in _records) {
      final d = r.startTime ?? _parseDateField(r.date);
      if (d != null) days.add(DateTime(d.year, d.month, d.day));
    }
    return days;
  }

  DateTime? _parseDateField(String date) {
    // Try to parse strings like "3월 15일"
    final m = RegExp(r'(\d+)월\s*(\d+)일').firstMatch(date);
    if (m != null) {
      final month = int.parse(m.group(1)!);
      final day = int.parse(m.group(2)!);
      return DateTime(DateTime.now().year, month, day);
    }
    return null;
  }

  int get _bestMonthlyCount {
    final counts = <String, int>{};
    for (final r in _records) {
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

  int get _bestYearlyCount {
    final counts = <int, int>{};
    for (final r in _records) {
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

  /// Number of seasons (spring 3-5, summer 6-8, fall 9-11, winter 12,1,2) covered.
  int get _seasonsCovered {
    final seasons = <int>{};
    for (final r in _records) {
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

  /// Number of distinct months (1-12) that have at least one hike.
  int get _monthsCovered {
    final months = <int>{};
    for (final r in _records) {
      final d = r.startTime ?? _parseDateField(r.date);
      if (d == null) continue;
      months.add(d.month);
    }
    return months.length;
  }

  // ── Challenge helpers ──────────────────────────

  int get _weekendHikes {
    int count = 0;
    for (final r in _records) {
      final d = r.startTime ?? _parseDateField(r.date);
      if (d == null) continue;
      if (d.weekday == DateTime.saturday || d.weekday == DateTime.sunday) count++;
    }
    return count;
  }

  int get _weekdayHikes {
    int count = 0;
    for (final r in _records) {
      final d = r.startTime ?? _parseDateField(r.date);
      if (d == null) continue;
      if (d.weekday >= DateTime.monday && d.weekday <= DateTime.friday) count++;
    }
    return count;
  }

  /// Rain hiker: any hike in Jun–Aug (rainy season proxy).
  bool get _hasRainHike {
    for (final r in _records) {
      final d = r.startTime ?? _parseDateField(r.date);
      if (d != null && d.month >= 6 && d.month <= 8) return true;
    }
    return false;
  }

  bool get _hasWinterHike {
    for (final r in _records) {
      final d = r.startTime ?? _parseDateField(r.date);
      if (d != null && (d.month == 12 || d.month == 1 || d.month == 2)) return true;
    }
    return false;
  }

  bool get _hasSummerHike {
    for (final r in _records) {
      final d = r.startTime ?? _parseDateField(r.date);
      if (d != null && d.month >= 6 && d.month <= 8) return true;
    }
    return false;
  }

  /// Speed demon: any hike >= 5km finished in < 2 hours.
  bool get _hasSpeedDemon {
    for (final r in _records) {
      if (r.distanceKm >= 5 && _parseDurationHours(r) > 0 && _parseDurationHours(r) < 2) {
        return true;
      }
    }
    return false;
  }

  /// Max total distance in a single calendar day (aggregating multiple records).
  double get _maxSingleDayDistance {
    final dayDist = <String, double>{};
    for (final r in _records) {
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

  /// Max number of distinct mountain names in a single day.
  int get _maxPeaksInDay {
    final dayPeaks = <String, Set<String>>{};
    for (final r in _records) {
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

  /// Two consecutive days with different mountains.
  bool get _hasBackToBack {
    final dayMountains = <DateTime, Set<String>>{};
    for (final r in _records) {
      final d = r.startTime ?? _parseDateField(r.date);
      if (d == null) continue;
      final key = DateTime(d.year, d.month, d.day);
      dayMountains.putIfAbsent(key, () => <String>{}).add(r.mountain);
    }
    final sortedDays = dayMountains.keys.toList()..sort();
    for (int i = 1; i < sortedDays.length; i++) {
      if (sortedDays[i].difference(sortedDays[i - 1]).inDays == 1) {
        // Check that at least one mountain differs
        final prev = dayMountains[sortedDays[i - 1]]!;
        final curr = dayMountains[sortedDays[i]]!;
        if (!prev.containsAll(curr) || !curr.containsAll(prev)) return true;
      }
    }
    return false;
  }

  /// Number of unique mountain names hiked.
  int get _uniqueMountainCount {
    final names = <String>{};
    for (final r in _records) {
      names.add(r.mountain);
    }
    return names.length;
  }

  // ── Special helpers ────────────────────────────

  bool get _hasNewYearHike {
    for (final r in _records) {
      final d = r.startTime ?? _parseDateField(r.date);
      if (d != null && d.month == 1 && d.day == 1) return true;
    }
    return false;
  }

  int get _springHikeCount {
    int count = 0;
    for (final r in _records) {
      final d = r.startTime ?? _parseDateField(r.date);
      if (d != null && d.month >= 3 && d.month <= 5) count++;
    }
    return count;
  }

  bool get _hasSummerSolstice {
    for (final r in _records) {
      final d = r.startTime ?? _parseDateField(r.date);
      if (d != null && d.month == 6 && d.day >= 20 && d.day <= 22) return true;
    }
    return false;
  }

  int get _autumnHikeCount {
    int count = 0;
    for (final r in _records) {
      final d = r.startTime ?? _parseDateField(r.date);
      if (d != null && d.month >= 9 && d.month <= 11) count++;
    }
    return count;
  }

  bool get _hasWinterSolstice {
    for (final r in _records) {
      final d = r.startTime ?? _parseDateField(r.date);
      if (d != null && d.month == 12 && d.day >= 20 && d.day <= 22) return true;
    }
    return false;
  }

  bool get _hasFullMoonHike {
    for (final r in _records) {
      final d = r.startTime ?? _parseDateField(r.date);
      if (d != null && d.day == 15) return true;
    }
    return false;
  }

  bool get _hasBirthdayHike {
    if (_birthday == null) return false;
    for (final r in _records) {
      final d = r.startTime ?? _parseDateField(r.date);
      if (d != null && d.month == _birthday!.month && d.day == _birthday!.day) return true;
    }
    return false;
  }

  bool get _hasAnniversary100 {
    if (_joinDate == null) return false;
    final target = _joinDate!.add(const Duration(days: 100));
    for (final r in _records) {
      final d = r.startTime ?? _parseDateField(r.date);
      if (d != null && d.year == target.year && d.month == target.month && d.day == target.day) {
        return true;
      }
    }
    return false;
  }

  int get _hikedRegionCount {
    // Derive regions from record mountain names matched against stamps
    final regions = <String>{};
    final stampMap = <String, String>{};
    for (final s in _stamps) {
      stampMap[s.name] = s.region;
    }
    for (final r in _records) {
      final region = stampMap[r.mountain];
      if (region != null) regions.add(region);
    }
    return regions.length;
  }

  bool get _hasPerfectYear {
    // Group hikes by year, check if any year has 50+ hikes AND covers all 12 months
    final yearMonths = <int, Set<int>>{};
    final yearCount = <int, int>{};
    for (final r in _records) {
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
}
