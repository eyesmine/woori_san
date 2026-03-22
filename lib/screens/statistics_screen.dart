import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../providers/statistics_provider.dart';
import '../providers/badge_provider.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late DateTime _calendarMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _calendarMonth = DateTime(now.year, now.month);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.ourRecords),
      ),
      body: Consumer2<StatisticsProvider, BadgeProvider>(
        builder: (context, stats, badgeProv, _) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            children: [
              // Summary cards
              _SummaryCards(stats: stats),
              const SizedBox(height: 24),

              // Best Records
              _SectionHeader(title: l.bestRecords, emoji: '🏅'),
              const SizedBox(height: 12),
              _BestRecordsCard(stats: stats, l: l),
              const SizedBox(height: 24),

              // Hiking Calendar
              _SectionHeader(title: l.hikingCalendar, emoji: '📅'),
              const SizedBox(height: 12),
              _HikingCalendar(
                hikingDates: stats.hikingDates,
                month: _calendarMonth,
                onPrevMonth: () => setState(() {
                  _calendarMonth = DateTime(_calendarMonth.year, _calendarMonth.month - 1);
                }),
                onNextMonth: () => setState(() {
                  _calendarMonth = DateTime(_calendarMonth.year, _calendarMonth.month + 1);
                }),
              ),
              const SizedBox(height: 24),

              // Next Badge Progress
              if (badgeProv.nextBadge != null) ...[
                _SectionHeader(title: l.nextBadge, emoji: '🎯'),
                const SizedBox(height: 12),
                _NextBadgeCard(badgeProv: badgeProv),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String emoji;
  const _SectionHeader({required this.title, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 4, height: 20, decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 10),
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 6),
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: context.appText)),
      ],
    );
  }
}

class _SummaryCards extends StatelessWidget {
  final StatisticsProvider stats;
  const _SummaryCards({required this.stats});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppTheme.primary.withAlpha(77), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryItem(value: '${stats.totalHikes}', label: l.totalHikes, icon: '🏔️'),
          Container(width: 1, height: 40, color: Colors.white24),
          _SummaryItem(value: stats.totalDistance, label: l.totalDistance, icon: '📍'),
          Container(width: 1, height: 40, color: Colors.white24),
          _SummaryItem(value: '${stats.totalElevationGain}m', label: l.altitude, icon: '⛰️'),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String value;
  final String label;
  final String icon;
  const _SummaryItem({required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}

class _BestRecordsCard extends StatelessWidget {
  final StatisticsProvider stats;
  final AppLocalizations l;
  const _BestRecordsCard({required this.stats, required this.l});

  @override
  Widget build(BuildContext context) {
    final hasRecords = stats.records.isNotEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFD700).withAlpha(77), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: hasRecords
          ? Row(
              children: [
                Expanded(child: _BestRecordItem(icon: Icons.straighten, value: stats.longestDistance, label: l.longestDistance, color: const Color(0xFFFFD700))),
                Container(width: 1, height: 48, color: Colors.grey.withAlpha(51)),
                Expanded(child: _BestRecordItem(icon: Icons.terrain, value: stats.highestElevation, label: l.highestElevation, color: const Color(0xFFFFD700))),
                Container(width: 1, height: 48, color: Colors.grey.withAlpha(51)),
                Expanded(child: _BestRecordItem(icon: Icons.timer, value: stats.longestDuration, label: l.longestDuration, color: const Color(0xFFFFD700))),
              ],
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(l.noRecordYet, style: TextStyle(color: context.appTextSub, fontSize: 14)),
              ),
            ),
    );
  }
}

class _BestRecordItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _BestRecordItem({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: context.appText),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: context.appTextSub)),
      ],
    );
  }
}

class _HikingCalendar extends StatelessWidget {
  final Set<DateTime> hikingDates;
  final DateTime month;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  const _HikingCalendar({required this.hikingDates, required this.month, required this.onPrevMonth, required this.onNextMonth});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isKorean = AppLocalizations.of(context)!.localeName == 'ko';
    final weekDays = isKorean
        ? ['일', '월', '화', '수', '목', '금', '토']
        : ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final startWeekday = firstDay.weekday % 7; // Sunday = 0

    final monthLabel = isKorean
        ? '${month.year}년 ${month.month}월'
        : '${_monthName(month.month)} ${month.year}';

    final canGoNext = month.year < now.year || (month.year == now.year && month.month < now.month);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          // Month navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 24),
                onPressed: onPrevMonth,
                color: context.appText,
              ),
              Text(monthLabel, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: context.appText)),
              IconButton(
                icon: Icon(Icons.chevron_right, size: 24, color: canGoNext ? context.appText : Colors.grey.withAlpha(77)),
                onPressed: canGoNext ? onNextMonth : null,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Weekday headers
          Row(
            children: weekDays.map((d) => Expanded(
              child: Center(
                child: Text(d, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.appTextSub)),
              ),
            )).toList(),
          ),
          const SizedBox(height: 4),
          // Calendar grid
          ...List.generate(6, (week) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: List.generate(7, (dayOfWeek) {
                  final dayIndex = week * 7 + dayOfWeek - startWeekday + 1;
                  if (dayIndex < 1 || dayIndex > lastDay.day) {
                    return const Expanded(child: SizedBox(height: 32));
                  }
                  final date = DateTime(month.year, month.month, dayIndex);
                  final hiked = hikingDates.contains(date);
                  final isToday = date.year == now.year && date.month == now.month && date.day == now.day;

                  return Expanded(
                    child: Center(
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: hiked
                              ? AppTheme.primary
                              : isToday
                                  ? AppTheme.primary.withAlpha(25)
                                  : Colors.transparent,
                          border: isToday && !hiked
                              ? Border.all(color: AppTheme.primary, width: 1.5)
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            '$dayIndex',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: hiked || isToday ? FontWeight.w700 : FontWeight.w400,
                              color: hiked
                                  ? Colors.white
                                  : isToday
                                      ? AppTheme.primary
                                      : context.appTextSub,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const names = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return names[month];
  }
}

class _NextBadgeCard extends StatelessWidget {
  final BadgeProvider badgeProv;
  const _NextBadgeCard({required this.badgeProv});

  @override
  Widget build(BuildContext context) {
    final badge = badgeProv.nextBadge!;
    final isKorean = AppLocalizations.of(context)!.localeName == 'ko';
    final title = isKorean ? badge.titleKo : badge.titleEn;
    final progress = badgeProv.getProgress(badge.type);
    final ratio = badgeProv.getProgressRatio(badge.type);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primary.withAlpha(25),
            ),
            child: Center(child: Text(badge.emoji, style: const TextStyle(fontSize: 28))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: context.appText)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: ratio,
                          minHeight: 8,
                          backgroundColor: Colors.grey.withAlpha(51),
                          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(progress, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.appTextSub)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
