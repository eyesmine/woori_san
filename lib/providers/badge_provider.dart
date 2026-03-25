import '../core/badge_evaluator.dart';
import '../models/badge.dart';
import '../models/hiking_record.dart';
import '../models/stamp.dart';

class BadgeProvider {
  final Set<BadgeType> _earned;
  final BadgeEvaluator? _evaluator;

  BadgeProvider({
    required List<HikingRecord> records,
    required List<Stamp> stamps,
    DateTime? joinDate,
    DateTime? birthday,
  })  : _evaluator = records.isEmpty && stamps.isEmpty && joinDate == null && birthday == null
            ? null
            : BadgeEvaluator(
                records: records,
                stamps: stamps,
                joinDate: joinDate,
                birthday: birthday,
              ),
        _earned = _buildEarned(
          records: records,
          stamps: stamps,
          joinDate: joinDate,
          birthday: birthday,
        );

  static Set<BadgeType> _buildEarned({
    required List<HikingRecord> records,
    required List<Stamp> stamps,
    DateTime? joinDate,
    DateTime? birthday,
  }) {
    final evaluator = BadgeEvaluator(
      records: records,
      stamps: stamps,
      joinDate: joinDate,
      birthday: birthday,
    );

    final earned = <BadgeType>{};
    earned.addAll(evaluator.evaluateAll());

    if (earned.length >= 50) earned.add(BadgeType.grandMaster);
    if (earned.length >= 75) earned.add(BadgeType.legendaryHiker);
    if (earned.length >= 90) earned.add(BadgeType.ultimateChallenger);

    return earned;
  }

  Set<BadgeType> get earned => _earned;
  bool isEarned(BadgeType type) => _earned.contains(type);
  int get earnedCount => _earned.length;

  /// 다음 달성에 가장 가까운 배지
  HikingBadge? get nextBadge {
    if (_evaluator == null) return null;
    HikingBadge? best;
    double bestRatio = -1;
    for (final b in allBadgeDefinitions) {
      if (!_earned.contains(b.type)) {
        final r = _evaluator.getProgressRatio(b.type, earnedCount: earnedCount);
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
