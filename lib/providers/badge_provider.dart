import 'package:flutter/material.dart';
import '../core/badge_evaluator.dart';
import '../models/badge.dart';
import '../models/hiking_record.dart';
import '../models/stamp.dart';

/// 배지/업적 상태 관리 Provider.
///
/// 평가 로직은 [BadgeEvaluator]에 위임하고, 상태 관리만 담당합니다.
class BadgeProvider extends ChangeNotifier {
  final Set<BadgeType> _earned = {};
  BadgeEvaluator? _evaluator;

  List<HikingRecord> _records = [];
  List<Stamp> _stamps = [];
  DateTime? _joinDate;
  DateTime? _birthday;

  // ── public API ──────────────────────────────────

  Set<BadgeType> get earned => _earned;
  bool isEarned(BadgeType type) => _earned.contains(type);
  int get earnedCount => _earned.length;

  /// 모든 배지를 재평가합니다.
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

    _evaluator = BadgeEvaluator(
      records: records,
      stamps: stamps,
      joinDate: joinDate,
      birthday: birthday,
    );

    _earned.clear();
    final baseEarned = _evaluator!.evaluateAll();
    _earned.addAll(baseEarned);

    // 메타 배지 (earnedCount에 의존)
    if (_earned.length >= 50) _earned.add(BadgeType.grandMaster);
    if (_earned.length >= 75) _earned.add(BadgeType.legendaryHiker);
    if (_earned.length >= 90) _earned.add(BadgeType.ultimateChallenger);

    notifyListeners();
  }

  /// 저장된 데이터로 재평가
  void refresh() {
    if (_records.isNotEmpty || _stamps.isNotEmpty) {
      evaluate(records: _records, stamps: _stamps, joinDate: _joinDate, birthday: _birthday);
    }
  }

  /// 다음 달성에 가장 가까운 배지
  HikingBadge? get nextBadge {
    if (_evaluator == null) return null;
    HikingBadge? best;
    double bestRatio = -1;
    for (final b in allBadgeDefinitions) {
      if (!_earned.contains(b.type)) {
        final r = _evaluator!.getProgressRatio(b.type, earnedCount: earnedCount);
        if (r > bestRatio) {
          bestRatio = r;
          best = b;
        }
      }
    }
    return best;
  }

  /// 획득한 배지 목록 (호출자가 이미 표시된 항목 추적)
  List<HikingBadge> getNewlyEarnedBadges() {
    return allBadgeDefinitions.where((b) => _earned.contains(b.type)).toList();
  }

  /// 진행 문자열 (예: "5 / 10")
  String getProgress(BadgeType type) {
    return _evaluator?.getProgress(type, earnedCount: earnedCount) ?? '-';
  }

  /// 진행 비율 0.0 – 1.0 (프로그레스 바 UI용)
  double getProgressRatio(BadgeType type) {
    return _evaluator?.getProgressRatio(type, earnedCount: earnedCount) ?? 0.0;
  }
}
