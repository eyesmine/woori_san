import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
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
import '../widgets/home_stats_card.dart';
import '../widgets/home_header_banner.dart';
import '../widgets/recent_record_tile.dart';

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

    badgeProv.evaluate(records: mountainProv.records, stamps: stampProv.stamps);

    final box = Hive.box(AppConstants.settingsBox);
    final lastShownCount = box.get('lastBadgeCount', defaultValue: 0) as int;
    final currentCount = badgeProv.earnedCount;

    if (currentCount <= lastShownCount) return;

    final allEarned = badgeProv.getNewlyEarnedBadges();
    final newCount = currentCount - lastShownCount;
    final newBadges = allEarned.length > newCount
        ? allEarned.sublist(allEarned.length - newCount)
        : allEarned;

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

    box.put('lastBadgeCount', currentCount);
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
              flexibleSpace: const FlexibleSpaceBar(
                background: HomeHeaderBanner(),
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
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
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
                child: Builder(
                  builder: (context) {
                    final hikes = context.select<MountainProvider, int>((p) => p.totalHikes);
                    final distance = context.select<MountainProvider, String>((p) => p.totalDistance);
                    final stamps = context.select<StampProvider, int>((p) => p.totalStamped);
                    return HomeStatsCard(hikes: hikes, distance: distance, stamps: stamps);
                  },
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
                            child: RecentRecordTile(
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
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
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
