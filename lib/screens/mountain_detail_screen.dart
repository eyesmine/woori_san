import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/mountain.dart';
import '../providers/mountain_provider.dart';
class MountainDetailScreen extends StatelessWidget {
  final String mountainId;
  const MountainDetailScreen({super.key, required this.mountainId});

  @override
  Widget build(BuildContext context) {
    return Consumer<MountainProvider>(
      builder: (context, state, _) {
        final mountain = state.getMountainById(mountainId);
        if (mountain == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('산 정보를 찾을 수 없습니다.')),
          );
        }
        return _DetailBody(mountain: mountain);
      },
    );
  }
}

class _DetailBody extends StatelessWidget {
  final Mountain mountain;
  const _DetailBody({required this.mountain});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: mountain.colors,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Text(mountain.emoji, style: const TextStyle(fontSize: 72)),
                      const SizedBox(height: 8),
                      Text(
                        mountain.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '${mountain.location} · ${mountain.height}m',
                        style: const TextStyle(color: Colors.white70, fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info cards row
                  Row(
                    children: [
                      Expanded(child: _InfoCard(icon: Icons.trending_up, label: '난이도', value: mountain.difficulty.label, color: mountain.difficulty.color)),
                      const SizedBox(width: 12),
                      Expanded(child: _InfoCard(icon: Icons.timer_outlined, label: '소요 시간', value: mountain.time)),
                      const SizedBox(width: 12),
                      Expanded(child: _InfoCard(icon: Icons.straighten, label: '거리', value: mountain.distance)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _InfoCard(icon: Icons.height, label: '고도', value: '${mountain.height}m')),
                      const SizedBox(width: 12),
                      Expanded(child: _InfoCard(icon: Icons.location_on_outlined, label: '위치', value: mountain.location)),
                      const SizedBox(width: 12),
                      Expanded(child: _InfoCard(icon: Icons.star_outline, label: '태그', value: mountain.emoji)),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Text('소개', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  const SizedBox(height: 8),
                  Text(
                    mountain.description,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text('코스 정보', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withAlpha(15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _CourseRow(label: '코스 거리', value: mountain.distance),
                        const Divider(height: 24),
                        _CourseRow(label: '예상 소요시간', value: mountain.time),
                        const Divider(height: 24),
                        _CourseRow(label: '최고 고도', value: '${mountain.height}m'),
                        const Divider(height: 24),
                        _CourseRow(label: '난이도', value: mountain.difficulty.label),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text('위치', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.place, color: AppTheme.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(mountain.location, style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                              Text(
                                '위도 ${mountain.latitude.toStringAsFixed(4)}, 경도 ${mountain.longitude.toStringAsFixed(4)}',
                                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/tracking?mountainId=${mountain.id}'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.directions_walk),
        label: const Text('등산 시작', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;
  const _InfoCard({required this.icon, required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Icon(icon, color: color ?? AppTheme.primary, size: 20),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.textPrimary), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _CourseRow extends StatelessWidget {
  final String label;
  final String value;
  const _CourseRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary, fontSize: 14)),
      ],
    );
  }
}
