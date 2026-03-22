import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../providers/stamp_provider.dart';
import '../widgets/stamp_tile.dart';
import '../widgets/empty_state.dart';

class StampScreen extends StatefulWidget {
  const StampScreen({super.key});

  @override
  State<StampScreen> createState() => _StampScreenState();
}

class _StampScreenState extends State<StampScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l.stampCollection)),
      body: Consumer<StampProvider>(
        builder: (context, state, _) {
          if (state.stamps.isEmpty) {
            return Center(
              child: EmptyState(
                emoji: '🎖️',
                message: l.noStampsYet,
              ),
            );
          }
          final togetherList = state.togetherStamps;
          final filtered = _searchQuery.isEmpty
              ? state.stamps
              : state.stamps.where((s) => s.name.contains(_searchQuery) || s.region.contains(_searchQuery)).toList();

          const gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.85,
          );

          return CustomScrollView(
            slivers: [
              // Progress header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: _ProgressHeader(
                    total: state.stamps.length,
                    stamped: state.totalStamped,
                    together: state.togetherStamped,
                  ),
                ),
              ),

              // Search field
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: l.searchHint,
                      hintStyle: TextStyle(color: context.appTextSub, fontSize: 14),
                      prefixIcon: Icon(Icons.search, color: context.appTextSub, size: 20),
                      filled: true,
                      fillColor: context.appSurface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    style: TextStyle(fontSize: 14, color: context.appText),
                    onChanged: (v) => setState(() => _searchQuery = v.trim()),
                  ),
                ),
              ),

              // Together section (only when no search query)
              if (togetherList.isNotEmpty && _searchQuery.isEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                    child: Row(children: [
                      Text('💑 ${l.togetherMountains}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: context.appText)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: AppTheme.accent.withAlpha(38), borderRadius: BorderRadius.circular(8)),
                        child: Text('${togetherList.length}개', style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w700, fontSize: 12)),
                      ),
                    ]),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    gridDelegate: gridDelegate,
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => StampTile(
                        mountain: togetherList[index],
                        globalIndex: state.stamps.indexOf(togetherList[index]),
                      ),
                      childCount: togetherList.length,
                    ),
                  ),
                ),
              ],

              // All mountains title + count
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                  child: Row(children: [
                    Text(l.allMountains, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: context.appText)),
                    const SizedBox(width: 8),
                    Text('${state.totalStamped} / ${state.stamps.length}', style: TextStyle(color: context.appTextSub, fontSize: 14)),
                  ]),
                ),
              ),

              // All stamps (lazy loaded via SliverGrid)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                sliver: SliverGrid(
                  gridDelegate: gridDelegate,
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => StampTile(
                      mountain: filtered[index],
                      globalIndex: state.stamps.indexOf(filtered[index]),
                    ),
                    childCount: filtered.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  final int total;
  final int stamped;
  final int together;

  const _ProgressHeader({required this.total, required this.stamped, required this.together});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final progress = stamped / total;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.challenge100, style: TextStyle(fontSize: 13, color: context.appTextSub)),
                  const SizedBox(height: 2),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: '$stamped', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.primary)),
                        TextSpan(text: ' / $total', style: TextStyle(fontSize: 16, color: context.appTextSub, fontWeight: FontWeight.w500)),
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
                    Text('${(progress * 100).toInt()}%',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.accent.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Text('💑', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${l.together} $together개 오름', style: TextStyle(fontWeight: FontWeight.w700, color: context.appText, fontSize: 14)),
                    Text('${total - stamped}${l.waitingMountains}', style: TextStyle(color: context.appTextSub, fontSize: 12)),
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
