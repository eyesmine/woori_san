import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
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
            body: Center(child: Text(AppLocalizations.of(context)?.mountainNotFound ?? 'Mountain not found.')),
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
    final l = AppLocalizations.of(context)!;
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
                      Expanded(child: _InfoCard(icon: Icons.trending_up, label: l.difficulty, value: mountain.difficulty.label, color: mountain.difficulty.color)),
                      const SizedBox(width: 12),
                      Expanded(child: _InfoCard(icon: Icons.timer_outlined, label: l.duration, value: mountain.time)),
                      const SizedBox(width: 12),
                      Expanded(child: _InfoCard(icon: Icons.straighten, label: l.distance, value: mountain.distance)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _InfoCard(icon: Icons.height, label: l.altitude, value: '${mountain.height}m')),
                      const SizedBox(width: 12),
                      Expanded(child: _InfoCard(icon: Icons.location_on_outlined, label: l.region, value: mountain.location)),
                      const SizedBox(width: 12),
                      Expanded(child: _InfoCard(icon: Icons.star_outline, label: l.tag, value: mountain.emoji)),
                    ],
                  ),

                  const SizedBox(height: 24),
                  Text(l.introduction, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: context.appText)),
                  const SizedBox(height: 8),
                  Text(
                    mountain.description,
                    style: TextStyle(
                      color: context.appTextSub,
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 24),
                  Text(l.courseInfo, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: context.appText)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withAlpha(15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _CourseRow(label: l.courseDistance, value: mountain.distance),
                        const Divider(height: 24),
                        _CourseRow(label: l.courseTime, value: mountain.time),
                        const Divider(height: 24),
                        _CourseRow(label: l.altitude, value: '${mountain.height}m'),
                        const Divider(height: 24),
                        _CourseRow(label: l.difficulty, value: mountain.difficulty.label),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  Text(l.location, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: context.appText)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.appSurface,
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
                              Text(mountain.location, style: TextStyle(fontWeight: FontWeight.w600, color: context.appText)),
                              Text(
                                '위도 ${mountain.latitude.toStringAsFixed(4)}, 경도 ${mountain.longitude.toStringAsFixed(4)}',
                                style: TextStyle(color: context.appTextSub, fontSize: 12),
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
        label: Text(l.startHiking, style: const TextStyle(fontWeight: FontWeight.w700)),
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
        color: context.appSurface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Icon(icon, color: color ?? AppTheme.primary, size: 20),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: context.appTextSub, fontSize: 10)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: context.appText), textAlign: TextAlign.center),
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
        Text(label, style: TextStyle(color: context.appTextSub, fontSize: 14)),
        Text(value, style: TextStyle(fontWeight: FontWeight.w600, color: context.appText, fontSize: 14)),
      ],
    );
  }
}
