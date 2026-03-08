import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/mountain.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: CustomScrollView(
        slivers: [
          // 헤더
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppTheme.bg,
            flexibleSpace: FlexibleSpaceBar(
              background: _HeaderBanner(),
            ),
            title: const Text('우리산 🏔️'),
          ),

          // 코스 추천 섹션
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('이번 주 추천 코스', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  TextButton(onPressed: () {}, child: const Text('전체보기', style: TextStyle(color: AppTheme.primary))),
                ],
              ),
            ),
          ),

          // 추천 코스 가로 스크롤
          SliverToBoxAdapter(
            child: SizedBox(
              height: 220,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: sampleMountains.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) => _MountainCard(mountain: sampleMountains[index]),
              ),
            ),
          ),

          // 우리의 기록 섹션
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 8),
              child: Row(
                children: [
                  Container(width: 4, height: 20, decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 10),
                  const Text('우리의 기록', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                ],
              ),
            ),
          ),

          // 통계 카드
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _StatsCard(),
            ),
          ),

          // 최근 산행 기록
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _RecentRecord(
                  mountain: '북한산',
                  date: '2025.02.15',
                  duration: '4시간 23분',
                  distance: '8.2km',
                  emoji: '🌲',
                ),
                const SizedBox(height: 12),
                _RecentRecord(
                  mountain: '관악산',
                  date: '2025.02.01',
                  duration: '3시간 10분',
                  distance: '6.5km',
                  emoji: '⛅',
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B4332), Color(0xFF2D6A4F), Color(0xFF40916C)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text('다음 산행은 어디로?', style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 4),
              const Text('함께라면\n어디든 좋아요 🌿', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800, height: 1.3)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(value: '12', label: '함께한 산행', icon: '🏔️'),
          _Divider(),
          _StatItem(value: '87km', label: '총 거리', icon: '📍'),
          _Divider(),
          _StatItem(value: '5개', label: '획득 도장', icon: '🎖️'),
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

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 40, color: Colors.white24);
  }
}

class _MountainCard extends StatelessWidget {
  final Mountain mountain;
  const _MountainCard({required this.mountain});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 산 이미지 영역
          Container(
            height: 110,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: mountain.colors,
              ),
            ),
            child: Center(child: Text(mountain.emoji, style: const TextStyle(fontSize: 40))),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mountain.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.textPrimary)),
                const SizedBox(height: 4),
                Row(children: [
                  _Tag(mountain.difficulty),
                  const SizedBox(width: 6),
                  Text(mountain.time, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  const _Tag(this.text);

  Color get color {
    if (text == '초급') return Colors.green;
    if (text == '중급') return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}

class _RecentRecord extends StatelessWidget {
  final String mountain;
  final String date;
  final String duration;
  final String distance;
  final String emoji;

  const _RecentRecord({required this.mountain, required this.date, required this.duration, required this.distance, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mountain, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.textPrimary)),
                const SizedBox(height: 4),
                Text(date, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(duration, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.primary)),
              Text(distance, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}