import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

class HomeStatsCard extends StatelessWidget {
  final int hikes;
  final String distance;
  final int stamps;
  const HomeStatsCard({super.key, required this.hikes, required this.distance, required this.stamps});

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
          _StatItem(value: '$hikes', label: l.totalHikes, icon: '🏔️'),
          Container(width: 1, height: 40, color: Colors.white24),
          _StatItem(value: distance, label: l.totalDistance, icon: '📍'),
          Container(width: 1, height: 40, color: Colors.white24),
          _StatItem(value: '$stamps개', label: l.earnedStamps, icon: '🎖️'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final String icon;
  const _StatItem({required this.value, required this.label, required this.icon});

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
