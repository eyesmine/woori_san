import 'package:flutter/material.dart';
import '../models/hiking_record.dart';
import '../theme/app_theme.dart';

class ShareRecordCard extends StatelessWidget {
  final HikingRecord record;
  const ShareRecordCard({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header gradient bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1B4332), AppTheme.primary, Color(0xFF40916C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: const Center(
              child: Text(
                '우리산',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Mountain emoji
          Text(
            record.emoji,
            style: const TextStyle(fontSize: 48),
          ),

          const SizedBox(height: 12),

          // Mountain name
          Text(
            record.mountain,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),

          const SizedBox(height: 6),

          // Date
          Text(
            record.date,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),

          const SizedBox(height: 20),

          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Divider(color: Colors.grey.shade200, thickness: 1),
          ),

          const SizedBox(height: 20),

          // Stats row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem(
                  label: '거리',
                  value: record.distance,
                  icon: Icons.straighten,
                ),
                Container(width: 1, height: 40, color: Colors.grey.shade200),
                _StatItem(
                  label: '시간',
                  value: record.duration,
                  icon: Icons.timer_outlined,
                ),
                Container(width: 1, height: 40, color: Colors.grey.shade200),
                _StatItem(
                  label: '고도',
                  value: record.elevationGain != null
                      ? '${record.elevationGain}m'
                      : '-',
                  icon: Icons.trending_up,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Footer
          Text(
            '우리산 앱에서 기록',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade400,
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatItem({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primary, size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
