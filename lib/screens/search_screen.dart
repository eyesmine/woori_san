import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../models/mountain.dart';
import '../providers/mountain_provider.dart';
import '../widgets/mountain_card.dart';

enum _HeightFilter { all, under500, from500to1000, over1000 }

enum _SortOption { name, height, difficulty }

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  Difficulty? _selectedDifficulty;
  String? _selectedRegion;
  _HeightFilter _heightFilter = _HeightFilter.all;
  _SortOption _sortOption = _SortOption.name;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> _getGroupedRegions(List<Mountain> mountains) {
    final regionSet = <String>{};
    for (final m in mountains) {
      final firstWord = m.location.split(RegExp(r'[\s/]')).first;
      regionSet.add(firstWord);
    }
    final regions = regionSet.toList()..sort();
    return regions;
  }

  bool _applyHeightFilter(int height) {
    return switch (_heightFilter) {
      _HeightFilter.all => true,
      _HeightFilter.under500 => height <= 500,
      _HeightFilter.from500to1000 => height > 500 && height <= 1000,
      _HeightFilter.over1000 => height > 1000,
    };
  }

  List<Mountain> _applySort(List<Mountain> results) {
    switch (_sortOption) {
      case _SortOption.name:
        results.sort((a, b) => a.name.compareTo(b.name));
      case _SortOption.height:
        results.sort((a, b) => b.height.compareTo(a.height));
      case _SortOption.difficulty:
        results.sort((a, b) {
          const order = {Difficulty.beginner: 0, Difficulty.intermediate: 1, Difficulty.advanced: 2};
          return order[a.difficulty]!.compareTo(order[b.difficulty]!);
        });
    }
    return results;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l.searchHint,
            border: InputBorder.none,
            hintStyle: TextStyle(color: context.appTextSub),
          ),
          style: const TextStyle(fontSize: 16),
          onChanged: (v) => setState(() => _query = v.trim()),
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                setState(() => _query = '');
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Difficulty + Region filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                _FilterChip(
                  label: '전체 난이도',
                  selected: _selectedDifficulty == null,
                  onTap: () => setState(() => _selectedDifficulty = null),
                ),
                const SizedBox(width: 8),
                ...Difficulty.values.map((d) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _FilterChip(
                    label: d.label,
                    selected: _selectedDifficulty == d,
                    color: d.color,
                    onTap: () => setState(() => _selectedDifficulty = _selectedDifficulty == d ? null : d),
                  ),
                )),
                const SizedBox(width: 8),
                _FilterChip(
                  label: '전체 지역',
                  selected: _selectedRegion == null,
                  onTap: () => setState(() => _selectedRegion = null),
                ),
                const SizedBox(width: 8),
                ..._getGroupedRegions(context.read<MountainProvider>().mountains).map((r) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _FilterChip(
                    label: r,
                    selected: _selectedRegion == r,
                    onTap: () => setState(() => _selectedRegion = _selectedRegion == r ? null : r),
                  ),
                )),
              ],
            ),
          ),

          // Height filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                _FilterChip(
                  label: l.allHeight,
                  selected: _heightFilter == _HeightFilter.all,
                  onTap: () => setState(() => _heightFilter = _HeightFilter.all),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: l.heightUnder500,
                  selected: _heightFilter == _HeightFilter.under500,
                  onTap: () => setState(() => _heightFilter = _heightFilter == _HeightFilter.under500 ? _HeightFilter.all : _HeightFilter.under500),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: l.height500to1000,
                  selected: _heightFilter == _HeightFilter.from500to1000,
                  onTap: () => setState(() => _heightFilter = _heightFilter == _HeightFilter.from500to1000 ? _HeightFilter.all : _HeightFilter.from500to1000),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: l.heightOver1000,
                  selected: _heightFilter == _HeightFilter.over1000,
                  onTap: () => setState(() => _heightFilter = _heightFilter == _HeightFilter.over1000 ? _HeightFilter.all : _HeightFilter.over1000),
                ),
              ],
            ),
          ),

          // Sort options + result count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Consumer<MountainProvider>(
              builder: (context, state, _) {
                var results = state.search(_query, difficulty: _selectedDifficulty, region: _selectedRegion);
                results = results.where((m) => _applyHeightFilter(m.height)).toList();
                return Row(
                  children: [
                    Text(
                      '${results.length}${l.mountainCount}',
                      style: TextStyle(color: context.appTextSub, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    const Spacer(),
                    _SortChip(
                      label: l.sortByName,
                      selected: _sortOption == _SortOption.name,
                      onTap: () => setState(() => _sortOption = _SortOption.name),
                    ),
                    const SizedBox(width: 6),
                    _SortChip(
                      label: l.sortByHeight,
                      selected: _sortOption == _SortOption.height,
                      onTap: () => setState(() => _sortOption = _SortOption.height),
                    ),
                    const SizedBox(width: 6),
                    _SortChip(
                      label: l.sortByDifficulty,
                      selected: _sortOption == _SortOption.difficulty,
                      onTap: () => setState(() => _sortOption = _SortOption.difficulty),
                    ),
                  ],
                );
              },
            ),
          ),

          // Results
          Expanded(
            child: Consumer<MountainProvider>(
              builder: (context, state, _) {
                var results = state.search(
                  _query,
                  difficulty: _selectedDifficulty,
                  region: _selectedRegion,
                );

                // Apply height filter
                results = results.where((m) => _applyHeightFilter(m.height)).toList();

                // Apply sort
                results = _applySort(results);

                if (results.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🔍', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 16),
                        Text(
                          l.noSearchResults,
                          style: TextStyle(color: context.appTextSub, fontSize: 15),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: results.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final mountain = results[index];
                    return GestureDetector(
                      onTap: () => context.push('/mountain/${mountain.id}'),
                      child: _SearchResultTile(mountain: mountain),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? (color ?? AppTheme.primary) : context.appSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? (color ?? AppTheme.primary) : Colors.grey.shade200,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : context.appTextSub,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SortChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary.withAlpha(25) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppTheme.primary : Colors.grey.shade200,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppTheme.primary : context.appTextSub,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final Mountain mountain;
  const _SearchResultTile({required this.mountain});

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
                Text('${mountain.location} · ${mountain.height}m · ${mountain.distance}', style: TextStyle(color: context.appTextSub, fontSize: 13)),
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
