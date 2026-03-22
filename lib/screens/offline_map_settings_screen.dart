import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../models/mountain.dart';
import '../providers/mountain_provider.dart';

class OfflineMapSettingsScreen extends StatefulWidget {
  const OfflineMapSettingsScreen({super.key});

  @override
  State<OfflineMapSettingsScreen> createState() => _OfflineMapSettingsScreenState();
}

class _OfflineMapSettingsScreenState extends State<OfflineMapSettingsScreen> {
  final Set<String> _preloadingIds = {};
  final Set<String> _preloadedIds = {};

  @override
  void initState() {
    super.initState();
    _loadCachedStatus();
  }

  void _loadCachedStatus() {
    final box = Hive.box(AppConstants.cacheBox);
    final cached = box.get('preloaded_maps', defaultValue: <dynamic>[]);
    if (cached is List) {
      setState(() {
        _preloadedIds.addAll(cached.cast<String>());
      });
    }
  }

  Future<void> _preloadMap(Mountain mountain) async {
    setState(() => _preloadingIds.add(mountain.id));

    // Simulate pre-loading map tiles by waiting briefly.
    // In a real implementation, this would programmatically create a hidden
    // NaverMap widget centered on the mountain's coordinates to warm the SDK cache.
    await Future.delayed(const Duration(seconds: 2));

    final box = Hive.box(AppConstants.cacheBox);
    _preloadedIds.add(mountain.id);
    await box.put('preloaded_maps', _preloadedIds.toList());

    if (mounted) {
      setState(() => _preloadingIds.remove(mountain.id));
    }
  }

  Future<void> _clearCache() async {
    final box = Hive.box(AppConstants.cacheBox);
    await box.delete('preloaded_maps');
    if (mounted) {
      setState(() {
        _preloadedIds.clear();
      });
      final l = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.cacheCleared)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final mountains = context.watch<MountainProvider>().mountains;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.offlineMaps),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primary.withAlpha(15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.primary.withAlpha(40)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppTheme.primary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l.offlineMapsInfo,
                    style: TextStyle(
                      color: context.appText,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Section title
          Text(
            l.downloadMaps,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: context.appText,
            ),
          ),
          const SizedBox(height: 12),

          // Mountain list
          if (mountains.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  l.loadingCourses,
                  style: TextStyle(color: context.appTextSub),
                ),
              ),
            )
          else
            ...mountains.map((mountain) => _MountainCacheTile(
              mountain: mountain,
              isPreloaded: _preloadedIds.contains(mountain.id),
              isPreloading: _preloadingIds.contains(mountain.id),
              onPreload: () => _preloadMap(mountain),
            )),

          const SizedBox(height: 32),

          // Clear cache button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _preloadedIds.isNotEmpty ? _clearCache : null,
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              label: Text(
                l.clearMapCache,
                style: const TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(
                  color: _preloadedIds.isNotEmpty ? Colors.red : Colors.grey.shade300,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _MountainCacheTile extends StatelessWidget {
  final Mountain mountain;
  final bool isPreloaded;
  final bool isPreloading;
  final VoidCallback onPreload;

  const _MountainCacheTile({
    required this.mountain,
    required this.isPreloaded,
    required this.isPreloading,
    required this.onPreload,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(colors: mountain.colors),
            ),
            child: Center(
              child: Text(mountain.emoji, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mountain.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: context.appText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  mountain.location,
                  style: TextStyle(
                    color: context.appTextSub,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (isPreloading)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppTheme.primary,
              ),
            )
          else if (isPreloaded)
            const Icon(Icons.check_circle, color: AppTheme.primary, size: 24)
          else
            TextButton(
              onPressed: onPreload,
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: AppTheme.primary),
                ),
              ),
              child: Text(
                l.preloadMap,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }
}
