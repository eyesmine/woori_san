import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/badge.dart';
import '../providers/badge_provider.dart';
import '../theme/app_theme.dart';

class BadgeScreen extends StatelessWidget {
  const BadgeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('뱃지')),
      body: Consumer<BadgeProvider>(
        builder: (context, provider, _) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _ProgressHeader(
                total: allBadgeDefinitions.length,
                earned: provider.earnedCount,
              ),
              const SizedBox(height: 24),
              ..._buildCategories(context, provider),
              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildCategories(BuildContext context, BadgeProvider provider) {
    const categoryMeta = <BadgeCategory, _CategoryMeta>{
      BadgeCategory.count: _CategoryMeta('🏃', '횟수', 'Count'),
      BadgeCategory.distance: _CategoryMeta('📏', '거리', 'Distance'),
      BadgeCategory.elevation: _CategoryMeta('⛰️', '고도', 'Elevation'),
      BadgeCategory.region: _CategoryMeta('🗺️', '지역', 'Region'),
      BadgeCategory.stamps: _CategoryMeta('🎖️', '도장', 'Stamps'),
      BadgeCategory.together: _CategoryMeta('🤝', '함께', 'Together'),
      BadgeCategory.time: _CategoryMeta('⏰', '시간', 'Time'),
      BadgeCategory.consistency: _CategoryMeta('📅', '꾸준함', 'Consistency'),
      BadgeCategory.challenge: _CategoryMeta('💪', '도전', 'Challenge'),
      BadgeCategory.special: _CategoryMeta('🌟', '특수', 'Special'),
    };

    final widgets = <Widget>[];
    for (final category in BadgeCategory.values) {
      final badges = allBadgeDefinitions.where((b) => b.category == category).toList();
      if (badges.isEmpty) continue;

      final meta = categoryMeta[category]!;
      final earnedInCategory = badges.where((b) => provider.isEarned(b.type)).length;

      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 12),
          child: Row(
            children: [
              Text(meta.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                meta.titleKo,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: context.appText,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$earnedInCategory / ${badges.length}',
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      widgets.add(
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.75,
          ),
          itemCount: badges.length,
          itemBuilder: (context, index) => _BadgeTile(
            badge: badges[index],
            isEarned: provider.isEarned(badges[index].type),
            progress: provider.getProgress(badges[index].type),
            progressRatio: provider.getProgressRatio(badges[index].type),
            onTap: () => _showBadgeDetail(context, badges[index], provider),
          ),
        ),
      );
    }
    return widgets;
  }

  void _showBadgeDetail(BuildContext context, HikingBadge badge, BadgeProvider provider) {
    final isEarned = provider.isEarned(badge.type);
    final progress = provider.getProgress(badge.type);
    final ratio = provider.getProgressRatio(badge.type);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isEarned
                    ? AppTheme.primary.withAlpha(25)
                    : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  badge.emoji,
                  style: TextStyle(
                    fontSize: 40,
                    color: isEarned ? null : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              badge.titleKo,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isEarned ? context.appText : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              badge.titleEn,
              style: TextStyle(
                fontSize: 13,
                color: context.appTextSub,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              badge.descriptionKo,
              style: TextStyle(
                fontSize: 14,
                color: context.appTextSub,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Progress bar
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      progress,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: context.appText,
                      ),
                    ),
                    Text(
                      '${(ratio * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: ratio,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isEarned ? AppTheme.primary : AppTheme.primaryLight,
                    ),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (isEarned)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: AppTheme.primary, size: 18),
                    SizedBox(width: 6),
                    Text(
                      '달성 완료!',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  final int total;
  final int earned;

  const _ProgressHeader({required this.total, required this.earned});

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? earned / total : 0.0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '뱃지 컬렉션',
                style: TextStyle(fontSize: 13, color: context.appTextSub),
              ),
              const SizedBox(height: 2),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$earned',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary,
                      ),
                    ),
                    TextSpan(
                      text: ' / $total',
                      style: TextStyle(
                        fontSize: 16,
                        color: context.appTextSub,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            width: 70,
            height: 70,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 7,
                  backgroundColor: Colors.grey.shade100,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  final HikingBadge badge;
  final bool isEarned;
  final String progress;
  final double progressRatio;
  final VoidCallback onTap;

  const _BadgeTile({
    required this.badge,
    required this.isEarned,
    required this.progress,
    required this.progressRatio,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isEarned
              ? AppTheme.primary.withAlpha(15)
              : context.appSurface,
          borderRadius: BorderRadius.circular(16),
          border: isEarned
              ? Border.all(color: AppTheme.primary.withAlpha(50), width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              badge.emoji,
              style: TextStyle(
                fontSize: 32,
                color: isEarned ? null : Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              badge.titleKo,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isEarned ? context.appText : Colors.grey.shade400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Mini progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: SizedBox(
                height: 4,
                child: LinearProgressIndicator(
                  value: progressRatio,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isEarned ? AppTheme.primary : AppTheme.primaryLight.withAlpha(150),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isEarned ? '달성!' : progress,
              style: TextStyle(
                fontSize: 10,
                color: isEarned ? AppTheme.primary : context.appTextSub,
                fontWeight: isEarned ? FontWeight.w600 : FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryMeta {
  final String emoji;
  final String titleKo;
  final String titleEn;

  const _CategoryMeta(this.emoji, this.titleKo, this.titleEn);
}
