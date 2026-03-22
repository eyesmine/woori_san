import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../models/mountain.dart';
import '../providers/mountain_provider.dart';
import '../providers/stamp_provider.dart';
import '../providers/weather_provider.dart';
import '../providers/location_provider.dart';
import '../providers/badge_provider.dart';
import '../widgets/mountain_card.dart';
import '../widgets/weather_card.dart';
import '../widgets/empty_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initWithLocation();
      _checkNewBadges();
    });
  }

  void _checkNewBadges() {
    final badgeProv = context.read<BadgeProvider>();
    final mountainProv = context.read<MountainProvider>();
    final stampProv = context.read<StampProvider>();
    final prevCount = badgeProv.earnedCount;
    badgeProv.evaluate(records: mountainProv.records, stamps: stampProv.stamps);
    if (badgeProv.earnedCount <= prevCount) return; // no new badges
    final newBadges = badgeProv.getNewlyEarnedBadges();
    if (newBadges.isNotEmpty && mounted) {
      final l = AppLocalizations.of(context)!;
      final isKorean = l.localeName == 'ko';
      for (final badge in newBadges) {
        final title = isKorean ? badge.titleKo : badge.titleEn;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Text(badge.emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.newBadgeEarned, style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
                      Text(title, style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _initWithLocation() async {
    final locationProvider = context.read<LocationProvider>();
    final weatherProvider = context.read<WeatherProvider>();
    final mountainProvider = context.read<MountainProvider>();

    await locationProvider.getCurrentPosition();
    final pos = locationProvider.currentPosition;

    final lat = pos?.latitude ?? AppConstants.defaultLat;
    final lng = pos?.longitude ?? AppConstants.defaultLng;

    await Future.wait([
      weatherProvider.fetchWeather(lat, lng),
      mountainProvider.loadRecommended(lat: lat, lng: lng),
    ]);

    // 산 목록에서 누락된 도장 동기화
    if (mounted && mountainProvider.mountains.isNotEmpty) {
      context.read<StampProvider>().syncWithMountains(mountainProvider.mountains);
    }
  }

  Future<void> _onRefresh() async {
    await _initWithLocation();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppTheme.primary,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: context.appBg,
              flexibleSpace: FlexibleSpaceBar(
                background: const _HeaderBanner(),
              ),
              title: Text('${l.appTitle} 🏔️'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => context.push('/search'),
                ),
                IconButton(
                  icon: const Icon(Icons.person_outline),
                  onPressed: () => context.push('/profile'),
                ),
              ],
            ),

            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: WeatherCard(),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l.recommendedCourses, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: context.appText)),
                    TextButton(
                      onPressed: () => _showAllMountains(context),
                      child: Text(l.viewAll, style: const TextStyle(color: AppTheme.primary)),
                    ),
                  ],
                ),
              ),
            ),

            Consumer<MountainProvider>(
              builder: (context, state, _) {
                if (state.isLoading) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
                    ),
                  );
                }
                if (state.error != null) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: EmptyState(
                        emoji: '⚠️',
                        message: state.error!,
                      ),
                    ),
                  );
                }
                if (state.recommended.isEmpty && state.mountains.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: EmptyState(
                        emoji: '🏔️',
                        message: l.loadingCourses,
                      ),
                    ),
                  );
                }
                final displayList = state.recommended.isNotEmpty ? state.recommended : state.mountains.take(10).toList();
                return SliverToBoxAdapter(
                  child: SizedBox(
                    height: 220,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemCount: displayList.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (context, index) => MountainCard(mountain: displayList[index]),
                    ),
                  ),
                );
              },
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 8),
                child: Row(
                  children: [
                    Container(width: 4, height: 20, decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(2))),
                    const SizedBox(width: 10),
                    Expanded(child: Text(l.ourRecords, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: context.appText))),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: AppTheme.primary),
                      onPressed: () => context.push('/record/new'),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Consumer2<MountainProvider, StampProvider>(
                  builder: (context, mState, sState, _) => _StatsCard(
                    hikes: mState.totalHikes,
                    distance: mState.totalDistance,
                    stamps: sState.totalStamped,
                  ),
                ),
              ),
            ),

            Consumer<MountainProvider>(
              builder: (context, state, _) {
                if (state.records.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                      child: EmptyState(
                        emoji: '🌱',
                        message: l.noRecordsYet,
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= state.records.length) return null;
                        final r = state.records[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GestureDetector(
                            onTap: () => context.push('/record/${r.id}'),
                            child: _RecentRecord(
                              mountain: r.mountain,
                              date: r.date,
                              duration: r.duration,
                              distance: r.distance,
                              emoji: r.emoji,
                            ),
                          ),
                        );
                      },
                      childCount: state.records.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAllMountains(BuildContext context) {
    final mountains = context.read<MountainProvider>().mountains;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (sheetContext, scrollController) => _AllMountainsSheet(
          mountains: mountains,
          scrollController: scrollController,
          onTap: (mountain) {
            Navigator.pop(sheetContext);
            context.push('/mountain/${mountain.id}');
          },
        ),
      ),
    );
  }
}

class _AllMountainsSheet extends StatefulWidget {
  final List<Mountain> mountains;
  final ScrollController scrollController;
  final void Function(Mountain) onTap;

  const _AllMountainsSheet({
    required this.mountains,
    required this.scrollController,
    required this.onTap,
  });

  @override
  State<_AllMountainsSheet> createState() => _AllMountainsSheetState();
}

class _AllMountainsSheetState extends State<_AllMountainsSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final queryLower = _query.toLowerCase();
    final filtered = _query.isEmpty
        ? widget.mountains
        : widget.mountains.where((m) => m.name.toLowerCase().contains(queryLower) || m.location.toLowerCase().contains(queryLower)).toList();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 16),
                Text(l.allMountains, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: l.searchHint,
                    prefixIcon: const Icon(Icons.search, color: AppTheme.primary),
                    filled: true,
                    fillColor: context.appSurface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(child: Text(l.noSearchResults, style: TextStyle(color: context.appTextSub)))
                : ListView.separated(
                    controller: widget.scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (ctx, index) => GestureDetector(
                      onTap: () => widget.onTap(filtered[index]),
                      child: _MountainDetailTile(mountain: filtered[index]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _HeaderBanner extends StatelessWidget {
  const _HeaderBanner();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
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
              Text(l.headerSubtitle, style: const TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 4),
              Text(l.headerTitle, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800, height: 1.3)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final int hikes;
  final String distance;
  final int stamps;
  const _StatsCard({required this.hikes, required this.distance, required this.stamps});

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

class _MountainDetailTile extends StatelessWidget {
  final Mountain mountain;
  const _MountainDetailTile({required this.mountain});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(colors: mountain.colors),
            ),
            child: Center(child: Text(mountain.emoji, style: const TextStyle(fontSize: 28))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mountain.name, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: context.appText)),
                const SizedBox(height: 4),
                Text('${mountain.location} · ${mountain.height}m', style: TextStyle(color: context.appTextSub, fontSize: 13)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              DifficultyTag(difficulty: mountain.difficulty),
              const SizedBox(height: 4),
              Text(mountain.time, style: TextStyle(color: context.appTextSub, fontSize: 12)),
            ],
          ),
        ],
      ),
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
        color: context.appSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(color: AppTheme.primary.withAlpha(25), borderRadius: BorderRadius.circular(14)),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mountain, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: context.appText)),
                const SizedBox(height: 4),
                Text(date, style: TextStyle(color: context.appTextSub, fontSize: 13)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(duration, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.primary)),
              Text(distance, style: TextStyle(color: context.appTextSub, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
